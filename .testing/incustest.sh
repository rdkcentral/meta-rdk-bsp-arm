#!/bin/bash
set -e

touch /tmp/incus_in_use

get_router_info_json() {
  incus list -f json "${NEW_ROUTER_INSTANCE_NAME}"
}

get_testclient_info_json() {
  incus list -f json "${NEW_TESTCLIENT_INSTANCE_NAME}"
}

do_cleanup() {
  incus stop -f "${NEW_TESTCLIENT_INSTANCE_NAME}"
  incus stop -f "${NEW_ROUTER_INSTANCE_NAME}"
  incus project switch default
  rm -f /tmp/incus_in_use
  echo "Scheduling deletion of test environment in two hours"
  TEMP_FILE_NAME=$(mktemp)
  cat <<EOF > "${TEMP_FILE_NAME}"
  while [ -f /tmp/incus_in_use ]; do sleep 60; done
incus project switch default
(echo "yes" | (incus project rm -f "rdkb-test-${CI_PIPELINE_ID}")) > /dev/null
(echo "yes" | (incus network rm "r2c-${CI_PIPELINE_ID}" )) > /dev/null
EOF
  env -i "HOME=${HOME}" at -f "${TEMP_FILE_NAME}" "now + 2 hours"
  rm "${TEMP_FILE_NAME}"
}

cat <<EOF > metadata.yaml
architecture: arm64
creation_date: $(date +%s)
properties:
  description: RDK-B image
  os: RDK-B
  release: 20260520061518
EOF

NEW_PROJECT_NAME="rdkb-test-${CI_PIPELINE_ID}"

NEW_IMAGE_NAME="rdkb-${CI_PIPELINE_ID}"

NEW_ROUTER_INSTANCE_NAME="rdkb-ci-test-${CI_PIPELINE_ID}"
NEW_TESTCLIENT_INSTANCE_NAME="testclient-${CI_PIPELINE_ID}"
NEW_ROUTER2CLIENT_NETWORK_NAME="r2c-${CI_PIPELINE_ID}"

incus project create "${NEW_PROJECT_NAME}"

incus project switch "${NEW_PROJECT_NAME}"

incus network create "${NEW_ROUTER2CLIENT_NETWORK_NAME}" dns.mode=none ipv4.address=none ipv6.address=none --type=bridge 

tar -zcvf metadata.tar.gz metadata.yaml

curl "https://traverse-rdkb-ci-builds.s3.bhs.io.cloud.ovh.net/ci-builds/${CI_PIPELINE_ID}/generic/rdk-generic-broadband-image-armefi64-rdk-broadband.wic.qcow2" -o rdk-generic-broadband-image-armefi64-rdk-broadband.wic.qcow2

incus image import metadata.tar.gz rdk-generic-broadband-image-armefi64-rdk-broadband.wic.qcow2 --alias "${NEW_IMAGE_NAME}"

incus create "${NEW_IMAGE_NAME}" "${NEW_ROUTER_INSTANCE_NAME}" --vm \
  --storage default \
  -c security.secureboot=false \
  -c limits.cpu=2 \
  -c limits.memory=2GiB  \
  -n "${NEW_ROUTER2CLIENT_NETWORK_NAME}"
incus network attach bng2cpe "${NEW_ROUTER_INSTANCE_NAME}" eth1
incus start "${NEW_ROUTER_INSTANCE_NAME}"
incus create --storage default images:alpine/3.23 "${NEW_TESTCLIENT_INSTANCE_NAME}" -n "${NEW_ROUTER2CLIENT_NETWORK_NAME}"
incus start "${NEW_TESTCLIENT_INSTANCE_NAME}"
echo "Waiting for stack to boot"
sleep 30

INCUS_LIST_JSON_ROUTER=$(get_router_info_json)
VM_STATE=$(echo "${INCUS_LIST_JSON_ROUTER}" | jq -r '.[0].state.status')
if [ "${VM_STATE}" != "Running" ]; then
  echo "ERROR: RDK-B VM is not running"
  do_cleanup && exit 1
fi

echo "VM is running"

VM_IS_RUNNING_RDK=0

for i in $(seq 1 5); do
  INCUS_LIST_JSON_ROUTER=$(get_router_info_json)
  VM_OS_INFO=$(echo "${INCUS_LIST_JSON_ROUTER}" | jq -r '.[0].state.os_info')
  VM_OS_NAME=$(echo "${INCUS_LIST_JSON_ROUTER}" | jq -r .[0].state.os_info.os)
  if [[ $VM_OS_NAME =~ "RDK" ]]; then
    VM_IS_RUNNING_RDK=1
    break
  fi
  sleep 20
done

if [ "${VM_IS_RUNNING_RDK}" = "0" ]; then
  echo "ERROR: Virtual machine is not identifying as RDK-B (missing incus agent issue?)"
  echo "VM reported name is: ${VM_OS_NAME}"
  do_cleanup && exit 1
fi

echo "Reported OS information: "
echo "${VM_OS_INFO}"

echo "version.txt from VM:"
echo "------------------------------------------------------"
incus exec "${NEW_ROUTER_INSTANCE_NAME}" -- cat /version.txt
echo "------------------------------------------------------"

BRLAN0_STATUS="unknown"

# Wait for brlan0 to start up
for i in $(seq 1 5); do
  INCUS_LIST_JSON_ROUTER=$(get_router_info_json)
  BRLAN0_STATUS=$(echo "${INCUS_LIST_JSON_ROUTER}" | jq -r .[0].state.network.brlan0.state)
  if [ "${BRLAN0_STATUS}" = "up" ]; then
    break
  fi
  echo "Waiting for brlan0 to startup"
  sleep 20
done

if [ "${BRLAN0_STATUS}" != "up" ]; then
  echo "ERROR: brlan0 interface is not present"
  do_cleanup && exit 1
fi

BRLAN0_HAS_IPV4_GLOBAL=0
BRLAN0_HAS_IPV6_GLOBAL=0
# Wait for brlan0 to present both IPv4 and IPv6 (global) addresses
for i in $(seq 1 15); do
  INCUS_LIST_JSON_ROUTER=$(get_router_info_json)
  NUM_OF_BRLAN0_ADDRESSES=$(echo "${INCUS_LIST_JSON_ROUTER}" | jq -r '.[0].state.network.brlan0.addresses | length')
  for x in $(seq 0 "${NUM_OF_BRLAN0_ADDRESSES}"); do
    INTF_IDX=$(($x - 1))
    THIS_ADDR_INFO=$(echo "${INCUS_LIST_JSON_ROUTER}" | jq -r ".[0].state.network.brlan0.addresses[${INTF_IDX}]")
    if [ "${THIS_ADDR_INFO}" = "null" ]; then
      continue
    fi
    THIS_ADDR_FAMILY=$(echo "${THIS_ADDR_INFO}" | jq -r .family)
    THIS_ADDR_SCOPE=$(echo "${THIS_ADDR_INFO}" | jq -r .scope)
    THIS_ADDRESS=$(echo "${THIS_ADDR_INFO}" | jq -r .address)
    if [ "${THIS_ADDR_SCOPE}" = "global" ]; then
      if [ "${BRLAN0_HAS_IPV4_GLOBAL}" = "0" ] && [ "${THIS_ADDR_FAMILY}" = "inet" ]; then
        echo "Router IPv4 LAN address: ${THIS_ADDRESS}"
        BRLAN0_HAS_IPV4_GLOBAL=1
      elif [ "${BRLAN0_HAS_IPV6_GLOBAL}" = "0" ] &&  [ "${THIS_ADDR_FAMILY}" = "inet6" ]; then
        echo "Router IPv6 LAN address: ${THIS_ADDRESS}"
        BRLAN0_HAS_IPV6_GLOBAL=1
      fi
    fi
  done
  if [ "${BRLAN0_HAS_IPV4_GLOBAL}" = "1" ] && [ "${BRLAN0_HAS_IPV6_GLOBAL}" = "1" ]; then
    break
  fi
  sleep 30
done

if [ "${BRLAN0_HAS_IPV4_GLOBAL}" != "1" ]; then
  echo "ERROR: Router did not assign an IPv4 address to brlan0"
  do_cleanup && exit 1
fi

if [ "${BRLAN0_HAS_IPV6_GLOBAL}" != "1" ]; then
  echo "ERROR: Router did not assign an IPv6 address to brlan0"
  do_cleanup && exit 1
fi

# Validate that the test client (container) has acquired
# IPv4 and IPv6 addresses
TESTCLIENT_HAS_IPV4_ADDRESS=0
TESTCLIENT_HAS_IPV6_ADDRESS=0

for i in $(seq 1 10); do
  TESTCLIENT_INFO_JSON=$(get_testclient_info_json)
  TESTCLIENT_ETH0_ADDR_INFO=$(echo "${TESTCLIENT_INFO_JSON}"  | jq -r ".[0].state.network.eth0.addresses")
  NUM_OF_TESTCLIENT_ADDRS=$(echo "${TESTCLIENT_ETH0_ADDR_INFO}" | jq -r '. | length')
  for n in $(seq 1 "${NUM_OF_TESTCLIENT_ADDRS}"); do
    if_idx=$((n-1))
    THIS_ADDR_INFO=$(echo "${TESTCLIENT_ETH0_ADDR_INFO}" | jq -r ".[${if_idx}]")
    if [ "${THIS_ADDR_INFO}" = "null" ]; then
      continue
    fi
    THIS_ADDR_FAMILY=$(echo "${THIS_ADDR_INFO}" | jq -r .family)
    THIS_ADDR_SCOPE=$(echo "${THIS_ADDR_INFO}" | jq -r .scope)
    THIS_ADDRESS=$(echo "${THIS_ADDR_INFO}" | jq -r .address)
    if [ "${THIS_ADDR_SCOPE}" = "global" ]; then
      if [ "${TESTCLIENT_HAS_IPV4_ADDRESS}" = "0" ] && [ "${THIS_ADDR_FAMILY}" = "inet" ]; then
        echo "Client IPv4 LAN address: ${THIS_ADDRESS}"
        TESTCLIENT_IPV4_ADDRESS_VIA_AGENT="${THIS_ADDRESS}"
        TESTCLIENT_HAS_IPV4_ADDRESS=1
      elif [ "${TESTCLIENT_HAS_IPV6_ADDRESS}" = "0" ] &&  [ "${THIS_ADDR_FAMILY}" = "inet6" ]; then
        echo "Client IPv6 LAN address: ${THIS_ADDRESS}"
        TESTCLIENT_HAS_IPV6_ADDRESS=1
      fi
    fi
  done
  if [ "${TESTCLIENT_HAS_IPV4_ADDRESS}" = "1" ] && [ "${TESTCLIENT_HAS_IPV6_ADDRESS}" = "1" ]; then
    break
  fi
  sleep 30
done

if [ "${TESTCLIENT_HAS_IPV4_ADDRESS}" != "1" ]; then
  echo "ERROR: Test client failed to gain IPv4 address"
  do_cleanup && exit 1
fi

if [ "${TESTCLIENT_HAS_IPV6_ADDRESS}" != "1" ]; then
  echo "ERROR: Test client failed to acquire IPv6 address"
  do_cleanup && exit 1
fi

echo "Running local dmcli / TR-181 test (DHCP)"
# Device.DHCPv4.Server. takes a while to become avaialble on boot
HAS_DHCP_SERVER_POOL_ACTIVE="false"
for i in $(seq 0 5); do
	HAS_DHCP_SERVER_POOL_ACTIVE=$(incus exec "${NEW_ROUTER_INSTANCE_NAME}" -- dmcli eRT retv Device.DHCPv4.Server.Pool.1.Enable || :)
	if [ "${HAS_DHCP_SERVER_POOL_ACTIVE}" = "true" ]; then
		break
	fi
	sleep 10
done

if [ "${HAS_DHCP_SERVER_POOL_ACTIVE}" != "true" ]; then
	echo "ERROR: Device.DHCPv4.Server. is not responding"
	do_cleanup && exit 1
fi

incus exec "${NEW_ROUTER_INSTANCE_NAME}" -- dmcli eRT getv Device.DHCPv4.Server.Pool.1.Client.1. || :
TESTCLIENT_IPV4_ADDRESS_VIA_TR181=$(incus exec "${NEW_ROUTER_INSTANCE_NAME}" -- dmcli eRT retv Device.DHCPv4.Server.Pool.1.Client.1.IPv4Address.1.IPAddress || :)

if [ "${TESTCLIENT_IPV4_ADDRESS_VIA_AGENT}" != "${TESTCLIENT_IPV4_ADDRESS_VIA_TR181}" ]; then
  echo "ERROR: IPv4 Address for test client does not match value in TR181"
  echo "TR181 says: ${TESTCLIENT_IPV4_ADDRESS_VIA_TR181}"
  do_cleanup && exit 1
fi

echo "Running local dmcli / TR-181 test (DeviceInfo WAN Address)"
WAN_IP_ADDRESS=$(incus exec "${NEW_ROUTER_INSTANCE_NAME}" -- dmcli eRT retv Device.DeviceInfo.X_COMCAST-COM_WAN_IP || :)

if [ -z "${WAN_IP_ADDRESS}" ]; then
	echo "ERROR: Unable to obtain WAN IP address via TR181"
	do_cleanup && exit 1
fi

echo "WAN IP address (reported by TR181): ${WAN_IP_ADDRESS}"


incus list

do_cleanup
