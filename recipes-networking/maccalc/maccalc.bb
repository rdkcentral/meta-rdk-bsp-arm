SUMMARY = "Simple command line MAC address manipulation utility"
HOMEPAGE = "https://github.com/openwrt/packages/tree/master/net/maccalc"
FILESEXTRAPATHS:prepend = "${THISDIR}/src:"

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://main.c;beginline=1;endline=10;md5=fcba3a702502ffd0325e790c1a7b5782"

# The "upstream" is the OpenWrt packages feed
# https://github.com/openwrt/packages/tree/master/net/maccalc
SRC_URI = "file://Makefile \
           file://main.c \
           "

S = "${WORKDIR}"

TARGET_CC_ARCH += "${LDFLAGS}"

do_compile () {
	oe_runmake 'CC=${CC}'
}

do_install () {
	install -d ${D}${bindir}
	install -m 0755 ${WORKDIR}/maccalc ${D}${bindir}
}

