require ccsp_common_genericarm.inc
CFLAGS:aarch64:append = " -Werror=format-truncation=1 -g"
CFLAGS:remove = "-D_PLATFORM_RASPBERRYPI_"

FILESEXTRAPATHS:prepend := "${THISDIR}/ccsp-eth-agent:"

# As used with RDK-B 2026.Q3
SRCREV_pn-ccsp-eth-agent = "375b931eb5a41adf9fd4e2ffa1ec760c70f40c15"

SRC_URI:append = "\
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

# WIP to manage brlan0 members from TR-181 / PSM instead of syscfg
SRC_URI:append = " \
    file://0005-WIP-use-AddPortToLanBridge-to-manage-brlan0-members.patch \
"

SRC_URI:append = " \
    file://0006-Remove-PLATFORM_TURRIS-flags.patch \
"

do_install:append() {
   install -d ${D}/lib/rdk/
   install -m 755 ${WORKDIR}/bring_up_all_eth.sh ${D}/lib/rdk/
}
