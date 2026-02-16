require ccsp_common_genericarm.inc

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

EXTRA_OECONF += "PHP_RPATH=no"

SRC_URI += "${CMF_GIT_ROOT}/rdkb/devices/raspberrypi/sysint;protocol=${CMF_GIT_PROTOCOL};branch=${CMF_GIT_BRANCH};destsuffix=git/devices;name=webuijst"
SRCREV_webuijst = "${AUTOREV}"
SRC_URI_append = " \
    file://CcspWebUI.sh \
    file://CcspWebUI.service \
"

inherit systemd

do_install_append () {
    install -d ${D}${sysconfdir}
    install -d ${D}${base_libdir}/rdk/
    install -d ${D}${systemd_unitdir}/system/

    install -m 755 ${WORKDIR}/CcspWebUI.sh ${D}${base_libdir}/rdk/
    install -m 644 ${WORKDIR}/CcspWebUI.service ${D}${systemd_unitdir}/system/
}

SYSTEMD_SERVICE_${PN} += "CcspWebUI.service"
SYSTEMD_AUTO_ENABLE_${PN} = "enable"

FILES_${PN} += " \
    ${systemd_unitdir}/system/CcspWebUI.service \
    ${base_libdir}/rdk/* \
"
