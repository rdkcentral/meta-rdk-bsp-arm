require ccsp_common_genericarm.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
    file://cr-deviceprofile_genericarm.xml \
"

do_install:append() {
    # Config files and scripts
    install -m 644 ${WORKDIR}/cr-deviceprofile_genericarm.xml ${D}/usr/ccsp/cr-deviceprofile.xml
    install -m 644 ${WORKDIR}/cr-deviceprofile_genericarm.xml ${D}/usr/ccsp/cr-ethwan-deviceprofile.xml
}
