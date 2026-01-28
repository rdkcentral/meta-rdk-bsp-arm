FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI:append = " file://remove_broadcast_test.patch"
SRCREV:Unified-wifi-mesh = "f7cbc0057874477685a162f7bbc40be666cc3220"
SRCPV:Unified-wifi-mesh = "v0.1.0"
# These will be handled by unified-wifi-mesh-personality packages
do_install:append() {
    rm -rf ${D}${systemd_unitdir}/system/
    rm -rf ${D}/lib
}

FILES:${PN}:remove = "${systemd_unitdir}/system/*"

SYSTEMD_SERVICE:${PN} = ""
