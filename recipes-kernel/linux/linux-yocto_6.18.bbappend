ARMFILESPATHS := "${THISDIR}/linux-yocto-6.18:"
FILESEXTRAPATHS:prepend:armefi64 = "${ARMFILESPATHS}"

SRC_URI:append:armefi64 = " \
    file://defconfig \
    file://an7581.cfg \
    file://qemu.cfg \
    file://rpi.cfg \
"

COMPATIBLE_MACHINE:armefi64 = "armefi64"
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = "\
    file://0001-mac80211-import-130-disable_auto_vif.patch-from-owrt.patch \
    file://0002-wifi-mt76-transform-aspm_conf-for-pci_disable_link_s.patch \
"

