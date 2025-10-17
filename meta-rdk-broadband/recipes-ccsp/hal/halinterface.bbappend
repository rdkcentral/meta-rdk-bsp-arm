ALLOW_EMPTY_${PN} = "1"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += "file://sta-network.patch;apply=no"

#This is workaround for missing do_patch when RDK uses external sources
do_rpi_patches() {
    cd ${S}
        if [ ! -e patch_applied ]; then
            patch -p1 < ${WORKDIR}/sta-network.patch
            touch patch_applied
        fi
}
addtask rpi_patches after do_unpack before do_compile

CFLAGS_append = " ${@bb.utils.contains('DISTRO_FEATURES', 'halVersion3', ' -DWIFI_HAL_VERSION_3 ', '', d)}"
