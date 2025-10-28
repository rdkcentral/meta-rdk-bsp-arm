SRC_URI_remove = "git://github.com/rdkcentral/rdk-wifi-hal.git;protocol=https;branch=main;name=rdk-wifi-hal"

SRC_URI += "git://github.com/rdkcentral/rdk-wifi-hal.git;protocol=https;branch=develop;name=rdk-wifi-hal"
SRCREV_rdk-wifi-hal = "7cbf2c7a892e9d10be0fc8fa3ad85c7a7aeb511c"

FILESEXTRAPATHS_prepend := "${THISDIR}/rdk-wifi-hal:"

SRC_URI:append = "\
  file://0001-platform-change-default-SSID-to-RDKB-ARM-AP.patch;patchdir=.. \
"

# For the purposes of the EasyMesh bring up, we will "pretend" to be a
# Banana Pi, which has the same WiFi vendor as us.
CFLAGS_append = " -D_PLATFORM_BANANAPI_R4_ -DBANANA_PI_PORT"
CFLAGS_append_kirkstone = " -fcommon"
EXTRA_OECONF_append = " ${@bb.utils.contains('DISTRO_FEATURES', 'OneWifi', ' ONE_WIFIBUILD=true ', '', d)}"
EXTRA_OECONF_append = " ${@bb.utils.contains('DISTRO_FEATURES', 'OneWifi', ' BANANA_PI_PORT=true ', '', d)}"

SRC_URI += " \
  ${@bb.utils.contains('DISTRO_FEATURES', 'EasyMesh', ' file://InterfaceMap_em.json ', 'file://InterfaceMap.json ', d)} \
  ${@bb.utils.contains('DISTRO_FEATURES', 'EasyMesh', bb.utils.contains('DISTRO_FEATURES', 'em_extender', 'file://EasymeshCfg_ext.json ','file://EasymeshCfg.json ', d), ' ', d)} \
"

# On other implementations, these files are installed into /nvram
# As our /nvram mount point is separate, these instead will be
# copied by a pre-start script at runtime
do_install_append() {
  install -d ${D}/usr/ccsp/EasyMesh/nvram
  install -m 0644 ${WORKDIR}/InterfaceMa*.json ${D}/usr/ccsp/EasyMesh/nvram/InterfaceMap.json
  DISTRO_EM_ENABLED="${@bb.utils.contains('DISTRO_FEATURES','EasyMesh','true','false',d)}"
  if [ $DISTRO_EM_ENABLED = 'true' ]; then
     install -m 0644 ${WORKDIR}/Easymesh*.json  ${D}/usr/ccsp/EasyMesh/nvram/EasymeshCfg.json 
  fi
}

FILES_${PN} += " \
  /usr/ccsp/EasyMesh/* \
"

