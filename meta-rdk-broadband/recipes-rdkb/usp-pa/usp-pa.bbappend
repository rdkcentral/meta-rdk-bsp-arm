FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

EXTRA_OECONF:remove:kirkstone  = " --with-ccsp-platform=bcm --with-ccsp-arch=arm "

SRC_URI:append:class-target = " \
    file://10-wan-interface.conf \
    file://usp-pa-resolve-wan-ifname.sh \
"

USP_PA_SERVICE = "${D}${systemd_unitdir}/system/usp-pa.service"

do_install:append:class-target () {
       if [ ! -f "${USP_PA_SERVICE}" ]; then
               bbfatal "usp-pa.service not found"
       fi

       if ! grep -qE -- '--interface[[:space:]]+[^[:space:]]+' "${USP_PA_SERVICE}"; then
               bbfatal "usp-pa.service no longer passes --interface argument"
       fi

       sed -i -E 's|--interface[[:space:]]+[^[:space:]]+|--interface \${USP_PA_WAN_IF_NAME}|' "${USP_PA_SERVICE}"

       install -d ${D}${base_libdir}/rdk
       install -m 0755 ${WORKDIR}/usp-pa-resolve-wan-ifname.sh ${D}${base_libdir}/rdk/

       install -d ${D}${systemd_unitdir}/system/usp-pa.service.d
       install -m 0644 ${WORKDIR}/10-wan-interface.conf ${D}${systemd_unitdir}/system/usp-pa.service.d/10-wan-interface.conf
}

FILES:${PN}:append:class-target = " \
    ${base_libdir}/rdk/usp-pa-resolve-wan-ifname.sh \
    ${systemd_unitdir}/system/usp-pa.service.d/10-wan-interface.conf \
"
