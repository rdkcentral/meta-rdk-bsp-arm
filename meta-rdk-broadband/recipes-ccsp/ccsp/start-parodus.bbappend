require ccsp_common_genericarm.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://0001-start_parodus-align-generic-ARM-platform-with-other-.patch"

CFLAGS:remove = "-DPLATFORM_RASPBERRYPI"
