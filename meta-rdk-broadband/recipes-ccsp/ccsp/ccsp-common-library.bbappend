require ccsp_common_genericarm.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:${THISDIR}/files:"

DEPENDS:append = " breakpad"
DEPENDS:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'safec', ' safec', " ", d)}"

CXXFLAGS:append = " \
    -I${STAGING_INCDIR}/breakpad \
    -std=c++11 \
"

SRC_URI:append = " \
    file://ccsp_vendor.h \
    file://utopia.service \
    file://ethwan_intf.sh \
    file://brlan0_check.sh \
    file://brlan0_check.service \
    file://onewifi.service \
"

# Some systemd unit files invoke through '/bin/sh -c (...)' which causes
# the true process name not to appear in syslog (e.g journalctl).
# These patches update the unit files accordingly

SRC_URI:append = " file://0001-service-set-systemd-SyslogIdentifier.patch"

# Fix the path of the 'wan_started' monitor so it reads the correct path
# (it was moved into the /var/run to work under our read-only rootfs)
SRC_URI:append = " file://0002-systemd_units-correct-wan_started-path-for-read-only.patch"

# Remove call to migration_to_psm.sh, utopiaInitCheck.sh and log_psm_db.sh
SRC_URI:append = " file://0003-meta-rdk-bsp-arm-only-remove-pre-and-post-start-call.patch"

# Call pre-init script for CcspEthAgent (see ccsp-eth-agent.bbappend)
SRC_URI:append = " file://0004-meta-rdk-bsp-arm-only-systemd-CcspEthAgent-bring-up-.patch"

do_configure:prepend:aarch64() {
	sed -e '/len/ s/^\/*/\/\//' -i ${S}/source/ccsp/components/common/DataModel/dml/components/DslhObjRecord/dslh_objro_access.c
}
do_install:append:class-target () {
    # Config files and scripts
    install -m 777 ${S}/scripts/cli_start_arm.sh ${D}/usr/ccsp/cli_start.sh
    install -m 777 ${S}/scripts/cosa_start_arm.sh ${D}/usr/ccsp/cosa_start.sh

    # we need unix socket path
    echo "unix:path=/var/run/dbus/system_bus_socket" > ${S}/config/ccsp_msg.cfg
    install -m 644 ${S}/config/ccsp_msg.cfg ${D}/usr/ccsp/ccsp_msg.cfg
    install -m 644 ${S}/config/ccsp_msg.cfg ${D}/usr/ccsp/cm/ccsp_msg.cfg
    install -m 644 ${S}/config/ccsp_msg.cfg ${D}/usr/ccsp/mta/ccsp_msg.cfg
    install -m 644 ${S}/config/ccsp_msg.cfg ${D}/usr/ccsp/pam/ccsp_msg.cfg
    install -m 644 ${S}/config/ccsp_msg.cfg ${D}/usr/ccsp/tr069pa/ccsp_msg.cfg

    install -m 777 ${S}/systemd_units/scripts/ccspSysConfigEarly.sh ${D}/usr/ccsp/ccspSysConfigEarly.sh
    install -m 777 ${S}/systemd_units/scripts/ccspSysConfigLate.sh ${D}/usr/ccsp/ccspSysConfigLate.sh
    install -m 777 ${S}/systemd_units/scripts/utopiaInitCheck.sh ${D}/usr/ccsp/utopiaInitCheck.sh
    install -m 777 ${S}/systemd_units/scripts/ccspPAMCPCheck.sh ${D}/usr/ccsp/ccspPAMCPCheck.sh

    install -m 777 ${S}/systemd_units/scripts/ProcessResetCheck.sh ${D}/usr/ccsp/ProcessResetCheck.sh
    sed -i -e "s/source \/rdklogger\/logfiles.sh;syncLogs_nvram2/#source \/rdklogger\/logfiles.sh;syncLogs_nvram2/g" ${D}/usr/ccsp/ProcessResetCheck.sh
    # install systemd services
    install -d ${D}${systemd_unitdir}/system
    install -D -m 0644 ${S}/systemd_units/CcspCrSsp.service ${D}${systemd_unitdir}/system/CcspCrSsp.service
    install -D -m 0644 ${S}/systemd_units/CcspPandMSsp.service ${D}${systemd_unitdir}/system/CcspPandMSsp.service
    install -D -m 0644 ${S}/systemd_units/PsmSsp.service ${D}${systemd_unitdir}/system/PsmSsp.service
    install -D -m 0644 ${S}/systemd_units/rdkbLogMonitor.service ${D}${systemd_unitdir}/system/rdkbLogMonitor.service
    install -D -m 0644 ${S}/systemd_units/CcspTandDSsp.service ${D}${systemd_unitdir}/system/CcspTandDSsp.service
    install -D -m 0644 ${S}/systemd_units/CcspLMLite.service ${D}${systemd_unitdir}/system/CcspLMLite.service
    install -D -m 0644 ${S}/systemd_units/CcspTr069PaSsp.service ${D}${systemd_unitdir}/system/CcspTr069PaSsp.service
    install -D -m 0644 ${S}/systemd_units/snmpSubAgent.service ${D}${systemd_unitdir}/system/snmpSubAgent.service
    install -D -m 0644 ${S}/systemd_units/CcspEthAgent.service ${D}${systemd_unitdir}/system/CcspEthAgent.service
    install -D -m 0644 ${S}/systemd_units/notifyComp.service ${D}${systemd_unitdir}/system/notifyComp.service
    install -D -m 0644 ${S}/systemd_units/CcspTelemetry.service ${D}${systemd_unitdir}/system/CcspTelemetry.service

    #rfc service file
    install -D -m 0644 ${S}/systemd_units/rfc.service ${D}${systemd_unitdir}/system/rfc.service

    install -D -m 0644 ${S}/systemd_units/ProcessResetDetect.service ${D}${systemd_unitdir}/system/ProcessResetDetect.service
    install -D -m 0644 ${S}/systemd_units/ProcessResetDetect.path ${D}${systemd_unitdir}/system/ProcessResetDetect.path

    # Install wrapper for breakpad (disabled to support External Source build)
    #install -d ${D}${includedir}/ccsp
    #install -m 644 ${S}/source/breakpad_wrapper/include/breakpad_wrapper.h ${D}${includedir}/ccsp

    # Install "vendor information"
    install -m 0644 ${WORKDIR}/ccsp_vendor.h ${D}${includedir}/ccsp

    sed -i -- 's/NotifyAccess=.*/#NotifyAccess=main/g' ${D}${systemd_unitdir}/system/CcspCrSsp.service
    sed -i -- 's/notify.*/forking/g' ${D}${systemd_unitdir}/system/CcspCrSsp.service
    
    #copy rfc.properties into nvram
    sed -i '/ExecStartPre/ a\ExecStartPre=-/bin/cp /etc/rfc.properties /nvram/' ${D}${systemd_unitdir}/system/rfc.service
    sed -i 's#${PARODUS_START_LOG_FILE}#/rdklogs/logs/dcmrfc.log#g' ${D}${systemd_unitdir}/system/rfc.service
    sed -i 's/rfc.service /RFCbase.sh /g' ${D}${systemd_unitdir}/system/rfc.service
    #reduce sleep time to 12 sconds
    sed -i 's/300/12/g' ${D}${systemd_unitdir}/system/rfc.service
    sed -i "s/wan-initialized.target/multi-user.target/g" ${D}${systemd_unitdir}/system/rfc.service

    sed -i "/device.properties/a ExecStartPre=/bin/sh -c '(/usr/ccsp/utopiaInitCheck.sh)'"  ${D}${systemd_unitdir}/system/CcspPandMSsp.service
    #sed -i "/Description=CcspCrSsp service/a After=disable_systemd_restart_param.service" ${D}${systemd_unitdir}/system/CcspCrSsp.service

    #snmp module support
    sed -i "/tcp\:192.168.254.253\:705/a  ExecStart=\/usr\/bin\/snmp_subagent \&" ${D}${systemd_unitdir}/system/snmpSubAgent.service

    #Telemetry support
     sed -i "/Type=oneshot/a EnvironmentFile=\/etc/\device.properties" ${D}${systemd_unitdir}/system/CcspTelemetry.service
     sed -i "/EnvironmentFile=\/etc\/device.properties/a EnvironmentFile=\/etc\/dcm.properties" ${D}${systemd_unitdir}/system/CcspTelemetry.service
     sed -i "/EnvironmentFile=\/etc\/dcm.properties/a ExecStartPre=\/bin\/sh -c '\/bin\/touch \/rdklogs\/logs\/dcmscript.log'" ${D}${systemd_unitdir}/system/CcspTelemetry.service
     sed -i "s/ExecStart=\/bin\/sh -c '\/lib\/rdk\/dcm.service \&'/ExecStart=\/bin\/sh -c '\/lib\/rdk\/StartDCM.sh \>\> \/rdklogs\/logs\/telemetry.log \&'/g" ${D}${systemd_unitdir}/system/CcspTelemetry.service
     sed -i "s/wan-initialized.target/multi-user.target/g" ${D}${systemd_unitdir}/system/CcspTelemetry.service
     install -D -m 0644 ${S}/systemd_units/CcspXdnsSsp.service ${D}${systemd_unitdir}/system/CcspXdnsSsp.service

     install -d ${D}${base_libdir}/rdk
     install -m 755 ${WORKDIR}/ethwan_intf.sh ${D}${base_libdir}/rdk/
     install -m 755 ${WORKDIR}/brlan0_check.sh ${D}${base_libdir}/rdk/
#WanManager - RdkWanManager.service
     DISTRO_WAN_ENABLED="${@bb.utils.contains('DISTRO_FEATURES','rdkb_wan_manager','true','false',d)}"
     if [ $DISTRO_WAN_ENABLED = 'true' ]; then
     install -D -m 0644 ${S}/systemd_units/RdkWanManager.service ${D}${systemd_unitdir}/system/RdkWanManager.service
     sed -i "s/After=CcspCrSsp.service/After=CcspCrSsp.service utopia.service /g" ${D}${systemd_unitdir}/system/RdkWanManager.service
     sed -i "s/CcspPandMSsp.service/CcspCrSsp.service CcspPandMSsp.service/g" ${D}${systemd_unitdir}/system/CcspEthAgent.service
     install -D -m 0644 ${WORKDIR}/utopia.service ${D}${systemd_unitdir}/system/utopia.service
     install -D -m 0644 ${S}/systemd_units/RdkTelcoVoiceManager.service ${D}${systemd_unitdir}/system/RdkTelcoVoiceManager.service
     install -D -m 0644 ${S}/systemd_units/RdkVlanManager.service ${D}${systemd_unitdir}/system/RdkVlanManager.service
     fi
     DISTRO_FW_ENABLED="${@bb.utils.contains('DISTRO_FEATURES','fwupgrade_manager','true','false',d)}"
     if [ $DISTRO_FW_ENABLED = 'true' ]; then
         install -D -m 0644 ${S}/systemd_units/RdkFwUpgradeManager.service ${D}${systemd_unitdir}/system/RdkFwUpgradeManager.service
     fi

     install -D -m 0644 ${WORKDIR}/brlan0_check.service ${D}${systemd_unitdir}/system/brlan0_check.service
     ##### erouter0 ip issue
    sed -i '/Factory/a \
IsErouterRunningStatus=\`ifconfig erouter0 | grep RUNNING | grep -v grep | wc -l\` \
if [ \"\$IsErouterRunningStatus\" == 0 ]; then \
ethtool -s erouter0 speed 1000 \
fi' ${D}/usr/ccsp/ccspPAMCPCheck.sh

     DISTRO_OneWiFi_ENABLED="${@bb.utils.contains('DISTRO_FEATURES','OneWifi','true','false',d)}"
     if [ $DISTRO_OneWiFi_ENABLED = 'true' ]; then
         install -D -m 0644 ${WORKDIR}/onewifi.service ${D}${systemd_unitdir}/system/onewifi.service
     fi

    if ${@bb.utils.contains('DISTRO_FEATURES', 'webconfig_bin', 'true', 'false', d)}; then
        install -D -m 0644 ${S}/systemd_units/webconfig.service ${D}${systemd_unitdir}/system/webconfig.service
    fi
    install -D -m 0644 ${S}/systemd_units/wan-initialized.target ${D}${systemd_unitdir}/system/wan-initialized.target
    install -D -m 0644 ${S}/systemd_units/wan-initialized.path ${D}${systemd_unitdir}/system/wan-initialized.path

    if ${@bb.utils.contains('DISTRO_FEATURES', 'partner_default_ext', 'true', 'false', d)}; then
        sed -i "/^After=.*/a Requires=ApplySystemDefaults.service " ${D}${systemd_unitdir}/system/CcspPandMSsp.service
        if [ $DISTRO_OneWiFi_ENABLED = 'true' ]; then
            sed -i "/^After=/ s/$/ ApplySystemDefaults.service /g" ${D}${systemd_unitdir}/system/RdkWanManager.service
            sed -i "/^After=/ s/$/ ApplySystemDefaults.service /g" ${D}${systemd_unitdir}/system/RdkVlanManager.service
        fi
    fi

}

SYSTEMD_SERVICE:${PN}:append = " CcspCrSsp.service"
SYSTEMD_SERVICE:${PN}:append = " CcspPandMSsp.service"
SYSTEMD_SERVICE:${PN}:append = " PsmSsp.service"
SYSTEMD_SERVICE:${PN}:append = " rdkbLogMonitor.service"
SYSTEMD_SERVICE:${PN}:append = " CcspTandDSsp.service"
SYSTEMD_SERVICE:${PN}:append = " CcspLMLite.service"
SYSTEMD_SERVICE:${PN}:append = " CcspTr069PaSsp.service"
SYSTEMD_SERVICE:${PN}:append = " snmpSubAgent.service"
SYSTEMD_SERVICE:${PN}:append = " CcspEthAgent.service"
SYSTEMD_SERVICE:${PN}:append = " ProcessResetDetect.path"
SYSTEMD_SERVICE:${PN}:append = " ProcessResetDetect.service"
SYSTEMD_SERVICE:${PN}:append = " rfc.service"
SYSTEMD_SERVICE:${PN}:append = " notifyComp.service"
SYSTEMD_SERVICE:${PN}:append = " CcspXdnsSsp.service"
SYSTEMD_SERVICE:${PN}:append = " wan-initialized.path"
SYSTEMD_SERVICE:${PN}:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'rdkb_wan_manager', 'RdkWanManager.service utopia.service RdkVlanManager.service ', '', d)}"
SYSTEMD_SERVICE:${PN}:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'fwupgrade_manager', 'RdkFwUpgradeManager.service ', '', d)}"
SYSTEMD_SERVICE:${PN}:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'OneWifi', 'onewifi.service ', 'ccspwifiagent.service', d)}"
SYSTEMD_SERVICE:${PN}:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'webconfig_bin', 'webconfig.service', '', d)}"
SYSTEMD_SERVICE:${PN}:append = " brlan0_check.service"

FILES:${PN}:append = " \
    /usr/ccsp/ccspSysConfigEarly.sh \
    /usr/ccsp/ccspSysConfigLate.sh \
    /usr/ccsp/utopiaInitCheck.sh \
    /usr/ccsp/ccspPAMCPCheck.sh \
    /usr/ccsp/ProcessResetCheck.sh \
    ${base_libdir}/rdk/ethwan_intf.sh \
    ${base_libdir}/rdk/brlan0_check.sh \
    ${systemd_unitdir}/system/brlan0_check.service \
    ${systemd_unitdir}/system/CcspCrSsp.service \
    ${systemd_unitdir}/system/CcspPandMSsp.service \
    ${systemd_unitdir}/system/PsmSsp.service \
    ${systemd_unitdir}/system/rdkbLogMonitor.service \
    ${systemd_unitdir}/system/CcspTandDSsp.service \
    ${systemd_unitdir}/system/CcspLMLite.service \
    ${systemd_unitdir}/system/CcspTr069PaSsp.service \
    ${systemd_unitdir}/system/snmpSubAgent.service \
    ${systemd_unitdir}/system/CcspEthAgent.service \
    ${systemd_unitdir}/system/notifyComp.service \
    ${systemd_unitdir}/system/ProcessResetDetect.path \
    ${systemd_unitdir}/system/ProcessResetDetect.service \
    ${systemd_unitdir}/system/rfc.service \
    ${systemd_unitdir}/system/CcspTelemetry.service \
    ${systemd_unitdir}/system/CcspXdnsSsp.service \
    ${systemd_unitdir}/system/wan-initialized.target \
    ${systemd_unitdir}/system/wan-initialized.path \
"
FILES:${PN}:append = "${@bb.utils.contains('DISTRO_FEATURES', 'rdkb_wan_manager', ' ${systemd_unitdir}/system/RdkWanManager.service ${systemd_unitdir}/system/utopia.service ${systemd_unitdir}/system/RdkVlanManager.service ${systemd_unitdir}/system/RdkTelcoVoiceManager.service ', '', d)}"
FILES:${PN}:append = "${@bb.utils.contains('DISTRO_FEATURES', 'fwupgrade_manager', ' ${systemd_unitdir}/system/RdkFwUpgradeManager.service ', '', d)}"
