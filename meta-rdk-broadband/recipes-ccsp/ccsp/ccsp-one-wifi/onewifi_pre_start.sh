#!/bin/sh

#!/bin/sh

handle_mt7990() {
	echo "We have a MT7990 card"
	if ! (grep -q mt7996e /proc/modules); then
		modprobe mt7996e
	fi

	while [ ! -d /sys/class/ieee80211/phy0 ]; do
		sleep 1
	done
	# TODO: Should we teardown any existing wifi radios?
	if [ ! -d /sys/class/net/wifi0 ]; then
		iw phy phy0 interface add wifi0 type __ap radios 0
	fi
	WIFI0_MACADDR=$(cat /sys/class/net/wifi0/address)
	if [ ! -d /sys/class/net/wifi1 ]; then
		iw phy phy0 interface add wifi1 type __ap  radios 1
		WIFI1_MACADDR=$(maccalc add "${WIFI0_MACADDR}" 1)
		ip link set address "${WIFI1_MACADDR}" dev wifi1
	fi
	#if [ ! -d /sys/class/net/mld0 ]; then
	#	iw phy phy0 interface add mld0 type __ap radios all
	#	MLD0_MACADDR=$(maccalc add "${WIFI0_MACADDR}" 2)
	#	ip link set address "${MLD0_MACADDR}" dev mld
	#fi
	if [ ! -f "/nvram/InterfaceMap.json" ]; then
		echo "Copying InterfaceMap for MT7990 dual band"
		cp /usr/ccsp/wifi/InterfaceMap_mt7990.json /nvram/InterfaceMap.json
	fi
	echo "MT7990 setup complete"
}

handle_other() {
	modprobe mt7915e

	if [ -d "/sys/class/ieee80211/phy0" ] && [ ! -d "/sys/class/net/wlan0" ]; then
		iw phy0 interface add wlan0 type managed
	fi

	if [ -d "/sys/class/ieee80211/phy1" ] && [ ! -d "/sys/class/net/wlan1" ]; then
		iw phy1 interface add wlan1 type managed
	fi

}

HAS_MT7990=$(lspci -d 14c3:7993 | wc -l)

if [ "${HAS_MT7990}" = "1" ]; then
	handle_mt7990
else
	handle_other
fi

if [ ! -f "/nvram/wifi_defaults.txt" ]; then
        cp /usr/ccsp/wifi/wifi_defaults.txt /nvram/
fi



