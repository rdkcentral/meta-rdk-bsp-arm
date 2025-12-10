# Derived from meta-cmf-raspberrypi/conf/distro/include/rdk-rpi.inc
IMAGE_GEN_DEBUGFS = "0"

#preferred version for linux kirkstone build
PREFERRED_VERSION_libnl_kirkstone ?= "3.5.0"
PREFERRED_VERSION_jansson_kirkstone = "2.13.1"
PREFERRED_VERSION_googletest_kirkstone = "1.11.%"
PREFERRED_VERSION_net-snmp_kirkstone = "5.9.1"
PREFERRED_VERSION_icu_kirkstone ?= "58.2"
PREFERRED_VERSION_icu-native_kirkstone ?= "58.2"

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

DISTRO_FEATURES_append = " parodus"
DISTRO_FEATURES_append = " ledmgr"
DISTRO_FEATURES_append = " build_rne"
DISTRO_FEATURES_append = " rdk-oss-ssa"

# RDKShell distro is enabled for RDK services
DISTRO_FEATURES_append = " rdkshell"
DISTRO_FEATURES_append = " offline_apps"

# no more onscreen terminal required for RDK services
DISTRO_FEATURES_append = " systemd-disable-getty"

DISTRO_FEATURES_append = " ctrlm"
DISTRO_FEATURES_append = " vendor_class_id_feature"
DISTRO_FEATURES_append = " ctrlm_voice_sdk"

DISTRO_FEATURES_append = " wifi"
DISTRO_FEATURES_append = " bluetooth"
DISTRO_FEATURES_append = " bluez5"

# Disable lxc-container-generator warnings
DISTRO_FEATURES_NATIVE_append = " disable-lxcgen-warnings"
DISTRO_FEATURES_NATIVE_append_kirkstone = " kirkstone"
DISTRO_FEATURES_NATIVESDK_append_kirkstone = " kirkstone"

# Turn OFF the hardening feature.
DISTRO_FEATURES_NATIVE_remove = " harden_dobby"

# Turn ON and OFF the hardening feature.
DISTRO_FEATURES_NATIVE_append=" harden_dobby"

# FOG support
DISTRO_FEATURES_append = " enable-fog"

# Enable Storage Manager support for FOG
DISTRO_FEATURES_append = " storage_sdc"

HOSTTOOLS += " python"

# globally disables this feature (for all images supported)
IMAGE_FEATURES_remove = "read-only-rootfs"

### others
ENABLE_UART = "1"

# 2024-11-11: meta-cmf-arm: usppa disabled due to erouter0 dependency
# DISTRO_FEATURES_append_broadband = " usppa"

# REFPLTV-1137: DLNA support for xupnp
DISTRO_FEATURES_append_broadband = " dlna"

DISTRO_FEATURES_append_broadband = " referencepltfm "
DISTRO_FEATURES_append_extender = " referencepltfm "

DISTRO_FEATURES_append_broadband = " ipv6"
DISTRO_FEATURES_append_broadband = " webconfig_bin"

# RDKB-51565,RDKB-50795: [HAL] Cellular Hal Implementation
DISTRO_FEATURES_append_broadband = " rdkb_cellular_manager_mm"
DISTRO_FEATURES_append_broadband = " cellular_mgr_lite"
DISTRO_FEATURES_append_broadband = " cellular_libqmi_support"

DISTRO_FEATURES_append_broadband = " rdkb_power_manager"
#DISTRO_FEATURES_append_broadband = " rdkb_gpon_manager"
DISTRO_FEATURES_append_broadband = " rdkb_wan_manager"
#DISTRO_FEATURES_append_broadband = " rdkb_configurable_wan_interface"
#DISTRO_FEATURES_append_broadband = " rdkb_voice_manager_dmltr104_v2"
DISTRO_FEATURES_append_broadband = " rdkb_xdsl_ppp_manager"
DISTRO_FEATURES_append_broadband = " fwupgrade_manager"
DISTRO_FEATURES_append_broadband = " rdkb_inter_device_manager"

DISTRO_FEATURES_append_broadband = " no_moca_support"

DISTRO_FEATURES_append_broadband = " rdk_ledmanager"
DISTRO_FEATURES_remove_aarch64 = " rdk_ledmanager"

# Platform manager and LanManager
#DISTRO_FEATURES_append_broadband = " pm_lan_mgr"

# Fix MeshAgent build errors
DISTRO_FEATURES_append_broadband = " WanFailOverSupportEnable"

# RDKBDEV-50: Adding DSLite Functionality and related TR-181 DataModel Parameters
DISTRO_FEATURES_append_broadband = " dslite"

# RDKBDEV-73 : Dynamic DNS : Standardization based on broadband-forum.
DISTRO_FEATURES_append_broadband = " ddns_broadband"

# RDKBDEV-83 : Device Gateway Association using Managed Device
DISTRO_FEATURES_append_broadband = " device_gateway_association"

# REFPLTB-1546 : WiFi HAL 3.0 support for RPI
DISTRO_FEATURES_append_broadband = " halVersion3"

# RDKBDEV-866: EasyMesh Controller support
DISTRO_FEATURES_append_broadband = " easymesh-controller"

# RDKB-40900: RDKB support extender/nonrouter profile
DISTRO_FEATURES_append_extender = " rdkb_extender"

# RDKB-44824: CoreNetLib move bb file location
DISTRO_FEATURES_append_broadband = " core-net-lib"

# DKBDEV-1455 : Support Broadband DAC
DISTRO_FEATURES_append_broadband = " dac"

# REFPLTB-1775: Sky team's fix for erouter0 IP issue
DISTRO_FEATURES_append_broadband = " RbusBuildFlagEnable"

#MeshAgent support for broadband
DISTRO_FEATURES:append:broadband = " meshwifi"

#rdk-wifi-libhostap support for broadband
DISTRO_FEATURES_append_broadband = " HOSTAPD_2_11"

# Use MLO/WiFi7 code
DISTRO_FEATURES:append:broadband = " CONFIG_IEEE80211BE"
# OneWifi feature
DISTRO_FEATURES:append:broadband = " OneWifi"

# 2025-07-10: Disable 802.11ACL feature due to MT7915/6 problem
DISTRO_FEATURES:append:broadband = " disable_nl80211_acl"

# RDKBDEV-942 RdkGponManager: Modify as per new WAN Manager Design
DISTRO_FEATURES_append_broadband = " WanManagerUnificationEnable"

# CpuPROCAnalyzer Support for broadband
DISTRO_FEATURES_append_broadband = " CPUPROCANALYZER_BROADBAND"

# RDKB-50999: WebConfig blob handler
DISTRO_FEATURES_append_broadband = " lld_support"

# RDKB-48800: Install DHCP Manager service file
# 2025-09: Disable DHCP Manager (RDKBNETWOR-3)
# DISTRO_FEATURES_append_broadband = " dhcp_manager"

# RDKBDEV-694: Adding Partner Default Ext
DISTRO_FEATURES_append_broadband = " partner_default_ext"

# RDKBDEV-755: Add Asterisk IP PBX voice HAL for TelcoVoiceManager
#DISTRO_FEATURES_append_broadband = " Asterisk"

# Remove WebUI (does not work without erouter0)
DISTRO_FEATURES_remove_broadband = " webui_jst"

# Add new EasyMesh
DISTRO_FEATURES_append_broadband = " EasyMesh"

# Add IEEE1905 AL
DISTRO_FEATURES_append_broadband = " with_alsap"

SESSIONMGR_WS_RPC_ENABLE = "1"

#REFPLTB-2784 : easymesh controller arch only supports with wifiagent
MACHINEOVERRIDES_append =. "${@bb.utils.contains('DISTRO_FEATURES', 'OneWifi', ':onewifi', '' ,d)}"
DISTRO_FEATURES_remove_onewifi = " easymesh-controller"
