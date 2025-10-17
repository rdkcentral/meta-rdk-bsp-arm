#Rename opensync.init from  managers.init  because opensync-4.4 have opensync.init file  
do_install_append() {
     sed -i "s/managers.init/opensync.init/g" ${D}/usr/ccsp/ovsagent/OvsAgent_ovsdb-server_check.sh
}


#Disabling this service untill OVS is completely functional
SYSTEMD_SERVICE_${PN}_remove = "OvsAgent.path"
