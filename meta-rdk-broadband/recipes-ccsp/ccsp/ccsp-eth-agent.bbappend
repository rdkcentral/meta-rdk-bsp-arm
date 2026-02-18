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
    "

