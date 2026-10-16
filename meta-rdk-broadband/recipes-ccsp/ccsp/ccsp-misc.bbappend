require ccsp_common_genericarm.inc

CFLAGS += " -DDHCPV4_CLIENT_UDHCPC -DDHCPV6_CLIENT_DIBBLER -DUDHCPC_RUN_IN_BACKGROUND "

LDFLAGS:append:aarch64 = " -lutctx"

FILESEXTRAPATHS:prepend := "${THISDIR}/ccsp-misc:"

SRC_URI:append = " \
    file://0001-Add-_PLATFORM_GENERICARM_-for-generic-Arm-reference-.patch \
"
