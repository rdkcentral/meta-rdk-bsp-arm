EXTRA_OECONF:remove:kirkstone  = " --with-ccsp-platform=bcm --with-ccsp-arch=arm "

do_install:append:class-target () {

sed -i "/^ExecStart=/c\\ExecStart=/bin/sh -c '/usr/bin/obuspa --plugin /usr/libexec/usp-pa-vendor-rdk.so -v1 --resetfile /etc/usp-pa/usp_factory_reset.conf --truststore /etc/usp-pa/usp_truststore.pem --interface \"\$(sysevent get current_wan_ifname)\" --log syslog --dbfile /nvram/usp-pa.db'" ${D}${systemd_unitdir}/system/usp-pa.service

}
