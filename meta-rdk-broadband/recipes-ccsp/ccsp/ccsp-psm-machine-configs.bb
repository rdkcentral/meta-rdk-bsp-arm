LICENSE = "Apache-2.0"

# To make the future transition to Yocto Wrynose (6.0) easier
UNPACKDIR:kirkstone = "${WORKDIR}"

LIC_FILES_CHKSUM = "file://${UNPACKDIR}/copy_config.sh;beginline=2;endline=19;md5=1411179664c91eb095a51f46e1a0dcc7"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# There are two ways the default PSM configurations
# can be included
# 1. For the specified machine only (/usr/ccsp/config/bbhm_def_cfg.xml)
#    Machine specific builds like raspberrypi64-rdk-broadband use this
# 2. All machines are included, bbhm_def_cfg.xml
#    is copied at first boot
#    This is called a "universal image" and is activated
#    for the generic build target (armefi64-rdk-broadband)

PACKAGE_ARCH = "${MACHINE_ARCH}"

DEFAULT_BBHM_CONFIG:armefi64-rdk-broadband = "bbhm_def_cfg_default.xml"
DEFAULT_BBHM_CONFIG:raspberrypi64-rdk-broadband = "bbhm_def_cfg_rpi.xml"
# The "RDK" version of the Ten64 has 4 GigE ports, while the full
# retail configuration (8 GigE) uses "bbhm_def_cfg_ten64.xml".
DEFAULT_BBHM_CONFIG:ten64-rdk-broadband = "bbhm_def_cfg_ten64-4.xml"

SRC_URI:append = " \
    file://${DEFAULT_BBHM_CONFIG:armefi64-rdk-broadband} \
    file://${DEFAULT_BBHM_CONFIG:raspberrypi64-rdk-broadband} \
    file://${DEFAULT_BBHM_CONFIG:ten64-rdk-broadband} \
    file://bbhm_def_cfg_ten64.xml \
    file://copy_config.sh \
    file://copy_config_stub.sh \
"

# For machine specific builds
do_install() {
    install -d ${D}/usr/ccsp/psm
    install -m 755 ${UNPACKDIR}/copy_config_stub.sh ${D}/usr/ccsp/psm/copy_config.sh

    install -d ${D}/usr/ccsp/config
    cp ${UNPACKDIR}/${DEFAULT_BBHM_CONFIG} ${D}/usr/ccsp/config/bbhm_def_cfg.xml
}

# For universal (including QEMU) image build
do_install:armefi64-rdk-broadband() {
    # Config files and scripts
    install -d ${D}/usr/ccsp/config
    install -d ${D}/usr/ccsp/machine_configs
    install -d ${D}/usr/ccsp/psm
    cp ${UNPACKDIR}/bbhm_def_cfg_ten64.xml ${D}/usr/ccsp/machine_configs/traverse_ten64.xml
    cp ${UNPACKDIR}/${DEFAULT_BBHM_CONFIG:armefi64-rdk-broadband} ${D}/usr/ccsp/machine_configs/default.xml
    cp ${UNPACKDIR}/${DEFAULT_BBHM_CONFIG:raspberrypi64-rdk-broadband} ${D}/usr/ccsp/machine_configs/raspberrypi_4-model-b.xml
    ln -sr ${D}/usr/ccsp/machine_configs/raspberrypi_4-model-b.xml ${D}/usr/ccsp/machine_configs/raspberrypi_3-model-b.xml
    ln -sr ${D}/usr/ccsp/machine_configs/raspberrypi_4-model-b.xml ${D}/usr/ccsp/machine_configs/raspberrypi_3-model-b-plus.xml
    cp ${UNPACKDIR}/${DEFAULT_BBHM_CONFIG:ten64-rdk-broadband} ${D}/usr/ccsp/machine_configs/traverse_ten64-4.xml

    install -m 755 ${UNPACKDIR}/copy_config.sh ${D}/usr/ccsp/psm/copy_config.sh
}


FILES:${PN} = " \
    /usr/ccsp/config \
    /usr/ccsp/psm/copy_config.sh \
"

FILES:${PN}:append:armefi64-rdk-broadband = "\
    /usr/ccsp/machine_configs/* \
"
