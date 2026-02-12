require ccsp_common_genericarm.inc

DEPENDS:append = " rdk-wifi-hal"
CFLAGS:append = " -DWIFI_HAL_VERSION_3 -Wno-unused-function"

FILESEXTRAPATHS:prepend := "${THISDIR}/ccsp-one-wifi:"

SRC_URI:append = " \
    file://wifi_defaults.txt \
    file://onewifi_pre_start.sh \
"

EXTRA_OECONF:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'EasyMesh', ' --enable-em-app ', '', d)}"
CFLAGS:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'EasyMesh', ' -DEASY_MESH_NODE ', '', d)}"

EXTRA_OECONF:remove = " ${@bb.utils.contains('DISTRO_FEATURES', 'EasyMesh', ' ONEWIFI_CAC_APP_SUPPORT=true ', '', d)}"
CFLAGS:remove = " ${@bb.utils.contains('DISTRO_FEATURES', 'EasyMesh', ' -DONEWIFI_CAC_APP_SUPPORT -DONEWIFI_DB_SUPPORT  ', '', d)}"

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