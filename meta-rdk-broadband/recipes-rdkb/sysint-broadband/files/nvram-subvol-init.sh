#!/bin/sh
####################################################################################
# If not stated otherwise in this file or this component's LICENSE file the
# following copyright and licenses apply:
#
#  Copyright 2025 RDK Management
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

if (grep -q -E " / btrfs" /proc/mounts) && ! (grep -q -E "/nvram btrfs" /proc/mounts); then
	(/lib/rdk/btrfs/resize-disk.sh 1>/tmp/resize_disk.log 2>&1) || :
	ROOT_DEVICE=$(blkid --label root)
	mkdir -p /volumes/toplevel /nvram
	# Mount top level subvolume, so all volumes we create go under it
	mount -t btrfs -o subvolid=5 "${ROOT_DEVICE}" "/volumes/toplevel"
	if (grep -q "nvramvol=" /proc/cmdline); then
		NVRAM_SUBVOL_ID=$(sed -rn 's/.+nvramvol=([[:digit:]]+)/\1/p' /proc/cmdline)
		echo "Mounting existing nvram subvol ${NVRAM_SUBVOL_ID}"
		mount -t btrfs -o "subvolid=${NVRAM_SUBVOL_ID}" "${ROOT_DEVICE}" "/nvram"
	else
		# Ensure we mount the top-level subvolume (if it exists)
		# When creating, we will create under /volumes
		if !(mount -t btrfs -o subvol=@nvram "${ROOT_DEVICE}" "/nvram" 1>/dev/null 2>&1); then
			btrfs subvolume create /volumes/toplevel/@nvram
			cp -r /nvram /tmp/nvram_default
			mount -t btrfs -o subvol=@nvram "${ROOT_DEVICE}" "/nvram"
			cp -r /tmp/nvram_default/* /nvram
			rm -rf /tmp/nvram_default
		fi
	fi
	if !(mount -t btrfs -o subvol=@rdklogs "${ROOT_DEVICE}" "/rdklogs" 1>/dev/null 2>&1); then
		btrfs subvolume create /volumes/toplevel/@rdklogs
		mount -t btrfs -o subvol=@rdklogs "${ROOT_DEVICE}" "/rdklogs"
	fi
	mkdir -p "/rdklogs/logs2"
fi
