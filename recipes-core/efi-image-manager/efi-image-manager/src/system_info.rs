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

use std::path::{Path,PathBuf};

use std::process::Command;

use std::io::{Error,ErrorKind};

use std::fs;

use std::{time};

#[cfg(debug_assertions)]
use std::sync::{OnceLock};

#[cfg(debug_assertions)]
static IS_REAL_SYSTEM: OnceLock<bool> = OnceLock::new();

#[cfg(debug_assertions)]
pub fn check_real_system() -> bool {
    let device_prop_present = Path::new("/etc/device.properties").exists();
    IS_REAL_SYSTEM.set(device_prop_present).expect("Unable to set is_real_system lock");
    return device_prop_present;
}

#[cfg(debug_assertions)]
pub fn am_i_real() -> bool {
    return IS_REAL_SYSTEM.get().unwrap().clone();
}

#[cfg(not(debug_assertions))]
pub const fn am_i_real() -> bool {
    return true;
}

pub fn get_boot_mount_path() -> PathBuf {
    let mut boot_mount_path = PathBuf::new();
    if !am_i_real() {
        boot_mount_path.push("fakeenv/boot");
    } else {
        boot_mount_path.push("/boot/");
    }
    return boot_mount_path;
}

pub fn get_rdkb_boot_path() -> PathBuf {
    let rdkb_boot_path = get_boot_mount_path();
    return rdkb_boot_path.join("rdkb/");
}

pub fn get_systemd_loader_path() -> PathBuf {
    let systemd_loader_path = get_boot_mount_path().join("loader/");
    return systemd_loader_path;
}

pub fn get_systemd_loader_conf_path() -> PathBuf {
    let loader_dir_path = get_systemd_loader_path();
    let loader_conf_path = loader_dir_path.join("loader.conf");
    return loader_conf_path;
}

pub fn get_subvolume_path() -> PathBuf {
    let mut volumes_path = PathBuf::new();
    if !am_i_real() {
        volumes_path.push("fakeenv/volumes/");
        return volumes_path;
    } else {
        volumes_path.push("/volumes/toplevel/");
    }
    return volumes_path;
}

pub fn get_root_cmdline_arg() -> Result<String, std::io::Error> {
    if !am_i_real() {
        let root_cmdline_arg = "PARTUUID=5869c2a2-1f56-4b0e-832a-bab8627fe6b2".to_string();
        return Ok(root_cmdline_arg);
    }
    let blkid_output = Command::new("blkid").
        args(["-t","LABEL=root","-s","PARTUUID","-o","value"]).
        output().
        expect("blkid failed to execute");
    assert!(blkid_output.status.success());
    let blkid_output_str = String::from_utf8(blkid_output.stdout).unwrap();

    let root_part_arg = format!("PARTUUID={}", blkid_output_str.trim());
    return Ok(root_part_arg);
}

pub fn is_boot_mounted_ro() -> Result<bool, std::io::Error> {
    if !am_i_real() {
        return Ok(false);
    }
    let version_txt_contents = fs::read_to_string("/proc/mounts")?;
    for line in version_txt_contents.lines() {
        let line_split = line.split(" ");
        let line_split_components : Vec<&str> = line_split.collect();
        let mount_point = line_split_components[1];
        if mount_point == "/boot" {
            let mount_point_options = line_split_components[3];
            let is_mount_point_ro = mount_point_options.contains("ro,");
            return Ok(is_mount_point_ro);
        }
    }
    // No boot entry found, throw an error
    let eof_error = ErrorKind::UnexpectedEof;
    let error = Error::from(eof_error);
    return Err(error);
}

fn get_fstab_path() -> PathBuf {
    let mut fstab_file_path = PathBuf::new();
    if !am_i_real() {
        fstab_file_path.push("fakeenv/etc/fstab")
    } else {
        fstab_file_path.push("/etc/fstab")
    }
    return fstab_file_path;
}

pub fn get_fstab_boot_line() -> Result<String, std::io::Error> {
    let fstab_file_path = get_fstab_path();
    if !fstab_file_path.exists() {
        return Err(ErrorKind::NotFound.into());
    }
    let fstab_file_str = fs::read_to_string(fstab_file_path);
    for fstab_line in fstab_file_str?.lines() {
        if fstab_line.contains("/boot") {
            return Ok(fstab_line.to_string());
        }
    }
    let eof_error = ErrorKind::UnexpectedEof;
    let error = Error::from(eof_error);
    return Err(error);
}

pub fn remount_boot(readonly: bool) -> Result<(), std::io::Error> {
    if !am_i_real() {
        return Ok(());
    }
    let mode_str: String = match readonly {
        true => "ro".to_string(),
        _ => "rw".to_string()
    };
    let mount_arguments = format!("remount,{mode_str}");
    Command::new("mount").args(["-o",&mount_arguments, "/boot"]).spawn().expect("failed to remount /boot");
    Ok(())
}

pub fn remount_and_wait_for_boot() -> Result<(), std::io::Error> {
    let remount_boot_err = remount_boot(false);
    if remount_boot_err.is_err() {
        panic!("Unable to remount /boot as read-write");
    }
    /* It appears /boot does not become read/write immediately, so
    * give some time to the kernel */
    std::thread::sleep(time::Duration::from_secs(1));
    let mut is_boot_ro_now = is_boot_mounted_ro()?;
    while is_boot_ro_now {
        println!("Waiting for /boot to become read-write");
        std::thread::sleep(time::Duration::from_secs(1));
        is_boot_ro_now = is_boot_mounted_ro()?;
    }
    return Ok(());
}

pub fn get_mount_option(mount_options_string: String, mount_option_key: &str) -> Option<String> {
    let mount_options_split = mount_options_string.split(",");
    let mount_split_components : Vec<&str> = mount_options_split.collect();
    for this_mount_option_pair in mount_split_components {
        let this_mount_option_split : Vec<&str> = this_mount_option_pair.split("=").collect();
        if this_mount_option_split[0] == mount_option_key {
            return Some(this_mount_option_split[1].to_string());
        }
    }
    return None;
}

pub fn get_running_image_subvol_id() -> Result<Option<u64>,Error> {
    let proc_mounts_contents: String = match am_i_real() {
        true =>  fs::read_to_string("/proc/mounts")?,
        false => "/dev/vda2 / btrfs rw,relatime,space_cache=v2,subvolid=260,subvol=/@root_20250922053311-ro 0 0".to_string(),
    };

    let mut subvolid_str_holder : Option<String> = None;
    for line in proc_mounts_contents.lines() {
        let line_split = line.split(" ");
        let line_split_components : Vec<&str> = line_split.collect();
        let mount_point = line_split_components[1];
        if mount_point == "/" {
            let mount_point_options = line_split_components[3];
            subvolid_str_holder = get_mount_option(mount_point_options.to_string(), "subvolid");
            break;
        }
    }
    if let Some(subvolid_str) = subvolid_str_holder {
        let subvol_id : u64 = subvolid_str.parse().expect("Unable to parse subvolume ID");
        return Ok(Some(subvol_id));
    }
    return Ok(None);
}