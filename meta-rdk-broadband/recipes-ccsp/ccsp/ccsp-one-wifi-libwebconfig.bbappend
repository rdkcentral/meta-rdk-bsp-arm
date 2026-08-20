# revert RDKB-62931,XB10-2872-OneWifi sync 08/07/26
SRCREV_libwebconfig = "d17bd2d25fc0728d130cbe84e3c0e90b3734a6bc"

DEPENDS += " ${@bb.utils.contains('DISTRO_FEATURES', 'EasyMesh', ' rdk-wifi-libhostap unified-wifi-mesh-header ', '', d)}"
EXTRA_OECONF:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'EasyMesh', ' --enable-easymesh ', '', d)}"
EXTRA_OECONF:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'EasyMesh', ' --enable-em-app ', '', d)}"

CFLAGS += " -Wno-enum-conversion "
CFLAGS += " ${@bb.utils.contains('DISTRO_FEATURES', 'EasyMesh', ' -Wno-error=maybe-uninitialized -Wno-error=unused-variable -Wno-error=unused-but-set-variable -Wno-error=incompatible-pointer-types -Wno-error=sign-compare -Wno-error -DEASY_MESH_NODE  ', '', d)}"

# Undo RDKB-64429
CFLAGS:remove = " -DONEWIFI_MULTIAP_APP_SUPPORT"
EXTRA_OECONF:remove = " ONEWIFI_MULTIAP_APP_SUPPORT=true"


do_compile:append() {
    oe_runmake -C source/platform
}
do_install:append() {
      oe_runmake -C source/platform DESTDIR=${D} install
      install -m 644 ${S}/include/webconfig_external_proto_easymesh.h  ${D}/usr/include/ccsp
}

FILES:${PN}:append = " \
    ${libdir}/libwifi_bus.so* \
"

