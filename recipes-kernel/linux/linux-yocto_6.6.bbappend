# Generic machine setup (core-image-minimal)
COMPATIBLE_MACHINE:armefi64 = "armefi64"

ARMFILESPATHS := "${THISDIR}/${PN}-6.6:"
FILESEXTRAPATHS:prepend:armefi64 = "${ARMFILESPATHS}"

# Generic 6.6 defconfig and kernel patches
SRC_URI:append:armefi64 = " \
	file://defconfig-6.6 \
	"
