require ccsp_common_genericarm.inc

do_install_append () {
    ln -sf ${bindir}/dmcli ${D}${bindir}/ccsp_bus_client_tool
}
