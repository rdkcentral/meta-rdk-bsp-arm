CFLAGS:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'webconfig_bin', '-D_PLATFORM_GENERICARM_', '', d)}"

FILESEXTRAPATHS:prepend := "${THISDIR}/cpeabs:"

SRC_URI:append = " \
    file://0001-Remove-RDKB_EMU-flag.patch \
"
