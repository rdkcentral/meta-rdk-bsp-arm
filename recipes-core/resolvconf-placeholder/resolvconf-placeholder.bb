LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${WORKDIR}/resolv.placeholder.conf;md5=86e080a713972dcdd0caa9d622324134"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = " file://resolv.placeholder.conf"

do_install () {
	install -d ${D}${sysconfdir}
	install -m 0644 ${WORKDIR}/resolv.placeholder.conf ${D}${sysconfdir}/resolv.conf
}

FILES:${PN} = "/etc/resolv.conf"
