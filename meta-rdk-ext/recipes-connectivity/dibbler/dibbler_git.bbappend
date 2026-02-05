do_install:append:broadband() {
	if [ -f ${D}${sysconfdir}/udhcpc.vendor_specific ]; then
		rm -rf ${D}${sysconfdir}/udhcpc.vendor_specific
	fi
}

