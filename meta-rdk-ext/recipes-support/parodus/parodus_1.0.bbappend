FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

LDFLAGS:append = " -Wl,--no-as-needed -lm -llog4c -lrdkloggers"

inherit systemd coverity

SRC_URI:append:broadband = " \
        ${CMF_GIT_ROOT}/rdk/devices/raspberrypi/webpa-client;protocol=${CMF_GIT_PROTOCOL};branch=${CMF_GIT_BRANCH};destsuffix=git/devices;name=rdkbrpi \
        file://0001-parodus-set-SyslogIdentifier-in-systemd-unit.patch;apply=no \
"

SRCREV_rdkbrpi = "${AUTOREV}"
do_fetch[vardeps] += "SRCREV_rdkbrpi"
SRCREV_FORMAT .= "_rdkbrpi"

do_genericarm_patches () {
    cd ${S}
    if [ ! -e patch_applied ]; then
        cd "devices"
        bbnote "Patching 0001-parodus-set-SyslogIdentifier-in-systemd-unit.patch"
        patch -p1 < ${WORKDIR}/0001-parodus-set-SyslogIdentifier-in-systemd-unit.patch
        cd ${S}
        touch patch_applied
    fi
}
addtask genericarm_patches after do_unpack before do_configure

do_install:append:broadband () {
    install -d ${D}${systemd_unitdir}/system
    install -d ${D}${base_libdir_native}/rdk
    install -m 0644 ${S}/devices/broadband/parodus/systemd/parodus.service ${D}${systemd_unitdir}/system
    install -m 0755 ${S}/devices/broadband/parodus/scripts/parodus_start.sh ${D}${base_libdir_native}/rdk
}

SYSTEMD_SERVICE:${PN}:append:broadband = " parodus.service"

FILES:${PN}:append:broadband = " \
     ${systemd_unitdir}/system/parodus.service \
     ${base_libdir_native}/rdk/* \
"
