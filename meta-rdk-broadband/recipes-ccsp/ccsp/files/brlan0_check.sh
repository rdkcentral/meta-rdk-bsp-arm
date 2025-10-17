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
sleep 30
### Temp fix for brlan0 issue

while [ 1 ]
	do
	LanMode=`dmcli eRT getv Device.X_CISCO_COM_DeviceControl.LanManagementEntry.1.LanMode | grep value | cut -d ':' -f3 | cut -d ' ' -f2 | tr -d '\n'`
	if [ "$LanMode" = "router" ]; then
		num_intfs_in_bridge=$(find /sys/class/net/brlan0/ -name 'lower_eth*' | wc -l)
		if [ "${num_intfs_in_bridge}" = "0" ] && [ -f "/tmp/utopia-lan-started" ] && [ ! -f "/tmp/utopia-ipv4-4-up" ]; then
			logger "brlan0 not operational, fixing"
			/etc/utopia/service.d/lan_handler.sh ipv4_4-status up
		fi
	fi
	sleep 10
done