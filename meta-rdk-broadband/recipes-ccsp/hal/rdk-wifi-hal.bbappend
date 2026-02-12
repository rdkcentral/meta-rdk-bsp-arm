FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
	file://0001-platform-raspberry-pi-remove-unused-variable-in-plat.patch;patchdir=.. \
	file://0002-platform-raspberry-pi-use-RDKB-ARM-AP-d-on-meta-rdk-bsp-arm.patch;patchdir=.. \
	file://0003-platform-raspberry-pi-use-refboard_default_wifi_pass.patch;patchdir=.. \
"

CFLAGS:append = " \
	-fcommon \
"

# Use Raspberry Pi platform file as a base
CFLAGS:append = " -D_PLATFORM_GENERICARM_ \
	-D_PLATFORM_RASPBERRYPI_  -DRASPBERRY_PI_PORT \
"
EXTRA_OECONF:append = " ONE_WIFIBUILD=true RASPBERRY_PI_PORT=true"

