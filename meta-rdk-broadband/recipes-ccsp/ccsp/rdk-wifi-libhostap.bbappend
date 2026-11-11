# 2026-04-20 compile error due to undeclared "own_mld_id" variable
SRC_URI:remove = "file://${HOSTAPD_PV}/MLO_Correct_PerStaProfile_rx_link_id.patch"

# 2026-06-30 compile error due to patch not applying cleanly
# (original change was BCOMB-3508)
SRC_URI:remove = "file://${HOSTAPD_PV}/iPhone17_connection_fix.patch"

# 2026-08-11 compile error due to patch not applying cleanly
SRC_URI:remove = "file://${HOSTAPD_PV}/mlo_rx_link_id_fix.patch"

# 2026-11-10 remove patches related to XB10-3073
SRC_URI:remove = "file://${HOSTAPD_PV}/mld_link_sta_2_11.patch"
SRC_URI:remove = "file://${HOSTAPD_PV}/libhostap_log_timestamp_2_11.patch"
SRC_URI:remove = "file://${HOSTAPD_PV}/pmf_sta_reassoc_2_11.patch"
SRC_URI:remove = "file://${HOSTAPD_PV}/prune_assoc_deauth_2_11.patch"
SRC_URI:remove = "file://${HOSTAPD_PV}/rx_leave_no_drv_remove_2_11.patch"

