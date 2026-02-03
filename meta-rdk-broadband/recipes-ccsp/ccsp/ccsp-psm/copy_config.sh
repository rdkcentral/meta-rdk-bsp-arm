#!/bin/sh

set -e
MACHINE_NAME=$(strings /sys/firmware/devicetree/base/compatible | head -n 1 | sed "s/,/_/g")

MACHINE_CONFIG_FILE="/usr/ccsp/machine_configs/${MACHINE_NAME}.xml"
DEFAULT_CONFIG_FILE="/usr/ccsp/config/bbhm_def_cfg.xml"

if [ -f "${DEFAULT_CONFIG_FILE}" ]; then
    echo "Default config file in place"
    exit 0
fi

mount -t tmpfs tmpfs /usr/ccsp/config

if [ -f "${MACHINE_CONFIG_FILE}" ]; then
    echo "Copying machine specific config file"
    echo "Source: ${MACHINE_CONFIG_FILE}"
    echo "Destination: ${DEFAULT_CONFIG_FILE}"
    cp "${MACHINE_CONFIG_FILE}" "${DEFAULT_CONFIG_FILE}"
else
    echo "No machine specific config file found, copying default"
    cp "/usr/ccsp/machine_configs/default.xml" "${DEFAULT_CONFIG_FILE}"
fi

