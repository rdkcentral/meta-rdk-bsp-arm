do_install_append_broadband() {
	if [ -f ${D}${sysconfdir}/udhcpc.vendor_specific ]; then
		rm -rf ${D}${sysconfdir}/udhcpc.vendor_specific
	fi
}

