FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://usp-pa.service"
EXTRA_OECONF:remove:kirkstone  = " --with-ccsp-platform=bcm --with-ccsp-arch=arm "
