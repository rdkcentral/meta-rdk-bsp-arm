require ccsp_common_genericarm.inc
CFLAGS_aarch64_append = " -Werror=format-truncation=1 -g"
CFLAGS:remove = "-D_PLATFORM_RASPBERRYPI_"

FILESEXTRAPATHS_prepend := "${THISDIR}/ccsp-eth-agent:"

SRC_URI_append = "\
    file://0001-genericarm-register-link-handler-callback.patch;apply=no \
    file://0002-genericarm-increase-maximum-number-of-Ethernet-interfaces.patch;apply=no \
    "

do_genericarm_patches() {
    cd ${S}
    if [ ! -e genericarm_patch_applied ]; then
        bbnote "Applying 0001-genericarm-register-link-handler-callback.patch into ${S}"
        patch -p1 -i ${WORKDIR}/0001-genericarm-register-link-handler-callback.patch
        bbnote "Applying 0002-genericarm-increase-maximum-number-of-Ethernet-interfaces.patch into ${S}"
        patch -p1 -i ${WORKDIR}/0002-genericarm-increase-maximum-number-of-Ethernet-interfaces.patch
        touch genericarm_patch_applied
    fi
}
addtask genericarm_patches after do_unpack before do_compile

