require ccsp_common_genericarm.inc
CFLAGS_append_kirkstone = " -fcommon -Wno-error=implicit-function-declaration"
LDFLAGS_append_aarch64 = " -lnanomsg "
FILES_${PN} += " /lib/systemd/system "

FILESEXTRAPATHS_prepend := "${THISDIR}/ccsp-dhcp-mgr:"

SRC_URI += "\
        file://0001-ccsp-dhcp-manager-fix-non-moca-compile-error.patch \
"
