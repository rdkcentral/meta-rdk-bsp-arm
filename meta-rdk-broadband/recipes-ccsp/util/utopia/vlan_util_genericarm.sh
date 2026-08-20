#!/bin/sh
echo "Multinet vlan util called with arguments: $*" >> /tmp/vlan_util.log
# This event will be invoked by CcspEthAgent, which writes the Members.Eth
# PSM property just before sending this event
if [ "$1" = "multinet-syncMembers" ] && [ "$2" = "1" ]; then
	PSM_BRIDGE_MEMBERS=$(psmcli get "dmsb.l2net.1.Members.Eth")
	CURRENT_MEMBERS=$(find /sys/class/net/brlan0/ -name 'lower_*' -exec basename {} \; | cut -c 7- | tr '\n' ' ')
	echo "PSM_BRIDGE_MEMBERS=${PSM_BRIDGE_MEMBERS}" >> /tmp/vlan_util.log
	echo "CURRENT_MEMBERS=${CURRENT_MEMBERS}" >> /tmp/vlan_util.log
	for intf in $CURRENT_MEMBERS; do
		# wifi interfaces are managed by OneWifi, ignore them here
		if (grep -q "DEVTYPE=wlan" "/sys/class/net/${intf}/uevent"); then
			continue
		fi

		if !(echo "${PSM_BRIDGE_MEMBERS}" | grep -q "${intf}"); then
			echo "Interface ${intf} needs to be removed from brlan0" >> /tmp/vlan_util.log
			brctl delif brlan0 "${x}"
		fi
	done
	for x in $PSM_BRIDGE_MEMBERS; do
		if [ ! -d "/sys/class/net/${x}" ]; then
			echo "Interface ${x} does not exist, ignoring" >> /tmp/vlan_util.log
			continue
		fi

		if [ ! -d "/sys/class/net/brlan0/lower_${x}" ]; then
			echo "Interface ${x} needs to be added to brlan0" >> /tmp/vlan_util.log
			brctl addif brlan0 "${x}"
		fi
	done
fi
