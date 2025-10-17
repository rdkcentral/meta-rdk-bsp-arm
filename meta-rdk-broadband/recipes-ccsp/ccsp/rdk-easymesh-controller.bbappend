require ccsp_common_genericarm.inc
EXTRA_OECONF_remove_kirkstone  = " --with-ccsp-platform=bcm --with-ccsp-arch=arm"

do_install_append () {
	sed -i "s/After=ccspwifiagent.service/After=onewifi.service/g"  ${D}${systemd_unitdir}/system/RdkEasyMeshController.service
	sed -i "s/Type=simple/Type=forking/g"  ${D}${systemd_unitdir}/system/RdkEasyMeshController.service
}
