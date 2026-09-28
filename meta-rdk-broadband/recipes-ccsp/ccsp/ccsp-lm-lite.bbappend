require ccsp_common_genericarm.inc

LDFLAGS:append = " -Wl,--no-as-needed"

FILESEXTRAPATHS:prepend := "${THISDIR}/ccsp-lm-lite:"

SRC_URI:append = " \
    file://0001-Remove-PLATFORM_TURRIS-flags.patch \
"
