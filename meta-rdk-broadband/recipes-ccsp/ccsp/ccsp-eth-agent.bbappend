require ccsp_common_genericarm.inc
CFLAGS:aarch64:append = " -Werror=format-truncation=1 -g"
CFLAGS:remove = "-D_PLATFORM_RASPBERRYPI_"

FILESEXTRAPATHS:prepend := "${THISDIR}/ccsp-eth-agent:"

SRC_URI:remove = "${CMF_GITHUB_ROOT}/ethernet-agent;protocol=https;nobranch=1"
SRC_URI = "git://github.com/rdkcentral/ethernet-agent.git;protocol=https;branch=develop"
SRCREV_pn-ccsp-eth-agent = "3a0058c9699a15f9190fbdc02e411c9a541294f5"

SRC_URI:append = "\
    file://0001-genericarm-increase-maximum-number-of-Ethernet-interfaces.patch \
    file://0002-cosa_ethernet_internal-force-CcspHalEthSw_RegisterLink.patch \
    file://bring_up_all_eth.sh \
    "

# Missing from meta-rdk-broadband
# TODO: Submit upstream pull request
CFLAGS:append  = " ${@bb.utils.contains('DISTRO_FEATURES', 'rdkb_auto_port_switch', ' -DFEATURE_RDKB_AUTO_PORT_SWITCH', '', d)}"

FILES:${PN}:append = " /lib/rdk/bring_up_all_eth.sh"

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

do_install:append() {
   install -d ${D}/lib/rdk/
   install -m 755 ${WORKDIR}/bring_up_all_eth.sh ${D}/lib/rdk/
}