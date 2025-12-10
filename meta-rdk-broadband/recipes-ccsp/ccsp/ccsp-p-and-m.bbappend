require ccsp_common_genericarm.inc

FILESEXTRAPATHS_prepend := "${THISDIR}/ccsp-p-and-m:"

SRC_URI += "\
        file://0001-Remove-erouter0-reference-from-Device.IP.Interface.patch \
        file://0002-Generic-ARM-only-disable-sending-WebPA-notifications.patch \
        file://0003-Generic-ARM-only-disable-telemetry-reporting-for-WAN.patch \
"

DEPENDS_append = " utopia curl "

CFLAGS_append = " \
    -I=${includedir}/utctx \
    -I=${includedir}/utapi \
    -DWEBPA_NOTIFICATIONS_DISABLED \
    -DTELEMETRY_DISABLED \
"

LDFLAGS_remove = " \
    -lmoca_mgnt \
"
CFLAGS_remove = "-Werror"
#Disabling the ppp manager conditional flag until the pppmanager functionality support in RPI
CFLAGS_remove = " ${@bb.utils.contains('DISTRO_FEATURES', 'rdkb_xdsl_ppp_manager', '-DFEATURE_RDKB_XDSL_PPP_MANAGER', '', d)}"

do_configure_prepend () {
   #for WanManager support
   #Below lines of code needs to be removed , once (Device.DHCPv4.Client.{i} and Device.DhCPv6,CLient.{i}) the mentioned parameters are permanently removed from TR181-USGv2.XML
    DISTRO_WAN_ENABLED="${@bb.utils.contains('DISTRO_FEATURES','rdkb_wan_manager','true','false',d)}"
if [ $DISTRO_WAN_ENABLED = 'true' ]; then
if [ ! -f ${WORKDIR}/WanManager_XML_UPDATED ]; then
   GREP_WORD=`cat -n ${S}/config-arm/TR181-USGv2.XML  | grep 9536 | cut -d '<' -f2 | cut -d  '>' -f2`
   if [ "$GREP_WORD" = "ClientNumberOfEntries" ]; then
        #for DHCPv4.Client.{i}.
        sed -i '9534s/<parameter>/<!-- <parameter>/g' ${S}/config-arm/TR181-USGv2.XML
        sed -i '9542s/<\/parameter>/<\/parameter>-->/g' ${S}/config-arm/TR181-USGv2.XML
        sed -i '9642s/<object>/<!-- <object>/g' ${S}/config-arm/TR181-USGv2.XML
        sed -i '10058s/<\/object>/<\/object>-->/g' ${S}/config-arm/TR181-USGv2.XML
        #for DHCPv6.Client.{i}.
        sed -i '10832s/<parameter>/<!-- <parameter>/g' ${S}/config-arm/TR181-USGv2.XML
        sed -i '10836s/<\/parameter>/<\/parameter>-->/g' ${S}/config-arm/TR181-USGv2.XML
        sed -i '10839s/<object>/<!-- <object>/g' ${S}/config-arm/TR181-USGv2.XML
        sed -i '11138s/<\/object>/<\/object>-->/g' ${S}/config-arm/TR181-USGv2.XML
   fi
   if ${@bb.utils.contains('DISTRO_FEATURES', 'rdkb_xdsl_ppp_manager', 'true', 'false', d)}; then
  	 sed -i "s/<?ifndef FEATURE_RDKB_XDSL_PPP_MANAGER?>/<?ifdef FEATURE_RDKB_XDSL_PPP_MANAGER?>/g" ${S}/config-arm/TR181-USGv2.XML
   fi
   touch ${WORKDIR}/WanManager_XML_UPDATED
fi
fi
}

do_install_append(){
    # Config files and scripts
    install -m 644 ${S}/config-arm/CcspDmLib.cfg ${D}/usr/ccsp/pam/CcspDmLib.cfg
    install -m 644 ${S}/config-arm/CcspPam.cfg -t ${D}/usr/ccsp/pam
    install -m 644 ${S}/config-arm/TR181-USGv2.XML -t ${D}/usr/ccsp/pam

    install -m 777 ${D}/usr/bin/CcspPandMSsp -t ${D}/usr/ccsp/pam/

    install -d ${D}/fss/gw/usr/sbin
    ln -sf /sbin/ip.iproute2 ${D}/fss/gw/usr/sbin/ip

########## ETHWAN Support
   sed -i "s/\"Device.DeviceInfo.X_RDKCENTRAL-COM_Syndication.RDKB_UIBranding.AllowEthernetWAN\"\ :\ \"false\"\ \,/\"Device.DeviceInfo.X_RDKCENTRAL-COM_Syndication.RDKB_UIBranding.AllowEthernetWAN\" : \"true\" ,/g" ${D}/etc/partners_defaults.json

##### REFPLTB-728
    sed -i "s/www.rdkcentral.com/www.google.com/g" ${D}/etc/partners_defaults.json	
    sed -i "/productname\" : \"RDKM\"/{N;s/\n.*//;}" ${D}/etc/partners_defaults.json
    sed -i "/productname\" : \"RDKM\"/a \ \t\"Device.DeviceInfo.X_RDKCENTRAL-COM_Syndication.RDKB_UIBranding.CloudUI.link\" : \"www.rdkcentral.com\"," ${D}/etc/partners_defaults.json
    sed -i "/UserGuideLink\" : \"https:\/\/wiki.rdkcentral.com\/display\/RDK\/Download+and+Build+Documentation\",/{N;s/\n.*//;}" ${D}/etc/partners_defaults.json
    sed -i "/UserGuideLink\" : \"https:\/\/wiki.rdkcentral.com\/display\/RDK\/Download+and+Build+Documentation\",/a \ \t\"Device.DeviceInfo.X_RDKCENTRAL-COM_Syndication.RDKB_UIBranding.Footer.CustomerCentralLink\" : \"https:\/\/www.rdkcentral.com\/\"," ${D}/etc/partners_defaults.json
}

FILES_${PN}-ccsp += " \
    ${prefix}/ccsp/pam/CcspPandMSsp \
    /fss/gw/usr/sbin/ip \
    ${prefix}/ccsp/pam/TR181-USGv2.XML \
"
