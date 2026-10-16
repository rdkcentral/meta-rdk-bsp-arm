FILESEXTRAPATHS:prepend := "${THISDIR}/mesh-agent:"

SRC_URI:append = " \
    file://0001-Remove-PLATFORM_TURRIS-flags.patch;apply=no \
"

do_refplatform_meshagent_patches:append() {
    cd ${S}
    if [ ! -e genericarm_patch_applied ]; then
        bbnote "Patching 0001-Remove-PLATFORM_TURRIS-flags.patch"
        patch -p1 < ${WORKDIR}/0001-Remove-PLATFORM_TURRIS-flags.patch
        touch genericarm_patch_applied
    fi
}
