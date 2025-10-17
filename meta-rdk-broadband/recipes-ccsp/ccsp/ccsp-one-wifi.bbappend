require ccsp_common_genericarm.inc

FILESEXTRAPATHS_prepend := "${THISDIR}/ccsp-wifi-agent:${THISDIR}/files:"

DEPENDS_remove = " opensync-2.4.1"
DEPENDS_append = " mesh-agent"

CFLAGS_append = " -DWIFI_HAL_VERSION_3 -Wno-unused-function -D_PLATFORM_RASPBERRYPI_ -DWIFIDB_DIR=\\"/nvram/wifi\\""
LDFLAGS_append = " -ldl"
CFLAGS_append_aarch64 = " -Wno-error "

SRC_URI += " \
    file://checkwifi.sh \
    file://onewifi_pre_start.sh \
    file://wifi_defaults.txt \
"

do_install_append(){
    install -m 777 ${WORKDIR}/checkwifi.sh ${D}/usr/ccsp/wifi/
    install -m 777 ${WORKDIR}/onewifi_pre_start.sh ${D}/usr/ccsp/wifi/
    install -d ${D}/nvram
    install -m 644 ${WORKDIR}/wifi_defaults.txt ${D}/nvram/
}

FILES_${PN} += " \
    ${prefix}/ccsp/wifi/checkwifi.sh \
    ${prefix}/ccsp/wifi/onewifi_pre_start.sh \
    /usr/bin/wifi_events_consumer \
    /nvram/wifi_defaults.txt \
"
