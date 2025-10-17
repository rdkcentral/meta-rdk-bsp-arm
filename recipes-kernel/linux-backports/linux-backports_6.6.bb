#
# SPDX-License-Identifier: MIT
#
# Based on linux-backports-5.10.bb from TanoWrt:
# This file Copyright (C) 2020-2021 Tano Systems LLC
# Anton Kikin <a.kikin@tano-systems.com>
#
require linux-backports.inc

KV = "6.6.15"
PV = "${KV}"
PR = "rdkbarm.${INC_PR}"

FILESEXTRAPATHS:prepend = "${THISDIR}/${PN}_6.6/files:"
FILESEXTRAPATHS:prepend = "${THISDIR}/${PN}_6.6/configs:"
FILESEXTRAPATHS:prepend = "${THISDIR}/${PN}_6.6/patches:"

SRC_URI += "http://mirror2.openwrt.org/sources/backports-${KV}.tar.xz"
SRC_URI[sha256sum] = "3bbc461121134fda9089c084a5eed577d05e7837a157edf9a3797937172a3ece"

S = "${WORKDIR}/backports-${PV}"

# The mac80211 backport can provide WiFi drivers
# for several vendors like QCA and MTK.
# For each vendor, create a virtual package
# so other sources (like the vendor themselves)
# can override.
PROVIDES = "virtual/wifi-vendor-mtk"
RPROVIDES:${PN} = "virtual/wifi-vendor-mtk"

SRC_URI += "\
    file://openwrt-mac80211-build-subdir.patch \
    file://openwrt-mac80211-subsys-subdir.patch \
    file://mt76-fix-page_pool-helper-include-for-kernel-6.6.patch \
"
