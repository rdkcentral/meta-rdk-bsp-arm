SRC_URI:remove = "file://verbose.patch"
SRC_URI:remove = "file://revsshipv6.patch"
SYSTEMD_SERVICE:${PN}:remove:broadband = "dropbear.socket"

do_install:append:broadband() {
  rm -rf ${D}${systemd_unitdir}
  rm -rf ${D}/lib
}
