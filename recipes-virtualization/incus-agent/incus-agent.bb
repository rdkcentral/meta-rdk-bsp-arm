inherit systemd
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"


DESCRIPTION = "Hook to automatically install Incus agent"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${WORKDIR}/install-incus-agent.sh;beginline=2;endline=19;md5=9ccd86322e8b3587f7d5f8eb82a2e0a2"

SRC_URI = "\
    file://install-incus-agent.service \
    file://install-incus-agent.sh \
"

do_install() {
    install -d ${D}${systemd_unitdir}/system
    install -m 644 ${WORKDIR}/install-incus-agent.service ${D}${systemd_unitdir}/system
    install -d ${D}${sbindir}
    install -m 755 ${WORKDIR}/install-incus-agent.sh ${D}${sbindir}
}

SYSTEMD_SERVICE:${PN} = "install-incus-agent.service"

FILES:${PN} = " \
	${systemd_unitdir}/system/install-incus-agent.service \
	${sbindir}/install-incus-agent.sh \
"
