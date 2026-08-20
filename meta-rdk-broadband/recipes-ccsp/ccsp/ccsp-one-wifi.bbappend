require ccsp_common_genericarm.inc

DEPENDS:append = " rdk-wifi-hal"
CFLAGS:append = " -DWIFI_HAL_VERSION_3 -Wno-unused-function"

FILESEXTRAPATHS:prepend := "${THISDIR}/ccsp-one-wifi:"

SRC_URI:append = " \
    file://wifi_defaults.txt \
    file://onewifi_pre_start.sh \
    file://0001-db-fix-compile-error-when-ONEWIFI_DB_SUPPORT-not-set.patch \
    file://0002-wifi_db-fix-incorrect-type-for-index-variable.patch \
"

# revert RDKB-62931,XB10-2872-OneWifi sync 08/07/26
SRCREV_OneWifi = "d17bd2d25fc0728d130cbe84e3c0e90b3734a6bc"

# Undo RDKB-64429
SRC_URI:remove = "git://github.com/rdk-gdcs/lan_web.git;protocol=https;branch=main_branch_multiap_update;name=lan_web;destsuffix=lan_web"
CFLAGS:remove = " -DONEWIFI_MULTIAP_APP_SUPPORT"
EXTRA_OECONF:remove = " ONEWIFI_MULTIAP_APP_SUPPORT=true"
SRCREV_FORMAT = "OneWifi"

RDEPENDS_${PN}:append = "${@bb.utils.contains('DISTRO_FEATURES', 'EasyMesh', ' virtual/unified-wifi-mesh-personality', '', d)}"
RDEPENDS_${PN}:remove = "${@bb.utils.contains('DISTRO_FEATURES', 'EasyMesh', ' openvswitch', '', d)}"

EXTRA_OECONF:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'EasyMesh', ' --enable-em-app ', '', d)}"
CFLAGS:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'EasyMesh', ' -DEASY_MESH_NODE ', '', d)}"

EXTRA_OECONF:remove = " ${@bb.utils.contains('DISTRO_FEATURES', 'EasyMesh', ' ONEWIFI_CAC_APP_SUPPORT=true ', '', d)}"
CFLAGS:remove = " ${@bb.utils.contains('DISTRO_FEATURES', 'EasyMesh', ' -DONEWIFI_CAC_APP_SUPPORT -DONEWIFI_DB_SUPPORT  ', '', d)}"

# TODO: Lots of issues in OneWiFi with different int types being compared
CFLAGS:append:aarch64 = " -Wno-error "

# Undo RDKB-64429
do_compile:prepend() {
    mkdir -p ${WORKDIR}/lan_web/
    touch ${WORKDIR}/lan_web/multiap_stub_removed
}

do_install:append() {
    install -d ${D}/usr/ccsp/wifi/
    install -m 644 ${WORKDIR}/wifi_defaults.txt ${D}/usr/ccsp/wifi/
}

FILES:${PN}:append = " \
    /usr/bin/wifi_events_consumer \
    /usr/ccsp/wifi/wifi_defaults.txt \
    ${@bb.utils.contains('DISTRO_FEATURES', 'EasyMesh', '', '/usr/ccsp/wifi/onewifi_pre_start.sh', d)} \
"

python() {
    distro_features = d.getVar("DISTRO_FEATURES")
    if (distro_features.find("EasyMesh") < 0):
        d.appendVar("do_install", "\ninstall -m 755 ${WORKDIR}/onewifi_pre_start.sh ${D}/usr/ccsp/wifi/")
}

