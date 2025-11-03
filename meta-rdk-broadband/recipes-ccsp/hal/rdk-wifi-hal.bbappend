SRC_URI_remove = "git://github.com/rdkcentral/rdk-wifi-hal.git;protocol=https;branch=main;name=rdk-wifi-hal"

SRC_URI += "git://github.com/rdkcentral/rdk-wifi-hal.git;protocol=https;branch=develop;name=rdk-wifi-hal"
SRCREV_rdk-wifi-hal = "7cbf2c7a892e9d10be0fc8fa3ad85c7a7aeb511c"

FILESEXTRAPATHS_prepend := "${THISDIR}/rdk-wifi-hal:"

SRC_URI:append = "\
  file://0001-platform-change-default-SSID-to-RDKB-ARM-AP.patch;patchdir=.. \
"

RDEPENDS_${PN}:append = "virtual/unified-wifi-mesh-personality"

# For the purposes of the EasyMesh bring up, we will "pretend" to be a
# Banana Pi, which has the same WiFi vendor as us.
CFLAGS_append = " -D_PLATFORM_BANANAPI_R4_ -DBANANA_PI_PORT"
CFLAGS_append_kirkstone = " -fcommon"
EXTRA_OECONF_append = " ${@bb.utils.contains('DISTRO_FEATURES', 'OneWifi', ' ONE_WIFIBUILD=true ', '', d)}"
EXTRA_OECONF_append = " ${@bb.utils.contains('DISTRO_FEATURES', 'OneWifi', ' BANANA_PI_PORT=true ', '', d)}"