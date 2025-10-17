SUMMARY = "HAL for RDK CCSP components"
HOMEPAGE = "http://github.com/belvedere-yocto/hal"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://../../LICENSE;md5=3b83ef96387f14655fc854ddc3c6bd57"

PROVIDES = "hal-fwupgrade"
RPROVIDES_${PN} = "hal-fwupgrade"

DEPENDS += "rdkb-halif-fwupgrade"
SRC_URI = "${CMF_GIT_ROOT}/rdkb/devices/raspberrypi/hal;protocol=${CMF_GIT_PROTOCOL};branch=${CMF_GIT_BRANCH};name=fwupgradehal"

SRCREV_fwupgradehal = "${AUTOREV}"
SRCREV_FORMAT = "fwupgradehal"

PV = "${RDK_RELEASE}+git${SRCPV}"

S = "${WORKDIR}/git/source/fwupgrade"

CFLAGS_append = " -I=${includedir}/ccsp "

inherit autotools coverity

