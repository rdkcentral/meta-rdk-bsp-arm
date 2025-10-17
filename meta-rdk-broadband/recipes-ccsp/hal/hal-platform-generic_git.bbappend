FILESEXTRAPATHS_prepend := "${THISDIR}/hal-platform-generic:"

SRC_URI_append = " \
       file://platform_hal.c \
       file://Makefile.am \
"

DEPENDS += "utopia-headers"
CFLAGS_append = " \
    -I=${includedir}/utctx \
"
CFLAGS_append_aarch64 = " -D_64BIT_ARCH_SUPPORT_"
do_configure_prepend(){
    rm ${S}/platform_hal.c
    cp ${WORKDIR}/platform_hal.c ${S}/platform_hal.c
    rm ${S}/Makefile.am
    cp ${WORKDIR}/Makefile.am ${S}/Makefile.am
}

