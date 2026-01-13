FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI += " \
   file://nc.cfg \
   "

SRC_URI:remove = "file://enable_ps_wide.cfg"
SRC_URI:append:broadband = " file://rdk-b.cfg"

do_install:append() {
        rm ${D}${sysconfdir}/syslog.conf
        ln -s -r ${D}${base_bindir}/busybox ${D}${base_bindir}/timeout
}

FILES:${PN}-syslog:remove = "${sysconfdir}/syslog.conf"
