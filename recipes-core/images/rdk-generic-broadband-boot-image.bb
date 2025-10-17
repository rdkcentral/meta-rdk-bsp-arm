SUMMARY = "A console-only image for the RDK-B yocto build which supports uploading boot time data of broadband image on wiki central"

require recipes-core/images/add-non-root-user-group.inc
require recipes-core/images/rdk-generic-broadband-image.bb

IMAGE_INSTALL_append = " \
    packagegroup-core-ssh-openssh \
    "
IMAGE_FEATURES += " ssh-server-openssh"

IMAGE_INSTALL += " librsvg e2fsprogs"

IMAGE_ROOTFS_SIZE = "14192"

SYSTEMD_TOOLS = "systemd-analyze systemd-bootchart"

# systemd-bootchart doesn't currently build with musl libc
SYSTEMD_TOOLS_remove_libc-musl = "systemd-bootchart"

IMAGE_INSTALL_append = " ${SYSTEMD_TOOLS}"

ROOTFS_POSTPROCESS_COMMAND += "add_systemd_services; "

add_systemd_services() {
                if [ -d ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/multi-user.target.wants/ ]; then
                        rm -f ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/multi-user.target.wants/connman.service;
                fi
                if [ ! -f ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/multi-user.target.wants/lighttpd.service ]; then
                        ln -sf ${IMAGE_ROOTFS}${systemd_unitdir}/system/lighttpd.service ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/multi-user.target.wants/lighttpd.service
                fi
}


