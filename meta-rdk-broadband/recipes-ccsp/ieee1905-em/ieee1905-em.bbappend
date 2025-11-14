# Override the meta-cmf-broadband recipe to avoid installing
# systemd files (handled by unified-wifi-mesh-personality-...)
# cargo_do_install originates from bitbake's cargo.bbclass
# (Using the python function appears to be the only way to
# overwrite do_install() while keeping cargo/rust task
# dependencies intact)
python () {
    d.setVar("do_install", "export CRATE_CC_NO_DEFAULTS=1\ncargo_do_install")
}

SYSTEMD_SERVICE_${PN}:remove = "ieee1905_em_ctrl.service"
SYSTEMD_SERVICE_${PN}:remove = "ieee1905_em_agent.service"
