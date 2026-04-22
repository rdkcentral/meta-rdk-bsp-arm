FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

inherit systemd

SRC_URI:append = " file://network@.service"

S = "${WORKDIR}"
do_install:append() {
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${S}/network@.service ${D}${systemd_unitdir}/system/network@.service
}
SYSTEMD_SERVICE_${PN} += "network@.service"
FILES:${PN}:append = " \
      ${systemd_unitdir}/system/network@.service \
"
