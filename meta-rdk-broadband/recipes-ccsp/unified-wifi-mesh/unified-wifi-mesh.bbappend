# These will be handled by unified-wifi-mesh-personality packages
do_install:append() {
    rm -rf ${D}${systemd_unitdir}/system/
    rm -rf ${D}/lib
}

FILES_${PN}:remove = "${systemd_unitdir}/system/*"

unset SYSTEMD_SERVICE_${PN}