require ccsp_common_genericarm.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://bbhm_def_cfg_ten64.xml \
    file://bbhm_def_cfg_default.xml \
    file://copy_config.sh"

do_install:append() {
    # Config files and scripts
    install -d ${D}/usr/ccsp/config
    install -d ${D}/usr/ccsp/machine_configs
    cp ${WORKDIR}/bbhm_def_cfg_ten64.xml ${D}/usr/ccsp/machine_configs/traverse_ten64.xml
    cp ${WORKDIR}/bbhm_def_cfg_default.xml ${D}/usr/ccsp/machine_configs/default.xml

    install -m 755 ${WORKDIR}/copy_config.sh ${D}/usr/ccsp/psm/copy_config.sh
}

FILES:${PN}:append = " /usr/ccsp/config \
    /usr/ccsp/machine_configs \
    /usr/ccsp/machine_configs/traverse_ten64.xml \
    /usr/ccsp/machine_configs/default.xml"
