#!/bin/sh
##################################################################################
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

# Bring up all Ethernet interfaces before EthAgent starts
for x in $(find /sys/class/net -name 'eth*'); do
    # Ignore any interface that is not originating from
    # a "real" device (for example, no veth pairs)
    if [ ! -d "${x}/device" ]; then
        continue
    fi
    eth_intf_name=$(basename "${x}")
    echo "Bringing ${eth_intf_name} up"
    ip link set "${eth_intf_name}" up
done
