RDEPENDS:rdk-wanmanager:append = " ndisc6-rdisc6"
CFLAGS:append = " -D_PLATFORM_RASPBERRYPI_"

# 2026-03-03: Override version due to build failure with v2.15
SRC_URI="git://github.com/rdkcentral/wan-manager.git;branch=releases/2.14.0-main;protocol=https;name=WanManager;tag=v2.14.0"
