# ----------------------------------------------------------------------------

SYSTEMD_TOOLS = "systemd-analyze systemd-bootchart"

# systemd-bootchart doesn't currently build with musl libc
SYSTEMD_TOOLS_remove_libc-musl = "systemd-bootchart"

IMAGE_INSTALL_append = " ${SYSTEMD_TOOLS}"

#REFPLTB-349 Needed for Firmware upgrade - to create file system of dual partition
IMAGE_INSTALL_append = " e2fsprogs breakpad-staticdev"

#Opensync Integration 
IMAGE_INSTALL_append =" ${@bb.utils.contains('DISTRO_FEATURES', 'Opensync', ' opensync openvswitch', '', d)}"
# Traverse todo: add mt76 back
#Beegol agent Support
IMAGE_INSTALL_append =" ${@bb.utils.contains('DISTRO_FEATURES', 'beegol_agent', ' ba', '', d)}"

#Asterisk Support
IMAGE_INSTALL_append =" ${@bb.utils.contains('DISTRO_FEATURES', 'Asterisk', ' hal-voice-asterisk', '', d)}"

# For Rust environment verification
IMAGE_INSTALL_append = " rust-hello-world"

IMAGE_INSTALL_append = " efi-image-manager"

# Placeholder for resolv.conf
IMAGE_INSTALL_append = " resolvconf-placeholder"

require image-exclude-files.inc

remove_unused_file() {
    for i in ${REMOVED_FILE_LIST} ; do rm -rf ${IMAGE_ROOTFS}/$i ; done
}

ROOTFS_POSTPROCESS_COMMAND_append = "remove_unused_file; "


ROOTFS_POSTPROCESS_COMMAND_append = "add_busybox_fixes; "

add_busybox_fixes() {
                if [  -d ${IMAGE_ROOTFS}/bin ]; then
			cd  ${IMAGE_ROOTFS}/bin
                        rm ${IMAGE_ROOTFS}/bin/ps
			ln -sf  /bin/busybox.nosuid  ps
			ln -sf  /bin/busybox.nosuid  ${IMAGE_ROOTFS}/usr/bin/awk
			cd -
                fi
}

# ----------------------------------------------------------------------------
