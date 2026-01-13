# These will be handled by unified-wifi-mesh-personality packages
do_install:append() {
    rm -rf ${D}${systemd_unitdir}/system/
    rm -rf ${D}/lib
}

FILES:${PN}:remove = "${systemd_unitdir}/system/*"

SYSTEMD_SERVICE:${PN} = ""
