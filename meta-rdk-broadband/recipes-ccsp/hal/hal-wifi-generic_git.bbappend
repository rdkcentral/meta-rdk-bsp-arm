SRC_URI:append = " \
    ${CMF_GIT_ROOT}/rdkb/devices/raspberrypi/hal;protocol=${CMF_GIT_PROTOCOL};branch=${CMF_GIT_BRANCH};destsuffix=git/source/wifi/devices_rpi;name=wifihal-raspberrypi \
"

SRCREV_wifihal-raspberrypi = "${AUTOREV}"

DEPENDS +=" libev wpa-supplicant"
DEPENDS:append = "${@bb.utils.contains('DISTRO_FEATURES', 'OneWifi', ' rdk-wifi-hal', '', d)}"
LDFLAGS:append = " -lev -lwpa_client -lpthread"

do_configure:prepend(){
    rm ${S}/wifi_hal.c
    rm ${S}/Makefile.am
    ln -sf ${S}/devices_rpi/source/wifi/wifi_hal.c ${S}/wifi_hal.c
    ln -sf ${S}/devices_rpi/source/wifi/client_wifi_hal.c ${S}/client_wifi_hal.c
    ln -sf ${S}/devices_rpi/source/wifi/wifi_hostapd_interface.c ${S}/wifi_hostapd_interface.c
    ln -sf ${S}/devices_rpi/source/wifi/rpi_wifi_hal_assoc_devices_details.c ${S}/rpi_wifi_hal_assoc_devices_details.c
    ln -sf ${S}/devices_rpi/source/wifi/rpi_wifi_hal_version_3.c ${S}/rpi_wifi_hal_version_3.c
    ln -sf ${S}/devices_rpi/source/wifi/wifi_hal_rpi.h ${S}/wifi_hal_rpi.h
    ln -sf ${S}/devices_rpi/source/wifi/Makefile.am ${S}/Makefile.am
}

do_install:append(){
    install -d ${D}/usr/bin
    install -m 777 ${B}/wifihal ${D}/usr/bin/
}

CFLAGS:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'extender', '-D_RPI_EXTENDER_', '', d)}"
CFLAGS:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'halVersion3', ' -DWIFI_HAL_VERSION_3 ', '', d)}"
CFLAGS:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'OneWifi', ' -D_ONE_WIFI_ ', '', d)}"

RDEPENDS_${PN} += "wpa-supplicant"

