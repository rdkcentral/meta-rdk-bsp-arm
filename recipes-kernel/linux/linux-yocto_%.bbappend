ARMFILESPATHS := "${THISDIR}/${PN}:"

# Generic machine setup (core-image-minimal)
COMPATIBLE_MACHINE:armefi64 = "armefi64"
FILESEXTRAPATHS:prepend:armefi64 = "${ARMFILESPATHS}"
SRC_URI:append:armefi64 = " \
	file://defconfig \
	file://01_dpaa2_fix_sfp_lock_issue.patch \  
	file://02_dpaa2_add_more_10G_modes.patch \
        file://03_rk3568-pcie-phy-backports.patch \
	"

# All RDK changes are below this line

# Provide the kernel autoconf.h for use by other
# packages (required by utopia)
require kernel-autoconf.inc

RDKBFILESPATHS := "${THISDIR}/rdkb:"

FILESEXTRAPATHS:prepend:broadband = "${RDKBFILESPATHS}"

SRC_URI:append:broadband = " \
	file://rdkb.cfg \
	file://netfilter.cfg \
	file://proc-event.cfg \
"

# Patches required to allow backported mt76 driver
SRC_URI:append:armefi64 = " file://04_mtk-backports-for-5-15.patch \
                            file://05_net-allow-PAGE_POOL-to-be-user-selected.patch \
"

# Override any MACHINE derived kernel arguments
# These allow all derived machine types (raspberrypi, ten64, etc.) to
# use the kernel build from the generic machine
PACKAGE_ARCH = "${TUNE_PKGARCH}"
KMACHINE = "${TUNE_PKGARCH}"
KERNEL_ARTIFACT_NAME = "${PKGE}-${PKGV}-${PKGR}-${KMACHINE}${IMAGE_VERSION_SUFFIX}"
