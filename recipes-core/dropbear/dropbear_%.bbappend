SRC_URI_remove = "file://verbose.patch"
SRC_URI_remove = "file://revsshipv6.patch"
SRC_URI_remove_extender_kirkstone = " file://ssh_telemetry_2020.patch"
SYSTEMD_SERVICE_${PN}_remove_broadband = "dropbear.socket"

do_install_append_broadband() {
  rm -rf ${D}${systemd_unitdir}
  rm -rf ${D}/lib
}
