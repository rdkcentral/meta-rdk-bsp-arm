# Only override SRC_URI when EasyMesh is enabled
# (OneWiFi "main" branch does not recognize --enable-em-app as of 2026-02-12)
python() {
    distro_features = d.getVar("DISTRO_FEATURES")
    if (distro_features.find("EasyMesh") > 0):
        d.setVar("SRC_URI","git://github.com/rdkcentral/OneWifi.git;protocol=https;branch=develop;name=libwebconfig")
        d.setVar("SRCREV_libwebconfig","74ea1f6ca37612b13cfccba6213fe3fb06beb982")
}

DEPENDS += " ${@bb.utils.contains('DISTRO_FEATURES', 'EasyMesh', ' rdk-wifi-libhostap unified-wifi-mesh-header ', '', d)}"
EXTRA_OECONF:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'EasyMesh', ' --enable-easymesh ', '', d)}"
EXTRA_OECONF:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'EasyMesh', ' --enable-em-app ', '', d)}"

EXTRA_OECONF:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'EasyMesh', ' --enable-em-app ', '', d)}"

CFLAGS += " -Wno-enum-conversion "
CFLAGS += " ${@bb.utils.contains('DISTRO_FEATURES', 'EasyMesh', ' -Wno-error=maybe-uninitialized -Wno-error=unused-variable -Wno-error=unused-but-set-variable -Wno-error=incompatible-pointer-types -Wno-error=sign-compare -Wno-error -DEASY_MESH_NODE  ', '', d)}"

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

