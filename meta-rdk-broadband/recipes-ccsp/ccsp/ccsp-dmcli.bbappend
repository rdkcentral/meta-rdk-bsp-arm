require ccsp_common_genericarm.inc

do_install:append () {
    ln -sf ${bindir}/dmcli ${D}${bindir}/ccsp_bus_client_tool
    ln -sf ${bindir}/dmcli ${D}/usr/ccsp/ccsp_bus_client_tool
}
