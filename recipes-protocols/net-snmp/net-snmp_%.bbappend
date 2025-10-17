SRC_URI_remove = " \
    file://CiscoXB3-2774.patch \
"

do_install_append_broadband() {
        sed -i "s/ExecStart=\/usr\/sbin\/snmpd \$OPTIONS \-a \-f/#ExecStart=\/usr\/sbin\/snmpd \$OPTIONS \-a \-f/g" ${D}${systemd_unitdir}/system/snmpd.service
        sed -i "/#ExecStart=\/usr\/sbin\/snmpd \$OPTIONS \-a \-f/a ExecStart=\/usr\/sbin\/snmpd \-f \-C \-c \/usr\/ccsp\/snmp\/snmpd.conf \-M \/usr\/share\/snmp\/mibs \-Le" ${D}${systemd_unitdir}/system/snmpd.service
        sed -i "/ExecReload/a Restart=always" ${D}${systemd_unitdir}/system/snmpd.service
}
