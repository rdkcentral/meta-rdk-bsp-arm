DEPENDS += "${@bb.utils.contains('DISTRO_FEATURES','bridgeUtilsBin','ovs-agent','',d)}"

SRC_URI_append = " \
    ${CMF_GIT_ROOT}/rdkb/devices/raspberrypi/hal;protocol=${CMF_GIT_PROTOCOL};branch=${CMF_GIT_BRANCH};destsuffix=git/source/bridgeutil/devices_rpi;name=bridgeutilhal-raspberrypi \
"
SRCREV_bridgeutilhal-raspberrypi = "${AUTOREV}"

do_configure_prepend(){
    rm ${S}/bridge_util_oem.c
    ln -sf ${S}/devices_rpi/source/bridgeutil/bridge_util_oem.c ${S}/bridge_util_oem.c
    rm ${S}/Makefile.am
    ln -sf ${S}/devices_rpi/source/bridgeutil/Makefile.am ${S}/
    rm ${S}/configure.ac
    ln -sf ${S}/devices_rpi/source/bridgeutil/configure.ac ${S}/
}
