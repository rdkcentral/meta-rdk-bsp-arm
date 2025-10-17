#-------------------------------------------------------------------------------
# Remove unused system users
#-------------------------------------------------------------------------------
EXTRA_USERS_PARAMS += "\
"

#-------------------------------------------------------------------------------
# Remove unused system groups
#-------------------------------------------------------------------------------
EXTRA_USERS_PARAMS += "\
"

#-------------------------------------------------------------------------------
# Common groups
#-------------------------------------------------------------------------------
EXTRA_USERS_PARAMS += "\
    groupadd -g 501 dbusgrp       ; \
    groupadd -g 502 devgrp        ; \
"

#-------------------------------------------------------------------------------
# Common users and groups for OENMW
# For each user also the group with the same name and id is created.
#-------------------------------------------------------------------------------
EXTRA_USERS_PARAMS += "\
    useradd -u 700 -G dbusgrp                            -r -s /bin/false dhcpc          ; \
    useradd -u 701 -G dbusgrp                            -r -s /bin/false dnsmasq        ; \
    useradd -u 702 -G dbusgrp                            -r -s /bin/false firewall       ; \
    useradd -u 703 -G dbusgrp                            -r -s /bin/false dbus           ; \
    useradd -u 704 -G dbusgrp,devgrp,audio               -r -s /bin/false platformcontrol; \
    useradd -u 705 -G dbusgrp                            -r -s /bin/false rmfstreamer    ; \
    useradd -u 706 -G dbusgrp,devgrp,audio,input         -r -s /bin/false rdkbrowser2    ; \
"
#-------------------------------------------------------------------------------
# PLATFORMCONTROL
#-------------------------------------------------------------------------------
ROOTFS_CHOWN_SETCAP += "   -o platformcontrol:platformcontrol -m o-rwx,a-w  /usr/bin/irMgrMain                                       \n"
ROOTFS_CHOWN_SETCAP += "   -o platformcontrol:platformcontrol -m o-rwx,a-w  /usr/bin/dsMgrMain                                       \n"
ROOTFS_CHOWN_SETCAP += "   -o platformcontrol:platformcontrol -m o-rwx,a-w  /usr/bin/sysMgrMain                                      \n"

#-------------------------------------------------------------------------------
# RMFSTREAMER
#-------------------------------------------------------------------------------
ROOTFS_CHOWN_SETCAP += " -o rmfstreamer:rmfstreamer -m o-rwx /usr/bin/rmfStreamer      \n"
ROOTFS_CHOWN_SETCAP += " -o rmfstreamer:rmfstreamer -m o-rwx /usr/bin/tune.config      \n"
ROOTFS_CHOWN_SETCAP += " -o rmfstreamer:rmfstreamer -m o-rwx /usr/bin/channel_info.config \n"
ROOTFS_CHOWN_SETCAP += " -o rmfstreamer:rmfstreamer -m o-rwx /usr/bin/sidb.xml         \n"
ROOTFS_CHOWN_SETCAP += " -o rmfstreamer:rmfstreamer -m o-rwx /etc/os-release           \n"
ROOTFS_CHOWN_SETCAP += " -o rmfstreamer:rmfstreamer -m o-rwx /etc/rmfconfig.ini        \n"

#-------------------------------------------------------------------------------
# RDKBROWSER2
#-------------------------------------------------------------------------------
ROOTFS_CHOWN_SETCAP += " -o rdkbrowser2:rdkbrowser2    -m o-rwx /usr/bin/rdkbrowser2            \n"
ROOTFS_CHOWN_SETCAP += " -o rdkbrowser2:rdkbrowser2    -m o-rwx /usr/bin/rdkbrowser2.sh         \n"


