# Provide the kernel autoconf.h for use by other
# packages (required by utopia)

do_install:append() {
    install -d ${D}${includedir}
    install -m 0644 ${B}/include/generated/autoconf.h ${D}${includedir}/autoconf.h
}

sysroot_stage_all:append () {
    install -d ${SYSROOT_DESTDIR}${includedir}
    install -m 0644 ${D}${includedir}/autoconf.h ${SYSROOT_DESTDIR}${includedir}/autoconf.h
}

PACKAGES:append = " kernel-autoconf"
PROVIDES:append = " kernel-autoconf"

FILES:kernel-autoconf = "${includedir}/autoconf.h"
