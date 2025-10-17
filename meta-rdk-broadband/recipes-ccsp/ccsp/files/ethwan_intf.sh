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

# ASIX USB 3.0 devices are disabled from loading at boot
# to prevent issues with some devices that are in CDC-NCM
# mode
modprobe ax88179_178a

MACHINE_NAME=$(strings "/proc/device-tree/compatible" | head -n 1)
if [ "${MACHINE_NAME}" = "raspberrypi,4-model-b" ] || [ "${MACHINE_NAME}" = "raspberrypi,4-compute-module" ]; then
	# Make the built-in MAC the WAN side, and the first external
	# MAC (USB or PCI) the LAN side
	
	BUILT_IN_ETH_PATH=$(find /sys/devices/platform/scb/fd580000.ethernet/net/ -type d -mindepth 1 -maxdepth 1)
	BUILT_IN_ETH_NAME=$(basename "${BUILT_IN_ETH_PATH}")

	ip link set "${BUILT_IN_ETH_NAME}" down
	ip link set dev "${BUILT_IN_ETH_NAME}" name wan0

	# The external Ethernet should be on eth1,
	# rename it here. 
	if [ -d "/sys/class/net/eth1" ]; then
		ip link set eth1 down
		ip link set dev eth1 name eth0
		ip link set eth0 up
	fi

	# Reset the WAN interface name to eth6
	# (emulates Ten64 in the config)
	ip link set dev wan0 name eth6
	ip link set dev eth6 up
elif [ "${MACHINE_NAME}" = "traverse,ten64-4" ]; then
	# Rename eth3 as eth6 (WAN)
	ip link set eth3 down
	ip link set dev eth3 name eth6
	ip link set eth6 up

	# Rename the SFP ports same as a full
	# Ten64 unit
	ip link set eth4 down
	ip link set dev eth4 name eth8
	ip link set eth8 up

	ip link set eth5 down
	ip link set dev eth5 name eth9
	ip link set eth9 up
elif [ "${MACHINE_NAME}" != "traverse,ten64" ]; then
	# Emulate a Ten64
	if [ -d "/sys/class/net/eth1" ]; then
		ip link set eth1 down
		ip link set dev eth1 name eth6
	fi
	if [ -d "/sys/class/net/eth2" ]; then
		ip link set eth2 down
		ip link set dev eth2 name eth8
	fi
else
	logger "[ethwan_intf.sh] Unknown machine: ${MACHINE_NAME}"
fi

if [ -d "/sys/class/net/eth6" ]; then
	ip link set eth6 up
fi
if [ -d "/sys/class/net/eth8" ]; then
	ip link set eth8 up
fi
