FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# RDK-B 2026.Q3 version
SRCREV_rdk-wifi-hal = "67a05e9182d5b13778fd6f2248d71c5d64155af8"

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

CFLAGS:append = "${@bb.utils.contains('DISTRO_FEATURES', 'OneWiFi_Single_PHY', ' -DFEATURE_SINGLE_PHY', '', d)}"

EXTRA_OECONF:append = " ONE_WIFIBUILD=true RASPBERRY_PI_PORT=true"

