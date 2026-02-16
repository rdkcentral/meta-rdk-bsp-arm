# This is just to satisfy Yocto's want for a valid source
# All relevant files to this port are maintained in this layer
SRC_URI:append = " \
    ${CMF_GIT_ROOT}/rdkb/devices/raspberrypi/sysint;module=.;protocol=${CMF_GIT_PROTOCOL};branch=${CMF_GIT_BRANCH};destsuffix=git/devicegenericarm;name=sysintdevicegenericarm \
"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# These files relate to managing RDK related btrfs volumes (/nvram, /rdklogs etc.)
SRC_URI:append = "file://btrfs-subvolume.service \
                  file://nvram-subvol-init.sh \
                  file://resize-disk.sh \
                  "

SRCREV_sysintdevicegenericarm = "${AUTOREV}"
SRCREV_FORMAT = "sysintgeneric_sysintdevicegenericarm"

RDEPENDS:${PN}:append = " gptfdisk util-linux btrfs-tools multipath-tools"
do_install:append() {
    install -d ${D}${systemd_unitdir}/system
    install -m 0755 ${S}/device/lib/rdk/* ${D}${base_libdir}/rdk
    install -m 0755 ${S}/rfc.service ${D}${base_libdir}/rdk
    install -m 0755 ${S}/utils.sh ${D}${base_libdir}/rdk
    install -m 0755 ${S}/getpartnerid.sh ${D}${base_libdir}/rdk
    install -m 0755 ${S}/device/systemd_units/* ${D}${systemd_unitdir}/system/
    echo "BOX_TYPE=genericarm" >> ${D}${sysconfdir}/device.properties
    echo "MODEL_NAME=RPI" >> ${D}${sysconfdir}/device.properties

    ${@bb.utils.contains('DISTRO_FEATURES', 'OneWifi', 'echo "OneWiFiEnabled=true" >> ${D}${sysconfdir}/device.properties', '', d)}
    echo "MODEL_NUM=RPI_MOD" >> ${D}${sysconfdir}/device.properties

    #For rfc Support
    sed -i '/DEVICE_TYPE/c\DEVICE_TYPE=broadband' ${D}${sysconfdir}/device.properties
    sed -i '/LOG_PATH/c\LOG_PATH=/rdklogs/logs/' ${D}${sysconfdir}/device.properties
    #Erouter0 info
    sed -i "/f11/c\       mac=\`ifconfig \$WANINTERFACE | grep HWaddr | cut -d \" \" -f7\`" ${D}${base_libdir}/rdk/utils.sh
    sed -i '/Device.X_CISCO_COM_CableModem.MACAddress/{n;s/.*/    elif [ "$BOX_TYPE" = "XF3" ]; then/}' ${D}${base_libdir}/rdk/utils.sh

    # BTRFS management
    install -d ${D}${base_libdir}/rdk/btrfs
    install -m 0755 ${WORKDIR}/nvram-subvol-init.sh ${D}${base_libdir}/rdk/btrfs
    install -m 0755 ${WORKDIR}/resize-disk.sh ${D}${base_libdir}/rdk/btrfs

    install -m 0644 ${WORKDIR}/btrfs-subvolume.service ${D}${systemd_unitdir}/system

    # The btrfs image is fully read-only, so we need to create these folders ahead of time
    install -d ${D}/nvram
    touch ${D}/nvram/.placeholder
    install -d ${D}/rdklogs
    touch ${D}/rdklogs/.placeholder
    install -d ${D}/rdklogs/logs2
    touch ${D}/rdklogs/logs2/.placeholder
    install -d ${D}/volumes/toplevel
    touch ${D}/volumes/toplevel/.placeholder

    # We will put /nvram2/logs into /rdklogs/logs2
    install -d ${D}/nvram2
    touch ${D}/nvram2/.placeholder
    ln -s -r ${D}/rdklogs/logs2 ${D}/nvram2/logs

    #self heal support
    install -d ${D}/usr/ccsp/tad
    install -m 0755 ${S}/devicegenericarm/lib/rdk/corrective_action.sh ${D}/usr/ccsp/tad
    install -m 0755 ${S}/devicegenericarm/lib/rdk/self_heal_connectivity_test.sh ${D}/usr/ccsp/tad
    install -m 0755 ${S}/devicegenericarm/lib/rdk/resource_monitor.sh ${D}/usr/ccsp/tad
    install -m 0755 ${S}/devicegenericarm/lib/rdk/task_health_monitor.sh ${D}/usr/ccsp/tad
    install -m 0644 ${S}/devicegenericarm/systemd_units/disable_systemd_restart_param.service ${D}${systemd_unitdir}/system
    install -m 0755 ${S}/devicegenericarm/lib/rdk/disable_systemd_restart_param.sh ${D}${base_libdir}/rdk
    install -m 0755 ${S}/devicegenericarm/lib/rdk/run_rm_key.sh   ${D}${base_libdir}/rdk
}


# TODO add back swupdate.service
SYSTEMD_SERVICE:${PN}:append = " btrfs-subvolume.service"
SYSTEMD_SERVICE:${PN}:remove:broadband = "dropbear.service"
SYSTEMD_SERVICE:${PN}:remove:broadband = "ntp-data-collector.service"
SYSTEMD_SERVICE:${PN}:bootbroadband:append = " boot-time-upload.service monitor-upload.service"

FILES:${PN}:append = " ${systemd_unitdir}/system/* /usr/ccsp/tad/* /nvram/.placeholder /rdklogs/.placeholder /volumes/toplevel/.placeholder"
FILES:${PN}:append = " /rdklogs/logs2/.placeholder /nvram2/.placeholder /nvram/logs /nvram2/logs"
FILES:${PN}:append:bootbroadband = " ${systemd_unitdir}/system/*"
