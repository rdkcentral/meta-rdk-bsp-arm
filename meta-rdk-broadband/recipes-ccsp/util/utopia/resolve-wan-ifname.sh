#!/bin/sh
#
# Point Utopia WAN interface names at the interface this board
# actually uses, taken from PSM (dmsb.wanmanager.if.1.Name).
#

DEFAULT_WAN_IFNAME="eth1"
MACHINE_CONFIG_DIR="/usr/ccsp/machine_configs"
PSM_RECORD="dmsb.wanmanager.if.1.Name"

# board specific PSM config, selected the same way copy_config.sh does.
machine=""
if [ -f /sys/firmware/devicetree/base/compatible ]; then
    machine=$(strings /sys/firmware/devicetree/base/compatible | head -n 1 | tr ',' '_')
elif [ -r /sys/class/dmi/id/board_vendor ] && [ -r /sys/class/dmi/id/board_name ]; then
    board_vendor="$(cat /sys/class/dmi/id/board_vendor)"
    board_name="$(cat /sys/class/dmi/id/board_name)"
    machine="${board_vendor}_${board_name}"
fi

machine_cfg="${MACHINE_CONFIG_DIR}/default.xml"
if [ -n "${machine}" ] && [ -f "${MACHINE_CONFIG_DIR}/${machine}.xml" ]; then
    machine_cfg="${MACHINE_CONFIG_DIR}/${machine}.xml"
fi

# get interface resolved by WAN Manager
wan_ifname="$(sysevent get current_wan_ifname 2> /dev/null)"

# else, get interface from PSM config
for cfg in /nvram/bbhm_cur_cfg.xml /usr/ccsp/config/bbhm_def_cfg.xml "${machine_cfg}"; do
    [ -n "${wan_ifname}" ] && break
    [ -f "${cfg}" ] || continue
    wan_ifname=$(sed -n "s|.*<Record name=\"${PSM_RECORD}\"[^>]*>\([^<]*\)</Record>.*|\1|p" "${cfg}" | head -n 1)
done

# reject invalid interface name
case "${wan_ifname}" in
'' | *[!A-Za-z0-9._-]*)
    wan_ifname="${DEFAULT_WAN_IFNAME}"
    ;;
esac

# update sysevent value
sysevent set wan_ifname "${wan_ifname}"

# update syscfg value
syscfg_changed=0

for key in wan_physical_ifname ecm_wan_ifname cosa_usgv2_rip00::If1Name tr_Neighdisc_If_interface; do
    if [ "$(syscfg get "${key}")" != "${wan_ifname}" ]; then
        syscfg set "${key}" "${wan_ifname}"
        syscfg_changed=1
    fi
done

if [ "${syscfg_changed}" = "1" ]; then
    syscfg commit
fi

echo "[utopia] WAN interface name resolved to ${wan_ifname}"
