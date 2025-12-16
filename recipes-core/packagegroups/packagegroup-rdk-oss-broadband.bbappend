RDEPENDS_packagegroup-rdk-oss-broadband:append = " \
    iw \
    wireless-tools \
    ${@bb.utils.contains('DISTRO_FEATURES', 'OneWifi', ' ', ' hostapd', d)} \
    crda \
    ebtables \
    ethtool \
    ${@bb.utils.contains('DISTRO_FEATURES', 'dac', 'speedtest-cli', '', d)} \
"

RDEPENDS_packagegroup-rdk-oss-broadband:append = " virtual/wifi-vendor-mtk"
RDEPENDS_packagegroup-rdk-oss-broadband:append = " virtual/firmware-mtk-wifi6"
RDEPENDS_packagegroup-rdk-oss-broadband:remove:aarch64 = "alljoyn"
