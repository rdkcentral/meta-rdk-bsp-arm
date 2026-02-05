require ccsp_common_genericarm.inc
CFLAGS:aarch64:append = " -Werror=format-truncation=1 -g"
CFLAGS:remove = "-D_PLATFORM_RASPBERRYPI_"

FILESEXTRAPATHS:prepend := "${THISDIR}/ccsp-eth-agent:"

SRC_URI:remove = "${CMF_GITHUB_ROOT}/ethernet-agent;protocol=https;nobranch=1"
SRC_URI = "git://github.com/rdkcentral/ethernet-agent.git;protocol=https;branch=develop"
SRCREV_pn-ccsp-eth-agent = "e350f19aa5c0802c35ec520d9e1484b0033fc250"

SRC_URI:append = "\
    file://0001-genericarm-increase-maximum-number-of-Ethernet-interfaces.patch \
    file://bring_up_all_eth.sh \
    "

do_install:append() {
   install -d ${D}/lib/rdk/
   install -m 755 ${WORKDIR}/bring_up_all_eth.sh ${D}/lib/rdk/
}

FILES:${PN}:append = " /lib/rdk/bring_up_all_eth.sh"