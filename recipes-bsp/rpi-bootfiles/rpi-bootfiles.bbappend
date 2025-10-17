COMPATIBLE_MACHINE = "raspberrypi64-rdk-broadband"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# We specify our own setup in config.txt
SRC_URI:append = " file://config.txt"
DEPENDS:remove = "rpi-cmdline rpi-config"

DEPENDS:append = " u-boot"
# Define variables that would normally be sourced
# from rpi-base.inc

BOOTFILES_DIR_NAME ?= "bootfiles"
do_deploy[depends] = "u-boot:do_deploy"

do_deploy:append() {
        cp "${DEPLOY_DIR_IMAGE}/u-boot.bin"     "${DEPLOYDIR}/${BOOTFILES_DIR_NAME}"
        cp ${WORKDIR}/config.txt                "${DEPLOYDIR}/${BOOTFILES_DIR_NAME}"
        cp ${S}/bcm2711-rpi-*.dtb               "${DEPLOYDIR}/${BOOTFILES_DIR_NAME}"
        cp ${S}/bcm2712-rpi-*.dtb               "${DEPLOYDIR}/${BOOTFILES_DIR_NAME}"
        cp -r ${S}/overlays                     "${DEPLOYDIR}/${BOOTFILES_DIR_NAME}"

}

