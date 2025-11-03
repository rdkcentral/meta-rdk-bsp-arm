# Override the meta-cmf-broadband recipe to avoid installing
# systemd files (handled by unified-wifi-mesh-personality-...)
# cargo_do_install originates from bitbake's cargo.bbclass
unset do_install
do_install() {
    export CRATE_CC_NO_DEFAULTS=1
    cargo_do_install
}


#FILES_${PN}:remove = "${systemd_unitdir}/system/ieee1905_em_ctrl.service"
#FILES_${PN}:remove = "${systemd_unitdir}/system/ieee1905_em_agent.service"

SYSTEMD_SERVICE_${PN}:remove = "ieee1905_em_ctrl.service"
SYSTEMD_SERVICE_${PN}:remove = "ieee1905_em_agent.service"
