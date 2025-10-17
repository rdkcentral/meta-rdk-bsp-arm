CFLAGS_append_aarch64 = " -D_64BIT_ARCH_SUPPORT_ "
CFLAGS_append = " ${@bb.utils.contains('DISTRO_FEATURES', 'halVersion3', ' -DWIFI_HAL_VERSION_3 ', '', d)}"
