require ccsp_common_genericarm.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://bbhm_def_cfg_ten64.xml"

do_install:append() {
    # Config files and scripts
    install -d ${D}/usr/ccsp/config
    install -m 644 ${WORKDIR}/bbhm_def_cfg_ten64.xml ${D}/usr/ccsp/config/bbhm_def_cfg.xml
    install -m 755 ${S}/scripts/bbhm_patch.sh ${D}/usr/ccsp/psm/bbhm_patch.sh
    # Common for all platforms
    sed -i \
        -e 's#<Record name="dmsb.wanmanager.if.1.VirtualInterface.1.Name".*</Record>#<Record name="dmsb.wanmanager.if.1.VirtualInterface.1.Name" type="astr">erouter0</Record>#' \
        -e 's#<Record name="dmsb.ethlink.1.name".*</Record>#<Record name="dmsb.ethlink.1.name" type="astr">erouter0</Record>#' \
        ${D}/usr/ccsp/config/bbhm_def_cfg.xml
}

do_install_append_raspberrypi64-rdk-broadband() {
    # Set to eth0 for RPi
    sed -i \
        -e 's#<Record name="dmsb.wanmanager.if.1.Name".*</Record>#<Record name="dmsb.wanmanager.if.1.Name" type="astr">eth0</Record>#' \
        -e 's#<Record name="dmsb.ethlink.1.baseiface".*</Record>#<Record name="dmsb.ethlink.1.baseiface" type="astr">eth0</Record>#' \
        -e 's#<Record name="dmsb.vlanmanager.1.baseinterface".*</Record>#<Record name="dmsb.vlanmanager.1.baseinterface" type="astr">eth0</Record>#' \
        -e 's#<Record name="dmsb.ethagent.if.2.Name".*</Record>#<Record name="dmsb.ethagent.if.2.Name" type="astr">eth0</Record>#' \
        ${D}/usr/ccsp/config/bbhm_def_cfg.xml
}

do_install_append_armefi64-rdk-broadband() {
    # Set to eth3 for NXP
    sed -i \
        -e 's#<Record name="dmsb.wanmanager.if.1.Name".*</Record>#<Record name="dmsb.wanmanager.if.1.Name" type="astr">eth3</Record>#' \
        -e 's#<Record name="dmsb.ethlink.1.baseiface".*</Record>#<Record name="dmsb.ethlink.1.baseiface" type="astr">eth3</Record>#' \
        -e 's#<Record name="dmsb.vlanmanager.1.baseinterface".*</Record>#<Record name="dmsb.vlanmanager.1.baseinterface" type="astr">eth3</Record>#' \
        -e 's#<Record name="dmsb.ethagent.if.2.Name".*</Record>#<Record name="dmsb.ethagent.if.2.Name" type="astr">eth3</Record>#' \
        ${D}/usr/ccsp/config/bbhm_def_cfg.xml
}

do_install_append_armefi64-qemu-broadband() {
    # Set to eth3 for QEMU
    sed -i \
        -e 's#<Record name="dmsb.wanmanager.if.1.Name".*</Record>#<Record name="dmsb.wanmanager.if.1.Name" type="astr">eth0</Record>#' \
        -e 's#<Record name="dmsb.ethlink.1.baseiface".*</Record>#<Record name="dmsb.ethlink.1.baseiface" type="astr">eth0</Record>#' \
        -e 's#<Record name="dmsb.vlanmanager.1.baseinterface".*</Record>#<Record name="dmsb.vlanmanager.1.baseinterface" type="astr">eth0</Record>#' \
        -e 's#<Record name="dmsb.ethagent.if.2.Name".*</Record>#<Record name="dmsb.ethagent.if.2.Name" type="astr">eth0</Record>#' \
        ${D}/usr/ccsp/config/bbhm_def_cfg.xml
}
