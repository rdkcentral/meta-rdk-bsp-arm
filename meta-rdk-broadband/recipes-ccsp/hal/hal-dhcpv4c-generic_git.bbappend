SRC_URI_append = " \
    ${CMF_GIT_ROOT}/rdkb/devices/raspberrypi/hal;protocol=${CMF_GIT_PROTOCOL};branch=${CMF_GIT_BRANCH};destsuffix=git/source/dhcpv4c/devices_rpi;name=dhcphal-raspberrypi \
"
SRCREV_dhcphal-raspberrypi = "${AUTOREV}"

do_configure_prepend(){
    rm ${S}/dhcpv4c_api.c
    ln -sf ${S}/devices_rpi/source/dhcpv4c/dhcpv4c_api.c ${S}/dhcpv4c_api.c
}

