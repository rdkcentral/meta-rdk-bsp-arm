CFLAGS_append = " ${@bb.utils.contains('DISTRO_FEATURES', 'webconfig_bin', '-DPLATFORM_RASPBERRYPI', '', d)}"
