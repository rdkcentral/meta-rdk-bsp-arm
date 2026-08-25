ARMFILESPATHS := "${THISDIR}/linux-yocto-6.18:"
FILESEXTRAPATHS:prepend:armefi64 = "${ARMFILESPATHS}"

SRC_URI:append:armefi64 = " \
    file://defconfig \
    file://an7581.cfg \
    file://qemu.cfg \
    file://rpi.cfg \
"
