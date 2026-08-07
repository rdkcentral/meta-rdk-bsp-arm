#!/bin/sh
echo "Multinet vlan util called with arguments: $*" >> /tmp/vlan_util.log
# This event will be invoked by CcspEthAgent, which writes the Members.Eth
# PSM property just before sending this event
if [ "$1" = "multinet-syncMembers" ] && [ "$2" = "1" ]; then
	PSM_BRIDGE_MEMBERS=$(psmcli get "dmsb.l2net.1.Members.Eth")
	for x in $PSM_BRIDGE_MEMBERS; do
		if [ ! -d "/sys/class/net/brlan0/lower_${x}" ]; then
			brctl addif brlan0 "${x}"
                fi
        done
fi
