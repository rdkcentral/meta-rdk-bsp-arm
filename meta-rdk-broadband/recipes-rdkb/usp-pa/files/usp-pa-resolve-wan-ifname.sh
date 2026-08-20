#!/bin/sh
# Resolve the WAN interface name for obuspa and stores it in EnvironmentFile.

set -u

ENV_DIR=/run/usp-pa
ENV_FILE="${ENV_DIR}/wan.env"

mkdir -p "${ENV_DIR}"
: > "${ENV_FILE}"

IF_NAME="$(sysevent get current_wan_ifname 2> /dev/null)"

# Sanitize to avoid shell injections
case "${IF_NAME}" in
''|*[!A-Za-z0-9._-]*)
       echo "usp-pa: invalid WAN interface name from sysevent" >&2
       exit 1
       ;;
esac

if [ ! -d "/sys/class/net/${IF_NAME}" ]; then
       echo "usp-pa: WAN interface '${IF_NAME}' not present yet" >&2
       exit 1
fi

echo "USP_PA_WAN_IF_NAME=${IF_NAME}" > "${ENV_FILE}"
