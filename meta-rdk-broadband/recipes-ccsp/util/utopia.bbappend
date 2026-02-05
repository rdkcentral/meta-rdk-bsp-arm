require meta-rdk-broadband/recipes-ccsp/ccsp/ccsp_common_genericarm.inc

DEPENDS:append = " kernel-autoconf utopia-headers libsyswrapper"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI:append = " \
    file://0001-scripts-lan_handler-treat-generic-Arm-boards-Ten64-q.patch \
    file://0002-lan_handler-refresh-fix-lan-handler-for-rpi.patch.patch \
    file://0003-utopia-duplicate-or-replace-_PLATFORM_RASPBERRYPI_-a.patch \
    file://0004-scripts-utopia_init-do-nvram-restore_reboot-and-drop.patch \
    file://0005-scripts-lan_handler-create-flag-files-for-lan-start-.patch \
    file://0006-dhcp-place-dnsmasq.conf-in-RAM-var-volatile.patch \
    file://0007-igd-place-IGD-temporary-files-under-var-volatile.patch \
    file://0008-RDKBDEV-XXXX-remove-usages-of-get_current_wan_ifname.patch \
    file://0009-service-dhcpv6_client-log-to-syslog-instead-of-console.patch \
    file://system_defaults \
"

LDFLAGS:append = " \
    -lsecure_wrapper \
"

CFLAGS:append = " -Wno-error=unused-function "
CFLAGS:remove = " ${@bb.utils.contains('DISTRO_FEATURES', 'bci', '-DWAN_FAILOVER_SUPPORTED', '', d)}"

do_install:append() {
    # Don't install header files which are provided by utopia-headers
    rm -f ${D}${includedir}/utctx/autoconf.h
    rm -f ${D}${includedir}/utctx/utctx.h
    rm -f ${D}${includedir}/utctx/utctx_api.h
    rm -f ${D}${includedir}/utctx/utctx_rwlock.h

    # Config files and scripts
    install -d ${D}/rdklogs
    install -d ${D}/fss/gw/bin
    install -d ${D}/fss/gw/usr/bin
    install -d ${D}/fss/gw/usr/sbin
    install -d ${D}/fss/gw/etc/utopia/service.d
    install -d ${D}/var/spool/cron/crontabs
    install -d -m 0777 ${D}/minidumps

    install -d ${D}${sbindir}/
    install -d ${D}${sysconfdir}/utopia/service.d
    install -d ${D}${sysconfdir}/utopia/registration.d
    install -d ${D}${sysconfdir}/utopia/post.d
    install -d ${D}${sysconfdir}/IGD
    install -d ${D}${sysconfdir}/utopia/service.d/service_bridge
    install -d ${D}${sysconfdir}/utopia/service.d/service_ddns
    install -d ${D}${sysconfdir}/utopia/service.d/service_dhcp_server
    install -d ${D}${sysconfdir}/utopia/service.d/service_lan
    install -d ${D}${sysconfdir}/utopia/service.d/service_multinet
    install -d ${D}${sysconfdir}/utopia/service.d/service_syslog
    install -d ${D}${sysconfdir}/utopia/service.d/service_wan

    install -m 755 ${S}/source/scripts/init/system/utopia_init.sh ${D}${sysconfdir}/utopia/
    install -m 644 ${S}/source/scripts/init/defaults/system_defaults_arm ${D}${sysconfdir}/utopia/system_defaults
    install -m 755 ${S}/source/scripts/init/service.d/*.sh ${D}${sysconfdir}/utopia/service.d/
    install -m 755 ${S}/source/scripts/init/service.d/service_bridge/*.sh ${D}${sysconfdir}/utopia/service.d/service_bridge
    install -m 755 ${S}/source/scripts/init/service.d/service_ddns/*.sh ${D}${sysconfdir}/utopia/service.d/service_ddns
    install -m 755 ${S}/source/scripts/init/service.d/service_dhcp_server/* ${D}${sysconfdir}/utopia/service.d/service_dhcp_server
    install -m 755 ${S}/source/scripts/init/service.d/service_lan/*.sh ${D}${sysconfdir}/utopia/service.d/service_lan
    install -m 755 ${S}/source/scripts/init/service.d/service_multinet/*.sh ${D}${sysconfdir}/utopia/service.d/service_multinet
    install -m 755 ${S}/source/scripts/init/service.d/service_syslog/*.sh ${D}${sysconfdir}/utopia/service.d/service_syslog
    install -m 755 ${S}/source/scripts/init/service.d/service_wan/*.sh ${D}${sysconfdir}/utopia/service.d/service_wan
    install -m 755 ${S}/source/scripts/init/service.d/service_firewall/firewall_log_handle.sh ${D}${sysconfdir}/utopia/service.d/
    install -m 644 ${S}/source/igd/src/inc/*.xml ${D}${sysconfdir}/IGD
    install -D -m 644 ${S}/source/scripts/init/syslog_conf/syslog.conf_default ${D}/fss/gw/${sysconfdir}/syslog.conf.${BPN}
    install -m 755 ${S}/source/scripts/init/syslog_conf/log_start.sh ${D}${sbindir}/
    install -m 755 ${S}/source/scripts/init/syslog_conf/log_handle.sh ${D}${sbindir}/
    install -m 755 ${S}/source/scripts/init/syslog_conf/syslog_conf_tool.sh ${D}${sbindir}/
    install -m 644 ${S}/source/scripts/init/service.d/event_flags ${D}${sysconfdir}/utopia/service.d/
    install -m 644 ${S}/source/scripts/init/service.d/rt_tables ${D}${sysconfdir}/utopia/service.d/rt_tables
    install -m 755 ${S}/source/scripts/init/service.d/service_cosa_arm.sh ${D}${sysconfdir}/utopia/service.d/service_cosa.sh
    install -m 755 ${S}/source/scripts/init/system/need_wifi_default.sh ${D}${sysconfdir}/utopia/
    touch ${D}${sysconfdir}/dhcp_static_hosts
    install -m 755 ${S}/source/scripts/init/service.d/service_bridge_rpi.sh ${D}${sysconfdir}/utopia/service.d/service_bridge.sh
    install -m 755 ${S}/source/scripts/init/service.d/service_dynamic_dns.sh ${D}${sysconfdir}/utopia/service.d/service_dynamic_dns.sh     

    # Creating symbolic links to install files in specific directory as in legacy builds
    ln -sf /usr/bin/10_firewall ${D}${sysconfdir}/utopia/post.d/10_firewall
    ln -sf /usr/bin/service_multinet_exec ${D}${sysconfdir}/utopia/service.d/service_multinet_exec
    ln -sf /usr/bin/10_mcastproxy ${D}${sysconfdir}/utopia/post.d/10_mcastproxy
    ln -sf /usr/bin/10_mldproxy ${D}${sysconfdir}/utopia/post.d/10_mldproxy
    ln -sf /usr/bin/15_igd ${D}${sysconfdir}/utopia/post.d/15_igd
    ln -sf /usr/bin/15_misc ${D}${sysconfdir}/utopia/post.d/15_misc
    ln -sf /usr/bin/02_bridge ${D}${sysconfdir}/utopia/registration.d/02_bridge
    ln -sf /usr/bin/02_forwarding ${D}${sysconfdir}/utopia/registration.d/02_forwarding
    ln -sf /usr/bin/02_ipv4 ${D}${sysconfdir}/utopia/registration.d/02_ipv4
    ln -sf /usr/bin/02_lanHandler ${D}${sysconfdir}/utopia/registration.d/02_lanHandler
    ln -sf /usr/bin/02_multinet ${D}${sysconfdir}/utopia/registration.d/02_multinet
    ln -sf /usr/bin/02_wan ${D}${sysconfdir}/utopia/registration.d/02_wan
    ln -sf /usr/bin/15_ccsphs ${D}${sysconfdir}/utopia/registration.d/15_ccsphs
    ln -sf /usr/bin/15_ddnsclient ${D}${sysconfdir}/utopia/registration.d/15_ddnsclient
    ln -sf /usr/bin/15_dhcp_server ${D}${sysconfdir}/utopia/registration.d/15_dhcp_server
    ln -sf /usr/bin/15_hotspot ${D}${sysconfdir}/utopia/registration.d/15_hotspot
    ln -sf /usr/bin/15_ssh_server ${D}${sysconfdir}/utopia/registration.d/15_ssh_server
    ln -sf /usr/bin/15_wecb ${D}${sysconfdir}/utopia/registration.d/15_wecb
    ln -sf /usr/bin/20_routing ${D}${sysconfdir}/utopia/registration.d/20_routing
    ln -sf /usr/bin/25_crond ${D}${sysconfdir}/utopia/registration.d/25_crond
    ln -sf /usr/bin/33_cosa ${D}${sysconfdir}/utopia/registration.d/33_cosa
    ln -sf /usr/bin/syscfg ${D}${bindir}/syscfg_create
    ln -sf /usr/bin/syscfg ${D}${bindir}/syscfg_destroy
    ln -sf /usr/bin/firewall ${D}/fss/gw/usr/bin/firewall
    ln -sf /usr/bin/GenFWLog ${D}/fss/gw/usr/bin/GenFWLog
    ln -sf /etc/utopia/service.d/log_capture_path.sh ${D}/fss/gw/etc/utopia/service.d/log_capture_path.sh
    ln -sf /etc/utopia/service.d/log_env_var.sh ${D}/fss/gw/etc/utopia/service.d/log_env_var.sh
    ln -sf /usr/bin/syseventd_fork_helper ${D}/fss/gw/usr/bin/syseventd_fork_helper
    ln -sf /usr/sbin/log_start.sh ${D}/fss/gw/usr/sbin/log_start.sh
    ln -sf /usr/sbin/log_handle.sh ${D}/fss/gw/usr/sbin/log_handle.sh
    #ln -sf /etc/syslog.conf.utopia ${D}/fss/gw/etc/syslog.conf.utopia
    ln -sf /etc/utopia/service.d/misc_handler.sh ${D}/fss/gw/etc/utopia/service.d/misc_handler.sh
    ln -sf /usr/bin/15_dynamic_dns ${D}${sysconfdir}/utopia/registration.d/15_dynamic_dns
    
    install -m 755 ${WORKDIR}/system_defaults ${D}${sysconfdir}/utopia/system_defaults
    sed -i -e "s/dropbear -E -s -b \/etc\/sshbanner.txt/dropbear -R -E /g" ${D}/etc/utopia/service.d/service_sshd.sh
    sed -i -e "/dropbear -R -E  -a -r/s/$/ -B/" ${D}${sysconfdir}/utopia/service.d/service_sshd.sh


    #Backup and Restore feature related
    sed -i "/rm -f \/nvram\/syscfg.db.prev/a \ \trm -f \/nvram\/hostapd0.conf.prev \ \n \trm -f \/nvram\/hostapd1.conf.prev" ${D}${sysconfdir}/utopia/utopia_init.sh

    #WanManager Feature
    DISTRO_WAN_ENABLED="${@bb.utils.contains('DISTRO_FEATURES','rdkb_wan_manager','true','false',d)}"
    if [ $DISTRO_WAN_ENABLED = 'true' ]; then

    # Remove redundant scripts (not relevant to our platform)
    rm ${D}${sysconfdir}/utopia/service.d/service_dhcpv6_client_arm.sh
    rm ${D}${sysconfdir}/utopia/service.d/service_dhcpv6_client_arm_bci.sh
    rm ${D}${sysconfdir}/utopia/service.d/service_potd.sh

    sed -i '/log_capture_path.sh/a \
mkdir -p \/nvram \
cp \/usr\/ccsp\/ccsp_msg.cfg \/tmp \
touch \/tmp\/cp_subsys_ert \
ln -s \/var\/spool\/cron\/crontabs \/ \
mkdir -p \/var\/run\/firewall \
mkdir -p \/opt\/secure \
touch \/nvram\/ETHWAN_ENABLE ' ${D}${sysconfdir}/utopia/utopia_init.sh

    sed -i '/sshd-start/a \
\#TODO: Need to replaced once the sky version 2 code is available \
sysevent set lan-start 0 \
sysevent set bridge-stop 0 \
sysevent set bridge_mode 0 \
sysevent set dhcp_server-resync 0 \
sysevent set ethwan-initialized 1 \
syscfg set eth_wan_enabled true \
syscfg commit \
# Creating the symbolic link of \/etc\/dibbler in \/tmp directory for dibbler-client \
ln -s \/etc\/dibbler \/tmp \
#To avoid sigsegv crash with dibbler-client \
touch \/etc\/dibbler\/radvd.conf \
echo 1 > \/proc\/sys\/net\/ipv4\/ip_forward ' ${D}${sysconfdir}/utopia/utopia_init.sh
    fi

    echo "touch -f /tmp/utopia_inited" >> ${D}${sysconfdir}/utopia/utopia_init.sh
}

do_install:append:aarch64 () {
	#Enabling rbus support on 64bit arch
	DISTRO_WAN_ENABLED="${@bb.utils.contains('DISTRO_FEATURES','rdkb_wan_manager','true','false',d)}"
        if [ $DISTRO_WAN_ENABLED = 'true' ]; then
		sed -i '/mkdir -p \/nvram/a \
touch \/nvram\/rbus_support ' ${D}${sysconfdir}/utopia/utopia_init.sh
	fi
}

do_install:append () {
    sed -i "s/\$user_password_3=/\$user_password_3=password/g"  ${D}${sysconfdir}/utopia/system_defaults
}

pkg_postinst:ontarget:${PN} () {
    #!/bin/sh
    #Stub postinst to suppress default
    exit 0
}

FILES:${PN} += " \
    /rdklogs/ \
    /fss/gw/bin/ \
    /fss/gw/usr/bin/ \
    /fss/gw/usr/sbin/ \
    /var/spool/cron/crontabs \
    /fss/gw/etc/utopia/* \
    /etc/utopia/system_defaults \
    /minidumps/ \
"

# 0001-fix-lan-handler-for-rpi.patch contains bash specific syntax which doesn't run with busybox sh
RDEPENDS:${PN} += "bash"

