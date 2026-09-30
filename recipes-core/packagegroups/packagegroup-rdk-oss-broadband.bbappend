RDEPENDS_packagegroup-rdk-oss-broadband:append = " \
    iw \
    wireless-tools \
    ${@bb.utils.contains('DISTRO_FEATURES', 'OneWifi', ' ', ' hostapd', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel-6-18', ' wireless-regdb-static', ' crda', d)} \
    ebtables \
    ethtool \
    ${@bb.utils.contains('DISTRO_FEATURES', 'dac', 'speedtest-cli', '', d)} \
"

RDEPENDS_packagegroup-rdk-oss-broadband:remove = " lighttpd"

RDEPENDS_packagegroup-rdk-oss-broadband:remove:aarch64 = "alljoyn"
