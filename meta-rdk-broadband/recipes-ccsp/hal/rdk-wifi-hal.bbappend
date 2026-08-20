FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# revert RDKB-62931,XB10-2872-OneWifi sync 08/07/26
SRCREV_rdk-wifi-hal = "28645c9250ec4a9b0ba86be9ffa2bd4aa0e932cc"

SRC_URI:append = " \
	file://0001-platform-raspberry-pi-remove-unused-variable-in-plat.patch;patchdir=.. \
	file://0002-platform-raspberry-pi-use-RDKB-ARM-AP-d-on-meta-rdk-bsp-arm.patch;patchdir=.. \
	file://0003-platform-raspberry-pi-use-refboard_default_wifi_pass.patch;patchdir=.. \
"

CFLAGS:append = " \
	-fcommon \
	-Wno-error=maybe-uninitialized \
"

# Use Raspberry Pi platform file as a base
CFLAGS:append = " -D_PLATFORM_GENERICARM_ \
	-D_PLATFORM_RASPBERRYPI_  -DRASPBERRY_PI_PORT \
"
EXTRA_OECONF:append = " ONE_WIFIBUILD=true RASPBERRY_PI_PORT=true"

