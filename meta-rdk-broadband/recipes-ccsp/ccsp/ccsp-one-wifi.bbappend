require ccsp_common_genericarm.inc

DEPENDS:append = " rdk-wifi-hal"
CFLAGS:append = " -DWIFI_HAL_VERSION_3 -Wno-unused-function"

FILESEXTRAPATHS:prepend := "${THISDIR}/ccsp-one-wifi:"

SRC_URI:append = " \
    file://wifi_defaults.txt \
    file://onewifi_pre_start.sh \
"

do_install:append() {
    install -d ${D}/usr/ccsp/wifi/
    install -m 644 ${WORKDIR}/wifi_defaults.txt ${D}/usr/ccsp/wifi/
    install -m 755 ${WORKDIR}/onewifi_pre_start.sh ${D}/usr/ccsp/wifi/
}

FILES:${PN}:append = " \
    /usr/bin/wifi_events_consumer \
    /usr/ccsp/wifi/wifi_defaults.txt \
    /usr/ccsp/wifi/onewifi_pre_start.sh \
"