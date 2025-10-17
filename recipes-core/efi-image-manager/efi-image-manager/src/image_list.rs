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

pub fn cli_command_list_images() -> Result<(), std::io::Error> {
    let map_of_images = image_info::list_installed_images();
    let active_image = image_info::get_active_image();
    let has_active_image = active_image != None;
    let active_image_value = active_image.unwrap_or("".to_string());

    for (key,_val) in map_of_images.iter() {
        print!("{}", key);
        if has_active_image && (*key == active_image_value) {
            println!(" *");
        } else {
            println!();
        }
    }
    Ok(())
}