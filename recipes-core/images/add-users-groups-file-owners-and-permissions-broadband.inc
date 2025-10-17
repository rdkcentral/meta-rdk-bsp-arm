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
    useradd -u 700 -G dbusgrp                            -r -s /bin/false dhcpc           ; \
    useradd -u 701 -G dbusgrp                            -r -s /bin/false dnsmasq         ; \
    useradd -u 702 -G dbusgrp                            -r -s /bin/false firewall        ; \
    useradd -u 703 -G dbusgrp                            -r -s /bin/false dbus            ; \
    useradd -u 704 -G dbusgrp                            -r -s /bin/false ccspcr          ; \
    useradd -u 705 -G dbusgrp                            -r -s /bin/false psm             ; \
    useradd -u 706 -G dbusgrp                            -r -s /bin/false pandm           ; \
    useradd -u 707 -G dbusgrp                            -r -s /bin/false ccsplmlite      ; \
    useradd -u 708 -G dbusgrp                            -r -s /bin/false ccspwifi        ; \
    useradd -u 709 -G dbusgrp                            -r -s /bin/false dmcli           ; \
"
#-------------------------------------------------------------------------------
# PandM,Dbus,CR
#-------------------------------------------------------------------------------

ROOTFS_CHOWN_SETCAP += " -o dbus:dbus -m o-rwx /usr/bin/dbus-daemon      \n"

ROOTFS_CHOWN_SETCAP += " -o ccspcr:ccspcr -m o-rwx /usr/bin/CcspCrSsp               \n"

ROOTFS_CHOWN_SETCAP += " -o ccspcr:ccspcr -m o-rwx /usr/ccsp/cr-deviceprofile.xml    \n"

ROOTFS_CHOWN_SETCAP += " -o psm:psm -m o-rwx /usr/bin/PsmSsp   \n"

ROOTFS_CHOWN_SETCAP += " -o ccsplmlite:ccsplmlite -m o-rwx /usr/bin/CcspLMLite     \n"

ROOTFS_CHOWN_SETCAP += " -o ccspwifi:ccspwifi -m o-rwx /usr/bin/CcspWifiSsp     \n"

ROOTFS_CHOWN_SETCAP += " -o dmcli:dmcli -m o-rwx /usr/bin/dmcli     \n"
#-------------------------------------------------------------------------------

