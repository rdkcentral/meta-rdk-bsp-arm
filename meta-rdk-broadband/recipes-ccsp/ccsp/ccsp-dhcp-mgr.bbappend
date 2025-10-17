require ccsp_common_genericarm.inc
CFLAGS_append_kirkstone = " -fcommon -Wno-error=implicit-function-declaration"
LDFLAGS_append_aarch64 = " -lnanomsg "
FILES_${PN} += " /lib/systemd/system "

FILESEXTRAPATHS_prepend := "${THISDIR}/ccsp-dhcp-mgr:"

SRC_URI += "\
        file://0001-ccsp-dhcp-manager-fix-non-moca-compile-error.patch \
"

do_genericarm_patches() {
    cd ${S}
    if [ ! -e genericarm_patch_applied ]; then
        bbnote "Applying 0001-ccsp-dhcp-manager-fix-non-moca-compile-error.patch into ${S}"
        patch -p1 -i ${WORKDIR}/0001-ccsp-dhcp-manager-fix-non-moca-compile-error.patch
        touch genericarm_patch_applied
    fi
}
addtask genericarm_patches after do_unpack before do_compile
