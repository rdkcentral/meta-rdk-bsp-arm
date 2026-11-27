require ccsp_common_genericarm.inc

# Machine configs are separated into another package
# (bbhm_def_cfg.xml)
# This is so ccsp-psm remains a generic package,
# while the machine configs are included per
# bitbake machine
DEPENDS:append = " ccsp-psm-machine-configs"

RDEPENDS:${PN}:append = " ccsp-psm-machine-configs"
