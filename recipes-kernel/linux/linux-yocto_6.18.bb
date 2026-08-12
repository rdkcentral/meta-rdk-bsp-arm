KBRANCH ?= "v6.18/standard/genericarm64"
require recipes-kernel/linux/linux-yocto.inc

# 6.18.44
SRCREV_machine:armefi64 ?= "e53bc6de014bcdd6615eeed206ef14ebe67c423b"
LINUX_VERSION ?= "6.18.44"
SRCREV_meta ?= "f94e250f9bd55d855b1a41e3cd72beebb3849ae3"

# set your preferred provider of linux-yocto to 'linux-yocto-upstream', and you'll
# get the <version>/base branch, which is pure upstream -stable, and the same
# meta SRCREV as the linux-yocto-standard builds. Select your version using the
# normal PREFERRED_VERSION settings.
BBCLASSEXTEND = "devupstream:target"
SRCREV_machine:class-devupstream ?= "c0d886e4af574740bcffafda40ae692918ca87f9"
PN:class-devupstream = "linux-yocto-upstream"
KBRANCH:class-devupstream = "v6.18/base"

KMETA = "kernel-meta"

SRC_URI = "git://git.yoctoproject.org/linux-yocto.git;name=machine;branch=${KBRANCH};protocol=https \
           git://git.yoctoproject.org/yocto-kernel-cache;type=kmeta;name=meta;branch=yocto-6.18;destsuffix=${KMETA};protocol=https"
LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

DEPENDS += "${@bb.utils.contains('ARCH', 'x86', 'elfutils-native', '', d)}"
DEPENDS += "openssl-native util-linux-native"
DEPENDS += "gmp-native libmpc-native"

# replaces kernel_do_install from kirkstone's kernel.bbclass
# reason: kirkstone kernel.bbclass does not specify "rm -f" for build and source dirs
kernel_do_install:kirkstone() {
	unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS MACHINE
	if (grep -q -i -e '^CONFIG_MODULES=y$' .config); then
		oe_runmake DEPMOD=echo MODLIB=${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION} INSTALL_FW_PATH=${D}${nonarch_base_libdir}/firmware modules_install
		rm -f "${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/build"
		rm -f "${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/source"
		# Remove empty module directories to prevent QA issues
		[ -d "${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel" ] && find "${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel" -type d -empty -delete
	else
		bbnote "no modules to install"
	fi

	#
	# Install various kernel output (zImage, map file, config, module support files)
	#
	install -d ${D}/${KERNEL_IMAGEDEST}

	#
	# bundle_initramfs runs after do_install before do_deploy. do_deploy does what's needed therefore.
	#
	for imageType in ${KERNEL_IMAGETYPES} ; do
		if [ "${INITRAMFS_IMAGE_BUNDLE}" != "1" ] ; then
			install -m 0644 ${KERNEL_OUTPUT_DIR}/$imageType ${D}/${KERNEL_IMAGEDEST}/$imageType-${KERNEL_VERSION}
		fi
	done

	install -m 0644 System.map ${D}/${KERNEL_IMAGEDEST}/System.map-${KERNEL_VERSION}
	install -m 0644 .config ${D}/${KERNEL_IMAGEDEST}/config-${KERNEL_VERSION}
	install -m 0644 vmlinux ${D}/${KERNEL_IMAGEDEST}/vmlinux-${KERNEL_VERSION}
	! [ -e Module.symvers ] || install -m 0644 Module.symvers ${D}/${KERNEL_IMAGEDEST}/Module.symvers-${KERNEL_VERSION}
}

do_install:remove:kirkstone = "kernel_do_install"
do_install:prepend:kirkstone = "kernel_do_install_kirkstone"

PV = "${LINUX_VERSION}+git${SRCPV}"