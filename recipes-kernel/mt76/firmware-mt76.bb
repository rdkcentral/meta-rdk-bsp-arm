SUMMARY = "Mediatek mt76 family firmware"
LICENSE = "Proprietary & ISC & GPLv2"
COMMENT = "Proprietary license allows the use of the firmware with conditions as in the license file at LIC_FILES_CHKSUM"
LIC_FILES_CHKSUM = "file://firmware/LICENSE;md5=1bff2e28f0929e483370a43d4d8b6f8e"

SRC_URI= " \
          git://github.com/openwrt/mt76.git;protocol=https \
        "

# 5.15: openwrt-23.05 branch as of 2024-06-19

# 6.18: mt76.git master as of 2026-08-12

SRCREV = "${@bb.utils.contains('DISTRO_FEATURES', 'kernel-6-18', 'b2704cf5a4068b672bf47ad5bf6b4802b6770a90', 'f1e1e67d97d1e9a8bb01b59ab20c45ebc985a958', d)}"

IS_KERNEL_6_18 = "${@bb.utils.contains('DISTRO_FEATURES', 'kernel-6-18', 'true', 'false', d)}"

S = "${WORKDIR}/git"
DEPENDS += "virtual/kernel"

inherit module

do_configure[noexec] = "1"
do_compile[noexec] = "1"

# Create a virtual package so consumers of this
# meta layer can provide their own firmware
# source for these devices (MT7915/MT7916)
PROVIDES = "virtual/firmware-mtk-wifi6"
RPROVIDES:${PN} = "virtual/firmware-mtk-wifi6"

do_install () {
    install -d ${D}${base_libdir}/firmware/mediatek
    install -m 755 ${S}/firmware/mt7915_eeprom.bin  ${D}${base_libdir}/firmware/mediatek
    install -m 755 ${S}/firmware/mt7915_eeprom_dbdc.bin  ${D}${base_libdir}/firmware/mediatek
    install -m 755 ${S}/firmware/mt7915_rom_patch.bin  ${D}${base_libdir}/firmware/mediatek
    install -m 755 ${S}/firmware/mt7915_wa.bin  ${D}${base_libdir}/firmware/mediatek
    install -m 755 ${S}/firmware/mt7915_wm.bin  ${D}${base_libdir}/firmware/mediatek

    install -m 755 ${S}/firmware/mt7916_eeprom.bin  ${D}${base_libdir}/firmware/mediatek
    install -m 755 ${S}/firmware/mt7916_rom_patch.bin  ${D}${base_libdir}/firmware/mediatek
    install -m 755 ${S}/firmware/mt7916_wa.bin  ${D}${base_libdir}/firmware/mediatek
    install -m 755 ${S}/firmware/mt7916_wm.bin  ${D}${base_libdir}/firmware/mediatek
}

do_install_mt7990_fw() {
    install -d ${D}${base_libdir}/firmware/mediatek/mt7996
    install -m 755 ${S}/firmware/mt7996/*.bin ${D}${base_libdir}/firmware/mediatek/mt7996
}

do_install:append = "${@bb.utils.contains('DISTRO_FEATURES', 'kernel-6-18', 'do_install_mt7990_fw', '', d)}"

FILES:${PN} += "${base_libdir}/firmware/mediatek/mt7915_eeprom.bin"
FILES:${PN} += "${base_libdir}/firmware/mediatek/mt7915_eeprom_dbdc.bin"
FILES:${PN} += "${base_libdir}/firmware/mediatek/mt7915_rom_patch.bin"
FILES:${PN} += "${base_libdir}/firmware/mediatek/mt7915_wa.bin"
FILES:${PN} += "${base_libdir}/firmware/mediatek/mt7915_wm.bin"

FILES:${PN} += "${base_libdir}/firmware/mediatek/mt7916_eeprom.bin"
FILES:${PN} += "${base_libdir}/firmware/mediatek/mt7916_rom_patch.bin"
FILES:${PN} += "${base_libdir}/firmware/mediatek/mt7916_wa.bin"
FILES:${PN} += "${base_libdir}/firmware/mediatek/mt7916_wm.bin"

FILES:${PN} += "${@bb.utils.contains('DISTRO_FEATURES', 'kernel-6-18', '${base_libdir}/firmware/mediatek/mt7996/*.bin', '', d)}"