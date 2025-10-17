do_install_append () {
    # Config files and scripts
    install -d ${D}${exec_prefix}/ccsp/notify-comp
    install -m 644 ${S}/scripts/msg_daemon.cfg ${D}${exec_prefix}/ccsp/notify-comp/msg_daemon.cfg
    install -m 644 ${S}/scripts/NotifyComponent.xml ${D}${exec_prefix}/ccsp/notify-comp/NotifyComponent.xml
    install -m 755 ${D}/usr/bin/* ${D}${exec_prefix}/ccsp/notify-comp
}

