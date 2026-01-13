# Derived from meta-cmf-raspberrypi/conf/distro/include/rdk-rpi.inc
IMAGE_GEN_DEBUGFS = "0"

#preferred version for linux kirkstone build
PREFERRED_VERSION:libnl:kirkstone ?= "3.5.0"
PREFERRED_VERSION:jansson:kirkstone = "2.13.1"
PREFERRED_VERSION:googletest:kirkstone = "1.11.%"
PREFERRED_VERSION:net-snmp:kirkstone = "5.9.1"
PREFERRED_VERSION:icu:kirkstone ?= "58.2"
PREFERRED_VERSION:icu-native:kirkstone ?= "58.2"

#preferred version for meson
PREFERRED_VERSION_meson-native_kirkstone = "0.61.3"
PREFERRED_VERSION_meson_kirkstone = "0.61.3"

### preferred providers
PREFERRED_PROVIDER_libevent = "libevent"

PREFERRED_PROVIDER_virtual/iarmmgrs-hal = "iarmmgrs-hal-raspberrypi"
PREFERRED_PROVIDER_virtual/devicesettings-hal = "devicesettings-hal-raspberrypi"
PREFERRED_PROVIDER_virtual/gst-plugins-playersinkbin ?= "gst-plugins-playersinkbin-rpi"
PREFERRED_PROVIDER_virtual/wifi-hal ?= "wifi-hal-generic"
PREFERRED_PROVIDER_virtual/mfrlib ?= "mfrlibs-rpi"
PREFERRED_PROVIDER_virtual/mfrfwlib ?= "fwupgrade-lib"

# Use linux-backports to supply the MediaTek WiFi (mt76) driver
PREFERRED_PROVIDER_virtual/wifi-vendor-mtk ?= "linux-backports"

VIRTUAL-RUNTIME_mfrlib = "mfrlibs-rpi"
VIRTUAL-RUNTIME_dtcpmgr = ""

DISTRO_FEATURES:append = " parodus"
DISTRO_FEATURES:append = " ledmgr"
DISTRO_FEATURES:append = " build_rne"
DISTRO_FEATURES:append = " rdk-oss-ssa"

# RDKShell distro is enabled for RDK services
DISTRO_FEATURES:append = " rdkshell"
DISTRO_FEATURES:append = " offline_apps"

# no more onscreen terminal required for RDK services
DISTRO_FEATURES:append = " systemd-disable-getty"

DISTRO_FEATURES:append = " ctrlm"
DISTRO_FEATURES:append = " vendor_class_id_feature"
DISTRO_FEATURES:append = " ctrlm_voice_sdk"

DISTRO_FEATURES:append = " wifi"
DISTRO_FEATURES:append = " bluetooth"
DISTRO_FEATURES:append = " bluez5"

# Disable lxc-container-generator warnings
DISTRO_FEATURES_NATIVE:append = " disable-lxcgen-warnings"
DISTRO_FEATURES_NATIVE:append:kirkstone = " kirkstone"
DISTRO_FEATURES_NATIVESDK:append:kirkstone = " kirkstone"

# Turn OFF the hardening feature.
DISTRO_FEATURES_NATIVE:remove = " harden_dobby"

# Turn ON and OFF the hardening feature.
DISTRO_FEATURES_NATIVE:append=" harden_dobby"

# FOG support
DISTRO_FEATURES:append = " enable-fog"

# Enable Storage Manager support for FOG
DISTRO_FEATURES:append = " storage_sdc"

HOSTTOOLS += " python"

# globally disables this feature (for all images supported)
IMAGE_FEATURES:remove = "read-only-rootfs"

### others
ENABLE_UART = "1"

# 2024-11-11: meta-cmf-arm: usppa disabled due to erouter0 dependency
# DISTRO_FEATURES:append:broadband = " usppa"

# REFPLTV-1137: DLNA support for xupnp
DISTRO_FEATURES:append:broadband = " dlna"

DISTRO_FEATURES:append:broadband = " referencepltfm "

DISTRO_FEATURES:append:broadband = " ipv6"
DISTRO_FEATURES:append:broadband = " webconfig_bin"

# RDKB-51565,RDKB-50795: [HAL] Cellular Hal Implementation
DISTRO_FEATURES:append:broadband = " rdkb_cellular_manager_mm"
DISTRO_FEATURES:append:broadband = " cellular_mgr_lite"
DISTRO_FEATURES:append:broadband = " cellular_libqmi_support"

DISTRO_FEATURES:append:broadband = " rdkb_power_manager"
#DISTRO_FEATURES:append:broadband = " rdkb_gpon_manager"
DISTRO_FEATURES:append:broadband = " rdkb_wan_manager"
#DISTRO_FEATURES:append:broadband = " rdkb_configurable_wan_interface"
#DISTRO_FEATURES:append:broadband = " rdkb_voice_manager_dmltr104_v2"
DISTRO_FEATURES:append:broadband = " rdkb_xdsl_ppp_manager"
DISTRO_FEATURES:append:broadband = " fwupgrade_manager"
DISTRO_FEATURES:append:broadband = " rdkb_inter_device_manager"

DISTRO_FEATURES:append:broadband = " no_moca_support"

DISTRO_FEATURES:append:broadband = " rdk_ledmanager"
DISTRO_FEATURES:remove:aarch64 = " rdk_ledmanager"

# Platform manager and LanManager
#DISTRO_FEATURES:append:broadband = " pm_lan_mgr"

# Fix MeshAgent build errors
DISTRO_FEATURES:append:broadband = " WanFailOverSupportEnable"

# RDKBDEV-50: Adding DSLite Functionality and related TR-181 DataModel Parameters
DISTRO_FEATURES:append:broadband = " dslite"

# RDKBDEV-73 : Dynamic DNS : Standardization based on broadband-forum.
DISTRO_FEATURES:append:broadband = " ddns_broadband"

# RDKBDEV-83 : Device Gateway Association using Managed Device
DISTRO_FEATURES:append:broadband = " device_gateway_association"

# REFPLTB-1546 : WiFi HAL 3.0 support for RPI
DISTRO_FEATURES:append:broadband = " halVersion3"

# RDKBDEV-866: EasyMesh Controller support
DISTRO_FEATURES:append:broadband = " easymesh-controller"

# RDKB-44824: CoreNetLib move bb file location
DISTRO_FEATURES:append:broadband = " core-net-lib"

# DKBDEV-1455 : Support Broadband DAC
DISTRO_FEATURES:append:broadband = " dac"

# REFPLTB-1775: Sky team's fix for erouter0 IP issue
DISTRO_FEATURES:append:broadband = " RbusBuildFlagEnable"

#MeshAgent support for broadband
DISTRO_FEATURES:append:broadband = " meshwifi"

#rdk-wifi-libhostap support for broadband
DISTRO_FEATURES:append:broadband = " HOSTAPD_2_11"

# Use MLO/WiFi7 code
DISTRO_FEATURES:append:broadband = " CONFIG_IEEE80211BE"
# OneWifi feature
DISTRO_FEATURES:append:broadband = " OneWifi"

# 2025-07-10: Disable 802.11ACL feature due to MT7915/6 problem
DISTRO_FEATURES:append:broadband = " disable_nl80211_acl"

# RDKBDEV-942 RdkGponManager: Modify as per new WAN Manager Design
DISTRO_FEATURES:append:broadband = " WanManagerUnificationEnable"

# CpuPROCAnalyzer Support for broadband
DISTRO_FEATURES:append:broadband = " CPUPROCANALYZER_BROADBAND"

# RDKB-50999: WebConfig blob handler
DISTRO_FEATURES:append:broadband = " lld_support"

# RDKB-48800: Install DHCP Manager service file
# 2025-09: Disable DHCP Manager (RDKBNETWOR-3)
# DISTRO_FEATURES:append:broadband = " dhcp_manager"

# RDKBDEV-694: Adding Partner Default Ext
DISTRO_FEATURES:append:broadband = " partner_default_ext"

# RDKBDEV-755: Add Asterisk IP PBX voice HAL for TelcoVoiceManager
#DISTRO_FEATURES:append:broadband = " Asterisk"

# Remove WebUI (does not work without erouter0)
DISTRO_FEATURES:remove:broadband = " webui_jst"

# Add new EasyMesh
DISTRO_FEATURES:append:broadband = " EasyMesh"

# Add IEEE1905 AL
DISTRO_FEATURES:append:broadband = " with_alsap"

SESSIONMGR_WS_RPC_ENABLE = "1"

#REFPLTB-2784 : easymesh controller arch only supports with wifiagent
MACHINEOVERRIDES:append = "${@bb.utils.contains('DISTRO_FEATURES', 'OneWifi', ':onewifi', '' ,d)}"
DISTRO_FEATURES:remove:onewifi = " easymesh-controller"
