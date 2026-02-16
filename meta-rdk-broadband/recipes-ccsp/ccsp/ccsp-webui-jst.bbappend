require ccsp_common_genericarm.inc

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

EXTRA_OECONF:append = "PHP_RPATH=no"

SRC_URI += "${CMF_GIT_ROOT}/rdkb/devices/raspberrypi/sysint;protocol=${CMF_GIT_PROTOCOL};branch=${CMF_GIT_BRANCH};destsuffix=git/devices;name=webuijst"
SRCREV_webuijst = "${AUTOREV}"
SRC_URI_append = " \
    file://CcspWebUI.sh \
    file://CcspWebUI.service \
"

inherit systemd

do_install:append () {
    install -d ${D}${sysconfdir}
    install -d ${D}${base_libdir}/rdk/
    install -d ${D}${systemd_unitdir}/system/

    install -m 755 ${WORKDIR}/CcspWebUI.sh ${D}${base_libdir}/rdk/
    install -m 644 ${WORKDIR}/CcspWebUI.service ${D}${systemd_unitdir}/system/
}


SYSTEMD_SERVICE:${PN}:append = "CcspWebUI.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

FILES:${PN}:append = " \
    ${systemd_unitdir}/system/CcspWebUI.service \
    ${base_libdir}/rdk/* \
"
