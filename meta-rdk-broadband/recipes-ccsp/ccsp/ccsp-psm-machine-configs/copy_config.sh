#!/bin/sh
##################################################################################
# If not stated otherwise in this file or this component's LICENSE file the
# following copyright and licenses apply:
#
#  Copyright 2026 RDK Management
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
if [ -f "/sys/firmware/devicetree/base/compatible" ]; then
    MACHINE_NAME=$(strings /sys/firmware/devicetree/base/compatible | head -n 1 | sed "s/,/_/g")
else
    DMI_VENDOR_ID=$(cat "/sys/class/dmi/id/board_vendor")
    DMI_BOARD_NAME=$(cat "/sys/class/dmi/id/board_name")
    MACHINE_NAME="${DMI_VENDOR_ID}_${DMI_BOARD_NAME}"
fi

MACHINE_CONFIG_FILE="/usr/ccsp/machine_configs/${MACHINE_NAME}.xml"
DEFAULT_CONFIG_FILE="/usr/ccsp/config/bbhm_def_cfg.xml"

if [ -f "${DEFAULT_CONFIG_FILE}" ]; then
    echo "Default config file in place"
    exit 0
fi

# /usr/ccsp/config will not be writable on a read-only
# rootfs, so mount a tmpfs on top
mount -t tmpfs -o mode=0755 tmpfs /usr/ccsp/config

if [ -f "${MACHINE_CONFIG_FILE}" ]; then
    echo "Copying machine specific config file"
    echo "Source: ${MACHINE_CONFIG_FILE}"
    echo "Destination: ${DEFAULT_CONFIG_FILE}"
    cp "${MACHINE_CONFIG_FILE}" "${DEFAULT_CONFIG_FILE}"
else
    echo "No machine specific config file found, copying default"
    cp "/usr/ccsp/machine_configs/default.xml" "${DEFAULT_CONFIG_FILE}"
fi

