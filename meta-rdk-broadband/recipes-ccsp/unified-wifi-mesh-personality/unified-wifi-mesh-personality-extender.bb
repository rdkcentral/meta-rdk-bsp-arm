inherit systemd

DESCRIPTION = "Runtime dependencies for unified-wifi-mesh in extender mode"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${WORKDIR}/onewifi_pre_start_em_ext.sh;beginline=2;endline=19;md5=d731450331b3bf78311e68e14f8223de"

RPROVIDES:${PN} = "virtual/unified-wifi-mesh-personality"

RDEPENDS:${PN} = "unified-wifi-mesh-personality-common maccalc socat"

SRC_URI = "\
    file://ieee1905_em_ext_agent.service \
    file://EasymeshCfg_ext.json \
    file://onewifi_pre_start_em_ext.sh \
    file://em_agent_pre_start.sh \
"

do_install() {
    install -d ${D}/usr/ccsp/EasyMesh
    install -m 0755 ${WORKDIR}/em_agent_pre_start.sh ${D}/usr/ccsp/EasyMesh/em_agent_pre_start.sh
    install -D -m 0644 ${WORKDIR}/ieee1905_em_ext_agent.service ${D}${systemd_unitdir}/system/ieee1905_em_agent.service
    install -d ${D}/usr/ccsp/wifi
    install -m 0755 ${WORKDIR}/onewifi_pre_start_em_ext.sh ${D}/usr/ccsp/wifi/onewifi_pre_start.sh
    install -d ${D}/usr/ccsp/EasyMesh/nvram
    install -m 0644 ${WORKDIR}/EasymeshCfg_ext.json  ${D}/usr/ccsp/EasyMesh/nvram/EasymeshCfg.json
}

FILES:${PN} = "\
    ${systemd_unitdir}/system/ieee1905_em_agent.service \
    /usr/ccsp/EasyMesh/nvram/EasymeshCfg.json \
    /usr/ccsp/wifi/onewifi_pre_start.sh \
    /usr/ccsp/EasyMesh/em_agent_pre_start.sh \
"

SYSTEMD_SERVICE:${PN} += " \
    ieee1905_em_agent.service \
"
