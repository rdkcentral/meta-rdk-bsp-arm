#!/bin/sh
echo "Start EM Ctrl Pre-Setup"

modprobe mt7915e

if [ ! -f "/nvram/wifi_defaults.txt" ]; then
    cp /usr/ccsp/wifi/wifi_defaults.txt /nvram
fi

if [ ! -f "/nvram/InterfaceMap.json" ]; then
    echo "No EasyMesh configuration data in /nvram, doing initial copy"
    cp /usr/ccsp/EasyMesh/nvram/* /nvram/
fi

if [ -d "/sys/class/net/wifi1.3" ]; then
    echo "AP interfaces already exist, not repeating setup"
    exit 0
fi

iw phy phy0 interface add wifi0 type __ap
iw phy phy0 interface add wifi0.1 type __ap
iw phy phy0 interface add wifi0.2 type __ap
iw phy phy1 interface add wifi1 type __ap
iw phy phy1 interface add wifi1.1 type __ap
iw phy phy1 interface add wifi1.2 type __ap
iw phy phy1 interface add wifi1.3 type __ap
#iw phy phy0 interface add wifi2 type __ap

BASE_WIFI_MAC=$(cat /sys/class/net/wifi0/address)
LOCAL_ADMIN_ADDRESS=$(maccalc or "${BASE_WIFI_MAC}" "0a:00:00:00:00:00")

wifi0_1_mac=$(maccalc add "${LOCAL_ADMIN_ADDRESS}" 1)
wifi0_2_mac=$(maccalc add "${LOCAL_ADMIN_ADDRESS}" 2)
wifi1_mac=$(maccalc add "${LOCAL_ADMIN_ADDRESS}" 3)
wifi1_1_mac=$(maccalc add "${LOCAL_ADMIN_ADDRESS}" 4)
wifi1_2_mac=$(maccalc add "${LOCAL_ADMIN_ADDRESS}" 5)
wifi1_3_mac=$(maccalc add "${LOCAL_ADMIN_ADDRESS}" 6)

#Update the mac address using ip link command
ifconfig wifi0 down
ifconfig wifi0.1 down
ifconfig wifi0.2 down
ifconfig wifi1 down
ifconfig wifi1.1 down
ifconfig wifi1.2 down
ifconfig wifi1.3 down
#ifconfig wifi2 down

#ip link set dev wifi0 address $wifi0_mac
ip link set dev wifi0.1 address "$wifi0_1_mac"
ip link set dev wifi0.2 address "$wifi0_2_mac"
ip link set dev wifi1 address "$wifi1_mac"
ip link set dev wifi1.1 address "$wifi1_1_mac"
ip link set dev wifi1.2 address "$wifi1_2_mac"
ip link set dev wifi1.3 address "$wifi1_3_mac"
#ip link set dev wifi2 address $wifi2_mac

ifconfig wifi0 up
ifconfig wifi0.1 up
ifconfig wifi0.2 up
ifconfig wifi1 up
ifconfig wifi1.1 up
ifconfig wifi1.2 up
ifconfig wifi1.3 up
#ifconfig wifi2 up

echo "End EM Ctrl Pre Setup"

exit 0
