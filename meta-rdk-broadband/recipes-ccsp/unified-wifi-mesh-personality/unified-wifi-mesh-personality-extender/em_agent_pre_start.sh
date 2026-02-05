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

#Ensure onewifi is up and running
#while [ ! -e /tmp/wifi_initialized ] && [ ! -e /tmp/wifi_dml_complete ] ; 
#do   
#   sleep 1; 
#done

#Ensure backhaul connectivity is established
al_mac_addr=`cat /nvram/EasymeshCfg.json | grep AL_MAC_ADDR  | cut -d '"' -f4`
channel_exists=`iw dev | grep $al_mac_addr  -A 4 | grep channel | wc -l`
ssid_exists=`iw dev | grep $al_mac_addr -A 4 | grep ssid | wc -l`

while [ "$channel_exists" != 1 ] && [ "$ssid_exists" != 1 ] ;
do
  sleep 1;
  channel_exists=`iw dev | grep $al_mac_addr  -A 4 | grep channel | wc -l`
  ssid_exists=`iw dev | grep $al_mac_addr -A 4 | grep ssid | wc -l`
done

if [ ! -d "/sys/class/net/brlan0" ]; then
  brctl addbr brlan0
  brctl addif brlan0 wifi1.3
  ifconfig brlan0 up
fi

#Run udhcpc to get ipaddr of brlan0 interface for connected clients internet connectivity
brlan0_ip_addr=`ifconfig brlan0 | grep "inet addr:" | cut -d ':' -f2 | cut -d ' ' -f1 | wc -l`
if [ "$brlan0_ip_addr" = 0 ]; then
udhcpc -i  brlan0 -q
fi
