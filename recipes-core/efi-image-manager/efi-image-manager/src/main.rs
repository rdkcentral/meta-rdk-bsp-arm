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

use clap::{Parser, Subcommand};
use std::io::{Error,ErrorKind};

pub mod image_ingestion;
pub mod image_info;
pub mod image_list;
pub mod image_mgmt;
pub mod system_info;
pub mod btrfs_driver;

#[derive(Parser,Debug)]
#[command(author, version, about, long_about = None)]
struct CliArgs {
    #[command(subcommand)]
    cmd: Commands
}

#[derive(Subcommand, Debug, Clone)]
enum Commands {
    ListImages,
    RemoveImage {
        image: String
    },
    Import {
        image: String,
    },
    SetActive {
        image: String,
    },
    GetRunningImage,
    Commit,
    Revert {
        image: String,
    },
    GetPartUUID,
    IsBootRO,
    BootLine,
}



fn print_example_struct() -> Result<(), std::io::Error> {
    let test_image = image_info::SystemImage {
        image_name: "rdkb-2025-q1-12345678".to_owned(),
        root_volume_id: 123,
        read_write_volume_id: Some(124),
        nvram_volume_id: 456,
        cmdline_extra: Some("net.ifnames=0".to_owned()),
    };

    let j = serde_json::to_string_pretty(&test_image).unwrap();
    println!("{}", j);
    Ok(())
}

fn cli_command_set_next_boot(image: &String) -> Result<(), std::io::Error> {
    println!("FIXME! ({})",image);
    Ok(())
}

fn cli_command_get_root_part_uuid() -> Result<(), std::io::Error> {
    let root_part_uuid_result = system_info::get_root_cmdline_arg()?;
    println!("{}", root_part_uuid_result);
    Ok(())
}

fn cli_command_is_boot_ro() -> Result<(), std::io::Error> {
    let is_boot_ro = system_info::is_boot_mounted_ro().expect("Unable to read /proc/mounts");
    println!("{:?}", is_boot_ro);
    Ok(())
}

fn cli_command_get_fstab_boot_line() -> Result<(), std::io::Error> {
    let fstab_line = system_info::get_fstab_boot_line()?;
    println!("{:?}", fstab_line);
    Ok(())
}

fn cli_command_get_running_image() -> Result<(), std::io::Error> {
    if let Some(running_image) = image_info::get_running_image() {
        println!("Running system image: {:?}", running_image);
        return Ok(());
    }
    let not_found_error = ErrorKind::NotFound;
    let error = Error::from(not_found_error);
    return Err(error);
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    #[cfg(debug_assertions)]
    {
        let real_system = system_info::check_real_system();
        if !real_system {
            eprintln!("Not running on a production system, all operations will be performed on \"fakeboot\"");
            eprintln!();
        }
    }
  
    let args = CliArgs::parse();
  
    println!("{:?}", args);
    match &args.cmd {
        Commands::ListImages => image_list::cli_command_list_images()?,
        Commands::Import {image} => image_ingestion::cli_command_import(&image)?,
        Commands::SetActive {image} => image_mgmt::cli_command_set_active_image(&image)?,
        Commands::RemoveImage {image} => image_mgmt::cli_command_remove_image(&image)?,
        Commands::GetRunningImage => cli_command_get_running_image()?,
        Commands::GetPartUUID => cli_command_get_root_part_uuid()?,
        Commands::IsBootRO => cli_command_is_boot_ro()?,
        Commands::BootLine => cli_command_get_fstab_boot_line()?,
        _ => print_example_struct()?,
    };
    Ok(())
}
