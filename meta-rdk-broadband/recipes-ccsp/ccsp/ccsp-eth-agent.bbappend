require ccsp_common_genericarm.inc
CFLAGS:aarch64:append = " -Werror=format-truncation=1 -g"
CFLAGS:remove = "-D_PLATFORM_RASPBERRYPI_"

FILESEXTRAPATHS:prepend := "${THISDIR}/ccsp-eth-agent:"

SRC_URI:append = "\
    file://0001-genericarm-increase-maximum-number-of-Ethernet-interfaces.patch \
    file://0002-cosa_ethernet_internal-force-CcspHalEthSw_RegisterLink.patch \
    "

# For systemd notifications

CFLAGS:append = " -DUSE_SYSTEMD_NOTIFICATIONS"
DEPENDS:append = " systemd"
LDFLAGS:append = " -lsystemd"

SRC_URI:append = " \
    file://0003-Send-READY-notification-to-systemd-when-data-model-ready.patch \
    file://0004-main-do-not-background-fork-when-systemd-notification.patch \
"
