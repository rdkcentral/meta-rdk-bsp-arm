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
use std::fs;
use crate::system_info;

use libbtrfsutil::{CreateSnapshotOptions,DeleteSubvolumeOptions};
#[cfg(debug_assertions)]
use rand::Rng;

pub struct SubvolumeCreationResult {
    pub subvolume_full_path: PathBuf,
    pub creation_result: std::io::Result<()>,
}

/* Functions to wrap libbtrfs while providing adequate simulation for development */
pub fn get_full_subvolume_path(subvol_name: &String) -> PathBuf {
    let subvolume_holder_path = system_info::get_subvolume_path();
    let subvolume_full_path = subvolume_holder_path.join(subvol_name);
    return subvolume_full_path;
}

pub fn create_new_subvolume(subvol_name: &String) -> std::io::Result<PathBuf>  {
    let subvolume_holder_path = get_full_subvolume_path(&subvol_name);
    if !system_info::am_i_real() {
        fs::create_dir(&subvolume_holder_path).expect("Unable to create simulated volume dir at {subvolume_holder_path}");
        return Ok(subvolume_holder_path);
    }
    let subvol_full_path_as_str = subvolume_holder_path.to_str().unwrap();

    let _new_subvol_result = libbtrfsutil::create_subvolume(subvol_full_path_as_str).expect("Unable to create new subvolume at ${subvol_full_path_as_str}");
    return Ok(subvolume_holder_path);
}

pub fn get_subvolume_id_for_subvol_name(subvol_name: &String) -> std::io::Result<u64> {
    let subvolume_full_path = get_full_subvolume_path(subvol_name);
    return get_subvolume_id(&subvolume_full_path);
}

pub fn is_subvolume(subvol_path: &Path) -> Result<bool, libbtrfsutil::Error> {
    if !system_info::am_i_real() {
        return Ok(true);
    }
    let is_subvolume = libbtrfsutil::is_subvolume(subvol_path);
    return is_subvolume;
}

pub fn get_subvolume_id(subvol_path: &PathBuf) -> std::io::Result<u64> {
    #[cfg(debug_assertions)] // avoid bringing in rand:: in release builds
    if !system_info::am_i_real() {
        /* In simulation / development mode, return random subvolume ids */
        let mut rng = rand::rng();
        let n1: u64 = rng.random();
        return Ok(n1);
    }
    let subvol_path_as_string = subvol_path.display().to_string();
    // TODO: Check for error?
    let subvol_info = libbtrfsutil::subvolume_id(subvol_path_as_string).unwrap();
    return Ok(subvol_info);
}

pub fn create_snapshot(snapshot_from_name: &String, snapshot_destination_name: &String, readonly: bool) -> Result<(), libbtrfsutil::Error> {
    let from_volume_full_path = get_full_subvolume_path(&snapshot_from_name);
    let destination_mount_full_path = get_full_subvolume_path(&snapshot_destination_name);
    if !system_info::am_i_real() {
        fs::create_dir(&destination_mount_full_path).expect("Unable to create simulated volume dir at {subvolume_holder_path}");
        return Ok(());
    }
    let _create_snapshot_options = CreateSnapshotOptions::new()
        .readonly(readonly)
        .create(from_volume_full_path, destination_mount_full_path)
        .expect("Unable to create snapshot");
    return Ok(());
}

pub fn create_snapshot_existing_path(from_volume_full_path: &Path, snapshot_destination_name: &String, readonly: bool) -> Result<(), libbtrfsutil::Error> {
    let destination_mount_full_path = get_full_subvolume_path(&snapshot_destination_name);
    if !system_info::am_i_real() {
        fs::create_dir(&destination_mount_full_path).expect("Unable to create simulated volume dir at {subvolume_holder_path}");
        return Ok(());
    }
    let _create_snapshot_options = CreateSnapshotOptions::new()
        .readonly(readonly)
        .create(from_volume_full_path, destination_mount_full_path)
        .expect("Unable to create snapshot");
    return Ok(());
}

pub fn delete_volume_by_id(subvolume_id: u64) -> Result<(), libbtrfsutil::Error> {
    let subvolume_holder_path = system_info::get_subvolume_path();
    let subvolume_path = libbtrfsutil::subvolume_path_with_id(&subvolume_holder_path,subvolume_id)
        .expect(format!("Unable to resolve subvolume path for subvol ID {}", subvolume_id).as_str());
    let full_subvolume_path = subvolume_holder_path.join(subvolume_path);
    println!("Subvolume path to delete: {}",full_subvolume_path.display());
    let _delete_subvolume_operation = DeleteSubvolumeOptions::new()
        .delete(full_subvolume_path);
    return Ok(());
}