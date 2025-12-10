inherit rdk-image

IMAGE_INSTALL += "\
    packagegroup-ap-extender \
"
remove_gateway_only_files() {
    rm -f ${IMAGE_ROOTFS}/lib/systemd/system/brlan0_check.service
    rm -f ${IMAGE_ROOTFS}/lib/rdk/brlan0_check.sh
    rm -f ${IMAGE_ROOTFS}/lib/systemd/system/RdkTelcoVoiceManager.service
    rm -f ${IMAGE_ROOTFS}/lib/systemd/system/RdkVlanManager.service
    rm -f ${IMAGE_ROOTFS}/lib/systemd/system/RdkWanManager.service
    rm -f ${IMAGE_ROOTFS}/lib/systemd/system/Ccsp*.service

}

ROOTFS_POSTPROCESS_COMMAND_append = "remove_gateway_only_files; "

