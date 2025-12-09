ARMFILESPATHS := "${THISDIR}/${PN}:"

# Generic machine setup (core-image-minimal)
COMPATIBLE_MACHINE:armefi64 = "armefi64"
FILESEXTRAPATHS:prepend:armefi64 = "${ARMFILESPATHS}"

# All RDK changes are below this line

# Provide the kernel autoconf.h for use by other
# packages (required by utopia)
require kernel-autoconf.inc

# Override any MACHINE derived kernel arguments
# These allow all derived machine types (raspberrypi, ten64, etc.) to
# use the kernel build from the generic machine
PACKAGE_ARCH = "${TUNE_PKGARCH}"
KMACHINE = "${TUNE_PKGARCH}"
KERNEL_ARTIFACT_NAME = "${PKGE}-${PKGV}-${PKGR}-${KMACHINE}${IMAGE_VERSION_SUFFIX}"
