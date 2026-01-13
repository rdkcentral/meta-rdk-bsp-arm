require ccsp_common_genericarm.inc
CFLAGS:append:kirkstone = " -fcommon -Wno-error=implicit-function-declaration"
LDFLAGS:append:aarch64 = " -lnanomsg "
FILES:${PN}:append = " /lib/systemd/system "

FILESEXTRAPATHS:prepend := "${THISDIR}/ccsp-dhcp-mgr:"

SRC_URI += "\
        file://0001-ccsp-dhcp-manager-fix-non-moca-compile-error.patch \
"
