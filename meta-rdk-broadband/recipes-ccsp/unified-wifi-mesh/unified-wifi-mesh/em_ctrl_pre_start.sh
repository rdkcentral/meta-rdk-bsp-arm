#!/bin/sh

if [ ! -f "/nvram/InterfaceMap.json" ]; then
    echo "No EasyMesh configuration data in /nvram, doing initial copy"
    cp /usr/ccsp/EasyMesh/nvram/* /nvram/
fi

/usr/ccsp/EasyMesh/setup_mysql_db_pre.sh

exit 0