require meta-rdk-broadband/recipes-ccsp/ccsp/ccsp_common_genericarm.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://0001-scripts-fix-incorrect-call-arguments-for-utopia-dhcp.patch"

do_install:append () {
    # Test and Diagonastics XML 
       install -m 644 ${S}/config/TestAndDiagnostic_arm.XML ${D}/usr/ccsp/tad/TestAndDiagnostic.XML
       install -m 644 ${S}/scripts/selfheal_reset_counts.sh ${D}/usr/ccsp/tad/selfheal_reset_counts.sh
       install -m 0755 ${S}/scripts/selfheal_aggressive.sh ${D}/usr/ccsp/tad
       install -m 0664 ${S}/scripts/log_*.sh ${D}/usr/ccsp/tad
       install -m 0664 ${S}/scripts/uptime.sh ${D}/usr/ccsp/tad
       sed -i "/corrective_action.sh/a source /lib/rdk/t2Shared_api.sh" ${D}/usr/ccsp/tad/log_mem_cpu_info.sh 
       sed -i "/corrective_action.sh/a source /lib/rdk/t2Shared_api.sh" ${D}/usr/ccsp/tad/uptime.sh 
}
FILES:${PN}-ccsp += " \
                    ${prefix}/ccsp/tad/* \
                    /fss/gw/usr/ccsp/tad/* \
                    "
