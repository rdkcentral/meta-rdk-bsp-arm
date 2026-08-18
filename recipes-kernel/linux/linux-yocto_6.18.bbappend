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
    file://0003-wifi-mt76-relicense-to-BSD-3-Clause-Clear.patch \
    file://0004-wifi-mt76-add-external-EEPROM-support-for-mt799x-chi.patch \
    file://0005-wifi-mt76-mt7996-add-variant-for-MT7992-chipsets.patch \
    file://0006-wifi-mt76-mt7996-apply-calibration-free-data-from-OT.patch \
    file://0007-mac80211-Allow-IBSS-mode-and-different-beacon-interv.patch \
"

