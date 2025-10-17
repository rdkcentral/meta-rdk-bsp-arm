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

use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::fs::File;
use std::fs;

use crate::system_info;

#[derive(Debug)]
pub struct RootFsImageInfo {
    pub image_name: String,
    pub version: String,
    pub build_time: String, 
}

#[derive(Serialize, Deserialize)]
#[derive(Debug)]
pub struct SystemImage {
    pub image_name: String,
    pub root_volume_id: u64,
    pub nvram_volume_id: u64,
    pub read_write_volume_id: Option<u64>,
    pub cmdline_extra: Option<String>
}

pub fn read_image_json_file(json_path: &std::path::Path) -> SystemImage {
    let image_json_file = File::open(json_path);
    let image_info: SystemImage = serde_json::from_reader(image_json_file.unwrap()).unwrap();
    return image_info;
}

pub fn list_installed_images() -> HashMap<String,SystemImage> {
    let mut map_of_images = HashMap::new();

    let boot_distro_kernel_dir = system_info::get_rdkb_boot_path();

    if !boot_distro_kernel_dir.exists() {
        panic!("Distribution boot path {} does not exist", boot_distro_kernel_dir.display());
    }

    let paths = fs::read_dir(boot_distro_kernel_dir).unwrap();

    for path in paths {
        let unwrapped_path = path.unwrap().path();
        if unwrapped_path.is_dir() {
            let image_file_name = unwrapped_path.file_name().unwrap();
            let image_file_name_string = image_file_name.to_str().unwrap().into();
            let image_json_file = unwrapped_path.join("image.json");
            if image_json_file.exists() {
                let image_info = read_image_json_file(&image_json_file);
                map_of_images.insert(image_file_name_string, image_info);
            }
        }
    }
    return map_of_images;
}

pub fn get_active_image() -> Option<String> {
    let loader_conf_file_path = system_info::get_systemd_loader_conf_path();

    if !loader_conf_file_path.exists() {
        eprintln!("systemd-boot loader.conf path {} does not exist", loader_conf_file_path.display());
        return None;
    }

    let loader_conf_contents = fs::read_to_string(loader_conf_file_path).expect("unable to read loader.conf");
    for line in loader_conf_contents.lines() {
        if line.starts_with("default ") {
            let split_line = line.split(" ");
            let collected_split_values: Vec<&str> =  split_line.collect();
            let default_image = collected_split_values[1];
            return Some(default_image.to_string());
        }
    }
    return None;
}

pub fn get_running_image() -> Option<SystemImage> {
    let running_image_subvol_id_holder = system_info::get_running_image_subvol_id()
        .expect("Unable to read /proc/mounts");
    if running_image_subvol_id_holder.is_none() {
        return None;
    }

    let running_image_subvol_id = running_image_subvol_id_holder.unwrap();
    let boot_distro_kernel_dir = system_info::get_rdkb_boot_path();

    if !boot_distro_kernel_dir.exists() {
        panic!("Distribution boot path {} does not exist", boot_distro_kernel_dir.display());
    }

    let paths = fs::read_dir(boot_distro_kernel_dir).unwrap();

    for path in paths {
        let unwrapped_path = path.unwrap().path();
        if unwrapped_path.is_dir() {
            let image_file_name = unwrapped_path.file_name().unwrap();
            let image_file_name_string: String = image_file_name.to_str().unwrap().into();
            let image_json_file = unwrapped_path.join("image.json");
            if image_json_file.exists() {
                let image_info = read_image_json_file(&image_json_file);
                if image_info.root_volume_id == running_image_subvol_id {
                    return Some(image_info);
                }
            }
        }
    }

    return None;
}
