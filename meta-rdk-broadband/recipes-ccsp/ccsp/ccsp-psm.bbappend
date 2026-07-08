require ccsp_common_genericarm.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://bbhm_def_cfg_ten64.xml \
                   file://bbhm_def_cfg_rpi.xml \
                   file://bbhm_def_cfg_nxp.xml \
                   file://bbhm_def_cfg_qemu.xml \
"

do_install:append() {
    # Config files and scripts
    install -d ${D}/usr/ccsp/config
    install -m 755 ${S}/scripts/bbhm_patch.sh ${D}/usr/ccsp/psm/bbhm_patch.sh
}

do_install_append_raspberrypi64-rdk-broadband() {
    install -m 644 ${WORKDIR}/bbhm_def_cfg_rpi.xml ${D}/usr/ccsp/config/bbhm_def_cfg.xml
}

do_install_append_armefi64-rdk-broadband() {
    install -m 644 ${WORKDIR}/bbhm_def_cfg_nxp.xml ${D}/usr/ccsp/config/bbhm_def_cfg.xml
}

do_install_append_armefi64-qemu-broadband() {
    install -m 644 ${WORKDIR}/bbhm_def_cfg_qemu.xml ${D}/usr/ccsp/config/bbhm_def_cfg.xml
}
