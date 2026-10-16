# Create symlink for Aeonsemi PHY firmware, for
# compatibility with other AN7581 device trees
do_install:append() {
	ln -sf aeonsemi/as21x1x_fw.bin ${D}${nonarch_base_libdir}/firmware/as21x1x_fw.bin
}

FILES:${PN}-as21xxx:append = " \
    ${nonarch_base_libdir}/firmware/as21x1x_fw.bin* \
"
