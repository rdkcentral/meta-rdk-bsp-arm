FILESEXTRAPATHS:prepend := "${THISDIR}/hal-ethsw-generic:"

SRC_URI:append = " \
       file://ccsp_hal_ethsw.c \
"

DEPENDS += "libnl"

CFLAGS:append  = " ${@bb.utils.contains('DISTRO_FEATURES', 'rdkb_wan_manager', '-DFEATURE_RDKB_WAN_MANAGER', '', d)}"
CFLAGS:append  = " -I${STAGING_INCDIR}/libnl3"
LDFLAGS:append = " -lnl-3 -lnl-route-3"

do_configure:prepend(){
    cp ${WORKDIR}/ccsp_hal_ethsw.c  ${S}/ccsp_hal_ethsw.c
}
