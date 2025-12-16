inherit systemd

DESCRIPTION = "Runtime dependencies for unified-wifi-mesh in controller mode"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${WORKDIR}/onewifi_pre_start_em_ctrl.sh;beginline=2;endline=19;md5=d731450331b3bf78311e68e14f8223de"

RPROVIDES:${PN} = "virtual/unified-wifi-mesh-personality"

RDEPENDS:${PN} = "unified-wifi-mesh-personality-common maccalc"

SRC_URI = "file://onewifi_pre_start_em_ctrl.sh \
    file://setup_mysql_db_post.sh \
    file://setup_mysql_db_pre.sh \
    file://EasymeshCfg.json \
    file://em_agent_pre_start.sh \
    file://em_ctrl_pre_start.sh \
    file://em_ctrl_with_pre_start.service \
    file://ieee1905_em_agent.service \
    file://ieee1905_em_ctrl.service \
"

do_install() {
    install -d ${D}/usr/ccsp/EasyMesh
    install -m 0755 ${WORKDIR}/em_ctrl_pre_start.sh ${D}/usr/ccsp/EasyMesh/em_ctrl_pre_start.sh
    install -m 0755 ${WORKDIR}/em_agent_pre_start.sh ${D}/usr/ccsp/EasyMesh/em_agent_pre_start.sh
    ln -s -r ${D}/usr/ccsp/EasyMesh/em_agent_pre_start.sh ${D}/usr/ccsp/EasyMesh/setup_ext_pre.sh
    install -d ${D}/usr/ccsp/EasyMesh/nvram
    install -m 0644 ${WORKDIR}/Easymesh*.json  ${D}/usr/ccsp/EasyMesh/nvram/EasymeshCfg.json
    install -d ${D}/usr/ccsp/wifi
    install -m 0755 ${WORKDIR}/onewifi_pre_start_em_ctrl.sh ${D}/usr/ccsp/wifi/onewifi_pre_start.sh
    install -d ${D}${systemd_unitdir}/system
    install -D -m 0644 ${WORKDIR}/em_ctrl_with_pre_start.service ${D}${systemd_unitdir}/system/em_ctrl.service
    install -D -m 0644 ${WORKDIR}/ieee1905_em_agent.service ${D}${systemd_unitdir}/system/
    install -D -m 0644 ${WORKDIR}/ieee1905_em_ctrl.service  ${D}${systemd_unitdir}/system/
}

FILES:${PN} = "\
    /usr/ccsp/EasyMesh/em_ctrl_pre_start.sh \
    /usr/ccsp/EasyMesh/em_agent_pre_start.sh \
    /usr/ccsp/EasyMesh/nvram/EasymeshCfg.json \
    /usr/ccsp/EasyMesh/setup_ext_pre.sh \
    /usr/ccsp/wifi/onewifi_pre_start.sh \
    ${systemd_unitdir}/system/em_ctrl.service \
    ${systemd_unitdir}/system/ieee1905_em_agent.service \
    ${systemd_unitdir}/system/ieee1905_em_ctrl.service \
"

SYSTEMD_SERVICE:${PN} = " \
    em_ctrl.service \
    ieee1905_em_agent.service \
    ieee1905_em_ctrl.service \
"
