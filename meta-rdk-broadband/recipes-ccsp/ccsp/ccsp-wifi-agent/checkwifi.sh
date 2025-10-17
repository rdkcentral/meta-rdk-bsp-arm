#!/bin/sh

/usr/ccsp/wifi/onewifi_pre_start.sh

if [ -d "/sys/class/net/wlan0" ] || [ -d "/sys/class/net/wlan1" ]; then
	touch /tmp/wifi_driver_initialized
else
	echo "Wifi driver is not initialized"
fi
