# 2026-08-05 utopia to develop (after 2.8.0) to sync with
# proposed upstream merge
# We cannot override the SRCREV:pn-utopia defined in meta-rdk-broadband
# directly, so these need to be cited in the utopia.bbappend and
# utopia-headers.bbappend
GENERIC_ARM_UTOPIA_SRCREV = "5d0d2b9753f0446a095c0336c45ebb88089083f3"
GENERIC_ARM_UTOPIA_PV = "2.8.0plus"