#!/bin/sh
##################################################################################
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

#mysql database - inserting default values in db
if [ ! -e "/nvram/mysql_db_data_exists" ]; then
sleep 5
br_mac="$(cat /sys/class/net/brlan0/address)"
al_mac="$(cat /sys/class/net/eth0_virt_peer/address)"
old_al_mac_addr=`cat /nvram/EasymeshCfg.json | grep AL_MAC_ADDR  | cut -d '"' -f4`
if [ "$old_al_mac_addr" == "00:00:00:00:00:00" ]; then
  sed -i "s/$old_al_mac_addr/$al_mac/g" /nvram/EasymeshCfg.json
fi
#password is not sensitive,used to add default values in mariadb
mysql -u bpi --password="root" -e "use OneWifiMesh; INSERT INTO NetworkSSIDList (ID,SSID,PassPhrase,Band,Enable,AKMsAllowed,SuiteSelector,AdvertisementEnabled,MFPConfig,MobilityDomain,HaulType)  values ('Fronthaul@OneWifiMesh','private_ssid','test-fronthaul','2.4,5,6',1,'dpp','00010203',1,'Optional','00:01:02:03:04:05','Fronthaul'),('IoT@OneWifiMesh','iot_ssid','test-backhaul','2.4,5,6',1,'dpp,sae,SuiteSelector','00010203',1,'Required','00:01:02:03:04:05','IoT'),('Configurator@OneWifiMesh','lnf_radius','test-backhaul','2.4,5,6',1,'dpp,sae,SuiteSelector','00010203',1,'Required','00:01:02:03:04:05','Configurator'),('Backhaul@OneWifiMesh','mesh_backhaul','test-backhaul','2.4,5,6',1,'dpp,sae,SuiteSelector','00010203',1,'Required','00:01:02:03:04:05','Backhaul'),('Hotspot@OneWifiMesh','Hotspot','test-Hotspot','2.4,5,6',1,'dpp,sae,SuiteSelector','00010203',1,'Required','00:01:02:03:04:05','Hotspot'); INSERT INTO NetworkList (ID,ControllerID,ColocatedAgentID,Media)  values ('OneWifiMesh','$br_mac','$al_mac',0);"
touch /nvram/mysql_db_data_exists
fi
