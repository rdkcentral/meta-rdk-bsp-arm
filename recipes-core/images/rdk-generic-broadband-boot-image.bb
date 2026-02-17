SUMMARY = "A console-only image for the RDK-B yocto build which supports uploading boot time data of broadband image on wiki central"

require recipes-core/images/add-non-root-user-group.inc
require recipes-core/images/rdk-generic-broadband-image.bb

IMAGE_INSTALL:append = " \
    packagegroup-core-ssh-openssh \
    "
IMAGE_FEATURES += " ssh-server-openssh"

IMAGE_INSTALL += " librsvg e2fsprogs"

IMAGE_ROOTFS_SIZE = "14192"

SYSTEMD_TOOLS = "systemd-analyze systemd-bootchart"

# systemd-bootchart doesn't currently build with musl libc
SYSTEMD_TOOLS:remove:libc-musl = "systemd-bootchart"

IMAGE_INSTALL:append = " ${SYSTEMD_TOOLS}"


