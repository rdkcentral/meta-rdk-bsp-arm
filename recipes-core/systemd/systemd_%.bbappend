do_install_append() {
    # disable restart of udev and timesyncd services on failure for now
    sed -i -e 's/^Restart=always/Restart=no/' ${D}/lib/systemd/system/systemd-udevd.service
    echo "TimeoutSec=10" >> ${D}/lib/systemd/system/systemd-udevd.service
}

RRECOMMENDS_${PN}_remove_broadband += "util-linux-swaponoff util-linux-losetup"
