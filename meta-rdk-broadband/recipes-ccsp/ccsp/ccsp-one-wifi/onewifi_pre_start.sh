#!/bin/sh

modprobe mt7915e

if [ -d "/sys/class/ieee80211/phy0" ] && [ ! -d "/sys/class/net/wlan0" ]; then
        iw phy0 interface add wlan0 type managed
fi

if [ -d "/sys/class/ieee80211/phy1" ] && [ ! -d "/sys/class/net/wlan1" ]; then
        iw phy1 interface add wlan1 type managed
fi

if [ ! -f "/nvram/wifi_defaults.txt" ]; then
        cp /usr/ccsp/wifi/wifi_defaults.txt /nvram/
fi
