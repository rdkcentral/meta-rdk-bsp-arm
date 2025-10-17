FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
    file://lighttpd.conf.video \
    file://lighttpd_php.conf.broadband \
    file://lighttpd_jst.conf.broadband \
"

# Fixme: the meta-rdk .bbappend files do this already for broadband builds.
# RPi builds for video apparently need it too? If not, this should be removed.
CFLAGS_append = " -DSO_BINDTODEVICE"

SYSTEMD_SERVICE_${PN} += "lighttpd.service"

LIGHTTPDCONF = "lighttpd.conf.video"

# Warning: the _broadband over-ride is currently enabled on a machine specific
# basis (ie it's defined by the raspberrypi-rdk-broadband.conf,
# qemuarmbroadband.conf, etc machine configs). In the short term, external BSP
# layers etc which target RDK-B will need to enable it in their machine configs
# too (as a longer term solution, the over-ride should be enabled automatically
# for all RDK-B targets by an RDK-B specific distro config etc).


do_install_append() {
    install -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/${LIGHTTPDCONF} ${D}${sysconfdir}/lighttpd.conf
}

do_install_append_broadband() {
    if [ "${@bb.utils.contains("DISTRO_FEATURES", "webui_jst", "yes", "no", d)}" = "yes" ]; then
	install -m 0644 ${WORKDIR}/lighttpd_jst.conf.broadband ${D}${sysconfdir}/lighttpd.conf
    else	
	install -m 0644 ${WORKDIR}/lighttpd_php.conf.broadband ${D}${sysconfdir}/lighttpd.conf
    fi

}

RDEPENDS_${PN}_append = " \
    lighttpd-module-fastcgi \
    lighttpd-module-proxy \
    "
