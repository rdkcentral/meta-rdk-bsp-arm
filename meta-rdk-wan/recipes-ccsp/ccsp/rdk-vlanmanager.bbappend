FILESEXTRAPATHS:prepend := "${THISDIR}/rdk-vlanmanager:"

SRC_URI:append = " \
    file://0001-Remove-PLATFORM_TURRIS-flags.patch \
"
