RDEPENDS_packagegroup-rdk-ccsp-broadband:remove = "ccsp-cm-agent"
RDEPENDS_packagegroup-rdk-ccsp-broadband:remove = "ccsp-cm-agent-ccsp"
RDEPENDS_packagegroup-rdk-ccsp-broadband:remove = "ccsp-moca-ccsp"
RDEPENDS_packagegroup-rdk-ccsp-broadband:remove = "ccsp-epon-agent"
RDEPENDS_packagegroup-rdk-ccsp-broadband:remove = "sys-resource"
RDEPENDS_packagegroup-rdk-ccsp-broadband:remove = "ccsp-wifi-agent"
RDEPENDS_packagegroup-rdk-ccsp-broadband:remove = "ccsp-mta-agent"
RDEPENDS_packagegroup-rdk-ccsp-broadband:remove = "ccsp-mta-agent-ccsp"
RDEPENDS_packagegroup-rdk-ccsp-broadband:remove = "rdktelcovoicemanager"

RDEPENDS_packagegroup-rdk-ccsp-broadband:remove = "ccsp-adv-security"

RDEPENDS_packagegroup-rdk-ccsp-broadband:remove = "ccsp-webui-jst"
RDEPENDS_packagegroup-rdk-ccsp-broadband:remove = "ccsp-webui-php"

RDEPENDS_packagegroup-rdk-ccsp-broadband:remove = "parodus"

RDEPENDS_packagegroup-rdk-ccsp-broadband:append = "\
    rdk-logger \
    libseshat \
    notify-comp \
    ${@bb.utils.contains('DISTRO_FEATURES', 'CPUPROCANALYZER_BROADBAND', 'cpuprocanalyzer', ' ', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'rdkb_cellular_manager_mm', 'rdk-cellularmanager-mm', ' ', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'rdk_ledmanager', 'rdk-ledmanager', ' ', d)} \
    \
"

# Set the gwprov app for RPi
GWPROVAPP = "${@bb.utils.contains('DISTRO_FEATURES','rdkb_wan_manager','','ccsp-gwprovapp-ethwan',d)}"
