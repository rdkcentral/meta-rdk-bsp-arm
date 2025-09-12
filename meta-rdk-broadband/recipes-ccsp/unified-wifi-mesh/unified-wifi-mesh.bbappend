SRC_URI_append = " file://em_ctrl_pre_start.sh \
    file://em_ctrl_with_pre_start.service"

FILESEXTRAPATHS:append := ":${THISDIR}/${PN}"

do_install:append() {
    install -m 0755 ${WORKDIR}/em_ctrl_pre_start.sh ${D}/usr/ccsp/EasyMesh/
    rm ${D}${systemd_unitdir}/system/em_ctrl.service
    install -D -m 0644 ${WORKDIR}/em_ctrl_with_pre_start.service ${D}${systemd_unitdir}/system/em_ctrl.service
}