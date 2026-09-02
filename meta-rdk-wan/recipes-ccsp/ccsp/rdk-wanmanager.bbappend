RDEPENDS:rdk-wanmanager:append = " ndisc6-rdisc6"
CFLAGS:append = " -D_PLATFORM_RASPBERRYPI_ -D_PLATFORM_GENERICARM_"

# 2026-03-03: Override version due to build failure with v2.15
SRC_URI="git://github.com/rdkcentral/wan-manager.git;branch=releases/2.14.0-main;protocol=https;name=WanManager;tag=v2.14.0"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = "\
    file://0001-wanmgr_interface_sm-place-wan_started-file-under-var.patch \
    file://0002-wanmgr_interface_sm-send-current-wan-ifname-to-sysev.patch \
"
