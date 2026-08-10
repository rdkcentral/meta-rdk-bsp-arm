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

PV = "${LINUX_VERSION}+git${SRCPV}"