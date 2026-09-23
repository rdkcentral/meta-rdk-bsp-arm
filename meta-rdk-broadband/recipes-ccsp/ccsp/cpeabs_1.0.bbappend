CFLAGS:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'webconfig_bin', '-D_PLATFORM_GENERICARM_', '', d)}"
