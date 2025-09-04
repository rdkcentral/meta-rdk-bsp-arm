SRC_URI_remove = "git://github.com/rdkcentral/rdk-wifi-hal.git;protocol=https;branch=main;name=rdk-wifi-hal"

SRC_URI += "git://github.com/rdkcentral/rdk-wifi-hal.git;protocol=https;branch=develop;name=rdk-wifi-hal"
SRCREV_rdk-wifi-hal = "e62398c723a9cc96ac6b62a5b35e29a49869de51"

FILESEXTRAPATHS_prepend := "${THISDIR}/rdk-wifi-hal:"

# Patch an issue with the mainline mt76 (MediaTek) driver
SRC_URI_append = "\
        file://0001-wifi_hal-do-not-create-any-vaps-other-than-private.patch;apply=no \
        file://0002-platform-raspberry-pi-remove-RPI-reference-default-SSID.patch;apply=no \
        file://0003-platform-raspberrypi-remove-unused-variable.patch;apply=no \
        file://0004-platform-rasbperry-pi-remove-functions-now-implement.patch;apply=no \
"

CFLAGS_append = " -D_PLATFORM_RASPBERRYPI_  -DRASPBERRY_PI_PORT "
CFLAGS_append_kirkstone = " -fcommon"
EXTRA_OECONF_append = " ${@bb.utils.contains('DISTRO_FEATURES', 'OneWifi', ' ONE_WIFIBUILD=true ', '', d)}"
EXTRA_OECONF_append = " ${@bb.utils.contains('DISTRO_FEATURES', 'OneWifi', ' RASPBERRY_PI_PORT=true ', '', d)}"

do_genericarm_patches() {
    cd ${S} # This puts us in "rdk-wifi-hal/src, so use -p2 below"
    if [ ! -e genericarm_patch_applied ]; then
        bbnote "Applying 0001-wifi_hal-do-not-create-any-vaps-other-than-private.patch into ${S}"
        patch -p2 -i ${WORKDIR}/0001-wifi_hal-do-not-create-any-vaps-other-than-private.patch
        bbnote "Applying 0002-platform-raspberry-pi-remove-RPI-reference-default-SSID.patch into ${S}"
        patch -d ${S}/.. -p1 -i ${WORKDIR}/0002-platform-raspberry-pi-remove-RPI-reference-default-SSID.patch
        bbnote "Applying 0003-platform-raspberrypi-remove-unused-variable.patch into ${S}"
        patch -d ${S}/.. -p1 -i ${WORKDIR}/0003-platform-raspberrypi-remove-unused-variable.patch
        bbnote "Applying 0004-platform-rasbperry-pi-remove-functions-now-implement.patch into ${S}"
        patch -d ${S}/.. -p1 -i ${WORKDIR}/0004-platform-rasbperry-pi-remove-functions-now-implement.patch
        touch genericarm_patch_applied
    fi
}
addtask genericarm_patches after do_unpack before do_compile

