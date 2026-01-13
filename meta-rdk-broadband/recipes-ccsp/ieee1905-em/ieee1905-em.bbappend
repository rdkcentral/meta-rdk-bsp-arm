inherit cargo-update-recipe-crates
SRC_URI = "git://github.com/rdkcentral/ieee1905-rs.git;branch=main;protocol=https"
SRCREV = "053ae8ac049e54f7267c7ce2b7cfaeab84eab44e"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = "file://0001-fixed-high-cpu-usage-when-listened-interface-is-down.patch"

include ieee1905-em-crates.inc
# Override the meta-cmf-broadband recipe to avoid installing
# systemd files (handled by unified-wifi-mesh-personality-...)
# cargo_do_install originates from bitbake's cargo.bbclass
# (Using the python function appears to be the only way to
# overwrite do_install() while keeping cargo/rust task
# dependencies intact)
python () {
    d.setVar("do_install", "export CRATE_CC_NO_DEFAULTS=1\ncargo_do_install")
}

SYSTEMD_SERVICE:${PN}:remove = "ieee1905_em_ctrl.service"
SYSTEMD_SERVICE:${PN}:remove = "ieee1905_em_agent.service"
