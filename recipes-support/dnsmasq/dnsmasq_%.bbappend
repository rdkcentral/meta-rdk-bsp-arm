# dnsmasq is managed by utopia's service_dhcp_server.sh
# Override do_install to prevent the installation of
# systemd units
do_install() {
        oe_runmake "PREFIX=${D}${prefix}" \
                   "BINDIR=${D}${bindir}" \
                   "MANDIR=${D}${mandir}" \
                   install
        install -d ${D}${sysconfdir}
        install -m 644 ${WORKDIR}/dnsmasq.conf ${D}${sysconfdir}

        # When running under a completely read-only /etc,
        # make sure there is a "target" file to bind mount
        # resolv.dnsmasq to
        touch ${D}${sysconfdir}/resolv.dnsmasq
}

SYSTEMD_SERVICE:${PN} = ""
