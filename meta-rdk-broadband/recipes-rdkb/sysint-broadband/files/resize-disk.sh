#!/bin/sh
####################################################################################
# If not stated otherwise in this file or this component's LICENSE file the
# following copyright and licenses apply:
#
#  Copyright 2024 RDK Management
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##################################################################################

set -e

root_dev=$(df -P / | tail -n 1 | awk '/.*/ { print $1 }')
if [ ! -b "${root_dev}" ]; then
    echo "ERROR: No or invalid root device found: ${root_dev}" > /dev/stderr
    exit 1
fi

root_devname=$(basename "${root_dev}")
root_sysfs=$(readlink -f "/sys/class/block/${root_devname}")
root_partition_num=$(cat "${root_sysfs}/partition")
root_parent_sysfs=$(readlink -f "${root_sysfs}/../")
root_parent=$(basename "${root_parent_sysfs}")
root_parent_dev="/dev/${root_parent}"

if [ ! -b "${root_parent_dev}" ]; then
    echo "ERROR: No device node for ${root_parent_dev} found" > /dev/stderr
    exit 1
fi

if !(sfdisk --list-free "${root_parent_dev}" 2>&1 | grep -q 'backup GPT table is not on the end of the device'); then
    echo "Disk does not need to be resized"
    exit 0
fi

# Get part UUID for root
root_part_uuid=$(sgdisk -i 2 "${root_parent_dev}" | grep 'Partition unique GUID' | awk '{print $NF}')
echo "Root part UUID: ${root_part_uuid}"

sgdisk -e "${root_parent_dev}"
sleep 1
sgdisk -p "${root_parent_dev}"
kpartx -g "${root_parent_dev}" || :
sgdisk -d "${root_partition_num}" "${root_parent_dev}"
sgdisk -N "${root_partition_num}" "${root_parent_dev}"
sgdisk -p "${root_parent_dev}"
sgdisk -u "${root_partition_num}:${root_part_uuid}" "${root_parent_dev}"
new_part_size=$(sgdisk -i "${root_partition_num}" "${root_parent_dev}" | grep "Partition size" | awk '{print $3}')
echo "New partition size: ${new_part_size}"

resizepart "${root_parent_dev}" "${root_partition_num}" "${new_part_size}"

btrfs filesystem resize max /
exit 0
