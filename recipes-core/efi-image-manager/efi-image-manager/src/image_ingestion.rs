/*
 * If not stated otherwise in this file or this component's LICENSE file the
 * following copyright and licenses apply:
 *
 * Copyright 2025 RDK Management
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

use std::path::Path;
use std::process::{Command};
use std::fs;
use std::fs::OpenOptions;
use std::io::Write;

use tempfile::tempdir;

use crate::image_info;
use crate::system_info;
use crate::btrfs_driver;

pub fn cli_command_import(image: &String) -> Result<(), std::io::Error> {
    println!("Image path: ({})",image);
    let image_path = Path::new(image);
    if !image_path.exists() {
        panic!("ERROR: File {} does not exist", image);
    }

    // Create temporary folder to unpack the image in
    let tmp_dir = tempdir().unwrap();
    let tmp_dir_path = tmp_dir.path();
    let tmp_dir_path_str = tmp_dir_path.to_str().unwrap();

    /* unpack the version.txt from tar only (the full rootfs will be extracted to the subvol) */
    let tar_command = Command::new("tar").args(["-C",tmp_dir_path_str,"-xf",image,"./version.txt"]).spawn().expect("Failed to spawn tar extractor");
    let tar_extract_output = tar_command.wait_with_output().expect("Failed to extract new image");
    assert!(tar_extract_output.status.success());
    println!("Extract status: {}", tar_extract_output.status);

    let version_txt_path = tmp_dir_path.join("version.txt");
    if !version_txt_path.exists() {
        panic!("ERROR: No \"version.txt\" in image archive");
    }

    let image_version_info = parse_version_txt_data(&version_txt_path);
    println!("{:?}", image_version_info);

    let image_name = image_version_info.image_name;

    let image_name_split = image_name.split("_");
    let collected_image_name: Vec<&str> = image_name_split.collect();
    let image_name_ts = collected_image_name.last().unwrap().to_string();
    println!("Image timestamp: {image_name_ts}");

    let root_subvol_name = format!("@root_{image_name_ts}");
    /* setup new btrfs volumes */
    let full_subvolume_path = btrfs_driver::create_new_subvolume(&root_subvol_name).expect("Unable to create new root subvolume");

    let root_read_write_subvol_id = btrfs_driver::get_subvolume_id(&full_subvolume_path).expect("Unable to get subvolume id for {full_subvolume_path}");

    let full_subvolume_path_as_string = full_subvolume_path.to_str().unwrap();
    /* Extract the full archive into the new btrfs subvol */
    let full_tar_command = Command::new("tar").args(["-C",full_subvolume_path_as_string,"-xpf",image]).spawn().expect("Failed to spawn tar extractor");
    let full_tar_output = full_tar_command.wait_with_output().expect("Failed to extract new image");

    println!("Full extract status: {}", full_tar_output.status);
    // TODO: Handle extract error
    assert!(full_tar_output.status.success());

    /* Before touching /boot, we need to remount it */
    let is_boot_ro_stat = system_info::is_boot_mounted_ro();
    if is_boot_ro_stat.is_err() {
        panic!("Unable to determine /boot read-write status");
    }

    let is_boot_ro = is_boot_ro_stat.unwrap();

    if is_boot_ro {
        system_info::remount_and_wait_for_boot()
            .expect("Unable to remount /boot as read-write");
    }

    let boot_path = system_info::get_rdkb_boot_path();
    let boot_path_version_folder = boot_path.join(&image_name);
    let version_dir_create_err = fs::create_dir_all(&boot_path_version_folder);

    if version_dir_create_err.is_err() {
        panic!("Unable to create kernel version path {}", boot_path_version_folder.display());
    }

    let kernel_image_path = full_subvolume_path.join("boot").join("Image");
    println!("{:?}", kernel_image_path);

    let boot_path_kernel = boot_path_version_folder.join("Image");

    if kernel_image_path.exists() {
        fs::copy(kernel_image_path, &boot_path_kernel)?;
    }

    let fstab_boot_line = system_info::get_fstab_boot_line();
    if fstab_boot_line.is_err() {
        panic!("Unable to get /boot entry from running system fstab")
    }

    let image_fstab_path = full_subvolume_path.join("etc").join("fstab");
    if !image_fstab_path.exists() {
        panic!("No /etc/fstab file found in extracted image");
    }

    let mut image_fstab_file = OpenOptions::new()
        .append(true)
        .open(image_fstab_path)
        .unwrap();
    let have_written_fstab = writeln!(image_fstab_file, "{}", fstab_boot_line.unwrap());
    if have_written_fstab.is_err() {
        panic!("Unable to append /boot entry to fstab");
    }

    let readonly_snapshot_name = format!("@root_{image_name_ts}-ro");
    let readonly_snapshot_create_result = btrfs_driver::create_snapshot(&root_subvol_name, &readonly_snapshot_name, true);
    if readonly_snapshot_create_result.is_err() {
        panic!("Unable to create read-only rootfs snapshot");
    }
    let readonly_snapshot_id = btrfs_driver::get_subvolume_id_for_subvol_name(&readonly_snapshot_name).expect("Unable to get readonly snapshot id");

    let new_nvram_volume_str = format!("@nvram_{image_name_ts}");
    
    let nvram_path = Path::new("/nvram");
    let is_nvram_a_subvolume = btrfs_driver::is_subvolume(nvram_path).expect("Unable to get /nvram subvol path");
    let nvram_subvolume_id: u64;
    if is_nvram_a_subvolume {
        println!("/nvram already a subvolume, creating a snapshot");
        btrfs_driver::create_snapshot_existing_path(&nvram_path, &new_nvram_volume_str, false).expect("Unable to create new snapshot for /nvram");
        nvram_subvolume_id = btrfs_driver::get_subvolume_id_for_subvol_name(&new_nvram_volume_str).expect("Unable to get new nvram subvolume id");
    } else {
        let full_nvram_volume_path = btrfs_driver::create_new_subvolume(&new_nvram_volume_str).expect("Unable to create nvram volume");
        nvram_subvolume_id = btrfs_driver::get_subvolume_id(&full_nvram_volume_path).expect("Unable to get the nvram_subvoume_id");
    }

    /* TODO: Handle initrd file (if it exists) */

    /* create the json information */
    let image_info = image_info::SystemImage {
        image_name: image_name,
        root_volume_id: readonly_snapshot_id,
        nvram_volume_id: nvram_subvolume_id,
        read_write_volume_id: Some(root_read_write_subvol_id),
        cmdline_extra: None,
    };
    let image_info_json = serde_json::to_string_pretty(&image_info).unwrap();

    let version_image_info_path = boot_path_version_folder.join("image.json");
    let json_write_result = fs::write(&version_image_info_path, image_info_json);
    if json_write_result.is_err() {
        panic!("Unable to write image info to {}", &version_image_info_path.display());
    }

    let boot_mount_path = system_info::get_boot_mount_path();
    let kernel_relative_path = boot_path_kernel.strip_prefix(&boot_mount_path).unwrap();
    
    /* Create a systemd entry */
    create_systemd_loader_entry(&image_info, &kernel_relative_path);

    if is_boot_ro {
        println!("Mounting boot as read-only again");
        system_info::remount_boot(true)?;
    }
    return Ok(());
}

fn get_image_kernel_cmdline(image_info: &image_info::SystemImage) -> Result<String, std::io::Error> {
    let root_argument = system_info::get_root_cmdline_arg()?;
    let cmdline = format!("root={} rootwait rootfstype=btrfs rootflags=subvolid={} net.ifnames=0 nvramvol={}", root_argument, image_info.root_volume_id, image_info.nvram_volume_id);
    return Ok(cmdline);
}

fn create_systemd_loader_entry(image_info: &image_info::SystemImage, kernel_relative_path: &Path) {
    let systemd_loader_config_path = system_info::get_systemd_loader_path();
    let entries_path = systemd_loader_config_path.as_path().join("entries/");

    /* TODO: We should sanitize image names (even if created at a 'trusted' source) */
    let conf_file_name = format!("{}.conf", image_info.image_name);
    let entry_conf_file = entries_path.join(conf_file_name);
    println!("Need to create: {}", entry_conf_file.display());

    /*
    root@armefi64-rdk-broadband:~# cat /boot/loader/entries/boot-1752119416.conf
    title boot-1752119416
    linux /rdkb/.../Image
    options LABEL=Boot root=PARTUUID=5869c2a2-1f56-4b0e-832a-bab8627fe6b2 rootwait rootfstype=btrfs rootflags=subvolid=260 net.ifnames=0 nvramvol=261
    */

    let kernel_cmdline_result = get_image_kernel_cmdline(&image_info);
    if kernel_cmdline_result.is_err() {
        panic!("Unable to construct kernel command line");
    }
    let kernel_cmdline = kernel_cmdline_result.unwrap();

    let conf_file_contents = format!("title {}\r\nlinux {}\r\noptions {}\r\n", 
        image_info.image_name, kernel_relative_path.display(), kernel_cmdline);
    
    let _ = fs::write(entry_conf_file, conf_file_contents);
}

fn parse_version_txt_data(version_text_path: &Path) -> image_info::RootFsImageInfo {
    let version_txt_contents = fs::read_to_string(version_text_path).expect("unable to read version.txt");
    println!("{version_txt_contents}");
    let mut image_name: String = "UNKNOWN".to_string();
    let mut image_version: String = "UNKNOWN".to_string();
    let mut image_build_time: String = "UNKNOWN".to_string();
    for line in version_txt_contents.lines() {
        let split_values = line.split('=');
        let collected_values: Vec<&str> = split_values.collect();
        if collected_values.len() == 1 {
            if line.starts_with("imagename:") {
                let image_name_split = line.split(":");
                let image_name_collected: Vec<&str> = image_name_split.collect();
                image_name = image_name_collected[1].to_string();
            }
        } else {
            match collected_values[0] {
                "VERSION" => image_version = collected_values[1].to_string(),
                "BUILD_TIME" => image_build_time = collected_values[1].to_string(),
                _ => ()
            }
        }
    }
    let version_info_data = image_info::RootFsImageInfo {
        image_name: image_name,
        build_time: image_build_time,
        version: image_version,
    };

    return version_info_data;
}