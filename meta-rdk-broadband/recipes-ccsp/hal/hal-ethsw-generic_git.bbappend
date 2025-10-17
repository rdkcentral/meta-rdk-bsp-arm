FILESEXTRAPATHS_prepend := "${THISDIR}/hal-ethsw-generic:"

SRC_URI_append = " \
       file://ccsp_hal_ethsw.c \
"

DEPENDS += "libnl"

CFLAGS_append  = " ${@bb.utils.contains('DISTRO_FEATURES', 'rdkb_wan_manager', '-DFEATURE_RDKB_WAN_MANAGER', '', d)}"
CFLAGS_append  = " -I${STAGING_INCDIR}/libnl3"
LDFLAGS_append = " -lnl-3 -lnl-route-3"

do_configure_prepend(){
    cp ${WORKDIR}/ccsp_hal_ethsw.c  ${S}/ccsp_hal_ethsw.c
}
