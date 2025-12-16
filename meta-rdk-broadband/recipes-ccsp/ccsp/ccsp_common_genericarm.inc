SUMMARY = "common inc for Arm generic platforms"

# It is assumed that all recipes including this inc file have
# included meta-rdk/recipes-ccsp/ccsp/ccsp_common.inc

#require meta-rdk/recipes-ccsp/ccsp/ccsp_common.inc

CFLAGS:append = " -fno-exceptions -ffunction-sections -fdata-sections -fomit-frame-pointer -fno-strict-aliasing \
           -D_ANSC_LINUX -D_ANSC_USER -D_ANSC_LITTLE_ENDIAN_ -D_CCSP_CWMP_TCP_CONNREQ_HANDLER \
           -D_DSLH_STUN_ -D_NO_PKI_KB5_SUPPORT -D_BBHM_SSE_FILE_IO -D_ANSC_USE_OPENSSL_ -DENABLE_SA_KEY \
           -D_ANSC_AES_USED_ -D_COSA_INTEL_USG_ARM_ -D_COSA_FOR_COMCAST_ -D_NO_EXECINFO_H_ -DFEATURE_SUPPORT_SYSLOG \
           -DBUILD_WEB -D_NO_ANSC_ZLIB_ -D_DEBUG -U_ANSC_IPV6_COMPATIBLE_ -D_COSA_BCM_ARM_ -DUSE_NOTIFY_COMPONENT \
           -D_PLATFORM_GENERICARM_ -D_PLATFORM_RASPBERRYPI_ -DENABLE_SD_NOTIFY \
           -DCONFIG_VENDOR_CUSTOMER_COMCAST -UPARODUS_ENABLE -U_COSA_SIM_ \
           ${@bb.utils.contains('DISTRO_FEATURES', 'rdkb_wan_manager', ' -DFEATURE_RDKB_WAN_MANAGER ', '', d)} \
           ${@bb.utils.contains('DISTRO_FEATURES', 'meshwifi', ' -DENABLE_FEATURE_MESHWIFI ', '', d)} \
           -D_64BIT_ARCH_SUPPORT_ \
           -DFEATURE_SUPPORT_RDKLOG \
           "

DEPENDS:append = " breakpad-wrapper"
LDFLAGS:append = " -lbreakpadwrapper -lpthread -lcrypto -lsafec"
