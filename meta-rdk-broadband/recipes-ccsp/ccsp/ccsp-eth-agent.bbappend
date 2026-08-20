require ccsp_common_genericarm.inc
CFLAGS:aarch64:append = " -Werror=format-truncation=1 -g"
CFLAGS:remove = "-D_PLATFORM_RASPBERRYPI_"

FILESEXTRAPATHS:prepend := "${THISDIR}/ccsp-eth-agent:"

SRC_URI:remove = "${CMF_GITHUB_ROOT}/ethernet-agent;protocol=https;nobranch=1"
SRC_URI = "git://github.com/rdkcentral/ethernet-agent.git;protocol=https;branch=develop"
SRCREV_pn-ccsp-eth-agent = "e350f19aa5c0802c35ec520d9e1484b0033fc250"

SRC_URI:append = "\
    file://0001-genericarm-increase-maximum-number-of-Ethernet-interfaces.patch \
    "

# Missing from meta-rdk-broadband
# TODO: Submit upstream pull request
CFLAGS:append  = " ${@bb.utils.contains('DISTRO_FEATURES', 'rdkb_auto_port_switch', ' -DFEATURE_RDKB_AUTO_PORT_SWITCH', '', d)}"

# For systemd notifications

CFLAGS:append = " -DUSE_SYSTEMD_NOTIFICATIONS"
DEPENDS:append = " systemd"
LDFLAGS:append = " -lsystemd"

SRC_URI:append = " \
    file://0003-Send-READY-notification-to-systemd-when-data-model-ready.patch \
    file://0004-main-do-not-background-fork-when-systemd-notification.patch \
"

# WIP to manage brlan0 members from TR-181 / PSM instead of syscfg
SRC_URI:append = " \
    file://0005-WIP-use-AddPortToLanBridge-to-manage-brlan0-members.patch \
"
