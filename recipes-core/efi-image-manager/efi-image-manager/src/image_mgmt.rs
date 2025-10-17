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

use crate::image_info;
use crate::system_info;
use crate::btrfs_driver;
use std::fs;

pub fn cli_command_set_active_image(image: &String) -> Result<(), std::io::Error> {
    let map_of_images = image_info::list_installed_images();
    println!("Want to set {image} as active");

    if !map_of_images.contains_key(image) {
        panic!("ERROR: \"{image}\" not found");
    }

    let systemd_loader_config_path = system_info::get_systemd_loader_conf_path();
    println!("Writing to {}", systemd_loader_config_path.display());
    let conf_file_contents = format!("default {}\r\ntimeout 5\r\n", image);
    fs::write(systemd_loader_config_path, conf_file_contents)?;
    Ok(())
}

pub fn cli_command_remove_image(image: &String) -> Result<(), std::io::Error> {
    let map_of_images = image_info::list_installed_images();
    println!("Want to remove {image}");

    if !map_of_images.contains_key(image) {
        panic!("ERROR: \"{image}\" not found");
    }

    let image_to_remove = &map_of_images[image];
    if let Some(running_image) = image_info::get_running_image() {
        if running_image.root_volume_id == image_to_remove.root_volume_id {
            panic!("ERROR: It appears you are trying to remove the running image");
        }
    }

    /* Remove files from /boot first */
    let boot_distro_kernel_dir = system_info::get_rdkb_boot_path();
    let boot_version_path = boot_distro_kernel_dir.join(image);
    if !boot_version_path.exists() {
        panic!("No boot path for this image");
    }

    let loader_conf_path = system_info::get_systemd_loader_path();
    let loader_conf_name = format!("{image}.conf");
    let loader_conf_file = loader_conf_path.join("entries").join(loader_conf_name);
    if !loader_conf_file.exists() {
        panic!("Loader file not found at expected path: {}", loader_conf_file.display());
    }

    let is_boot_ro_stat = system_info::is_boot_mounted_ro();
    if is_boot_ro_stat.is_err() {
        panic!("Unable to determine /boot read-write status");
    }

    let is_boot_ro = is_boot_ro_stat.unwrap();
    if is_boot_ro {
        system_info::remount_and_wait_for_boot()
        .expect("Unable to remount /boot as read-write");
    }

    fs::remove_file(loader_conf_file)
    .expect("Unable to delete loader configurtion for image");

    fs::remove_dir_all(boot_version_path)
    .expect("Unable to delete boot images path");

    if let Some(read_write_volume_id) = image_to_remove.read_write_volume_id {
        btrfs_driver::delete_volume_by_id(read_write_volume_id)
        .expect("Unable to remove read/write volume {image_to_remove.read_write_volume_id}")
    }
    let root_volume_id = image_to_remove.root_volume_id;
    btrfs_driver::delete_volume_by_id(root_volume_id)
    .expect(format!("Unable to remove root volume with ID {root_volume_id}").as_str());

    let nvram_volume_id = image_to_remove.nvram_volume_id;
    btrfs_driver::delete_volume_by_id(nvram_volume_id)
    .expect(format!("Unable to remove nvram volume with ID {nvram_volume_id}").as_str());

    if is_boot_ro {
        system_info::remount_boot(true)?;
    }

    Ok(())
}