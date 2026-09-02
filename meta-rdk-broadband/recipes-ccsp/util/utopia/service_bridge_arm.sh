#!/bin/sh
##########################################################################
# If not stated otherwise in this file or this component's Licenses.txt
# file the following copyright and licenses apply:
#
# Copyright 2018 RDK Management
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

##########################################################################
#   Copyright [2018] [Cisco Systems, Inc.]
# 
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
# 
#       http://www.apache.org/licenses/LICENSE-2.0
# 
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#########################################################################

source /etc/utopia/service.d/hostname_functions.sh
source /etc/utopia/service.d/ulog_functions.sh
source /etc/utopia/service.d/event_handler_functions.sh

SERVICE_NAME="bridge"

UDHCPC_PID_FILE=/var/run/udhcpc.pid
UDHCPC_SCRIPT=/etc/utopia/service.d/service_bridge/dhcp_link.sh

POSTD_START_FILE="/tmp/.postd_started"

#Separate routing table used to ensure that responses from the web UI go directly to the LAN interface, not out erouter0
BRIDGE_MODE_TABLE=69

wan_if="erouter0"
determine_wan_ifname() 
{
   retry=0
   while [ "30" -ge "$retry" ]
   do
      retry=`expr $retry + 1`
      interface1_status=`dmcli eRT getv Device.X_RDK_WanManager.Interface.1.Status | grep value | cut -d':' -f3 | xargs`
      interface2_status=`dmcli eRT getv Device.X_RDK_WanManager.Interface.2.Status | grep value | cut -d':' -f3 | xargs`
      if [ "$interface1_status" == "Active" ] || [ "$interface2_status" == "Active" ]; then 
          break
      fi
      sleep 1
   done
   #Currently BPI has 2 Interfaces
   interface1_status=`dmcli eRT getv Device.X_RDK_WanManager.Interface.1.Status | grep value | cut -d':' -f3 | xargs`
   if [ "$interface1_status" == "Active" ]; then 
      interface_name=`dmcli eRT getv Device.X_RDK_WanManager.Interface.1.VirtualInterface.1.Name | grep value | cut -d':' -f3 | xargs`
      wan_if=$interface_name
      return
   fi
   interface_name=`dmcli eRT getv Device.X_RDK_WanManager.Interface.2.VirtualInterface.1.Name | grep value | cut -d':' -f3 | xargs`
   wan_if=$interface_name 
   #Legacy approach to determine wan interface name
   #wan_if=`sysevent get current_wan_ifname`
}




#--------------------------------------------------------------
# service_init
#--------------------------------------------------------------
service_init ()
{
   # Get all provisioning data
   # Figure out the names and addresses of the lan interface
   #
   # SYSCFG_lan_ethernet_physical_ifnames is the physical ethernet interfaces that
   # will be part of the lan
   #
   # SYSCFG_lan_wl_physical_ifnames is the names of each wireless interface as known
   # to the operating system

   SYSCFG_FAILED='false'
   FOO=`utctx_cmd get bridge_mode lan_ifname lan_ethernet_physical_ifnames lan_wl_physical_ifnames wan_physical_ifname bridge_ipaddr bridge_netmask br
idge_default_gateway bridge_nameserver1 bridge_nameserver2 bridge_nameserver3 bridge_domain hostname`
   eval "$FOO"
  if [ $SYSCFG_FAILED = 'true' ] ; then
     ulog bridge status "$PID utctx failed to get some configuration data"
     ulog bridge status "$PID BRIDGE CANNOT BE CONTROLLED"
     exit
  fi

  if [ -z "$SYSCFG_hostname" ] ; then
     SYSCFG_hostname="Utopia"
  fi 

  LAN_IFNAMES="$SYSCFG_lan_ethernet_physical_ifnames"

   # if we are using wireless interfafes then add them
   if [ -n "$SYSCFG_lan_wl_physical_ifnames" ] ; then
      LAN_IFNAMES="$LAN_IFNAMES $SYSCFG_lan_wl_physical_ifnames"
   fi
}

#Create a virtual lan0 management interface and connect it to the bride
#Also prevent this interface from sending any packets to the DOCSIS bridge
virtual_interface()
{
   echo "Inside virtual_interface"
    CMDIAG_IF=`syscfg get cmdiag_ifname`
    LAN_IP=`syscfg get lan_ipaddr`
    LAN_NETMASK=`syscfg get lan_netmask`

    if [ "$1" = "enable" ] ; then
        echo "ip link add $CMDIAG_IF type veth peer name l${CMDIAG_IF}"
        ip link add "$CMDIAG_IF" type veth peer name l"${CMDIAG_IF}"

        echo 1 > /proc/sys/net/ipv6/conf/llan0/disable_ipv6

        echo "ifconfig $CMDIAG_IF hw ether `cat /sys/class/net/lan0/address`"
        ifconfig "$CMDIAG_IF" hw ether "`cat /sys/class/net/${CMDIAG_IF}/address`"
      
        virtual_interface_ebtables_rules enable

        echo "ifconfig l${CMDIAG_IF} promisc up"
        ifconfig l"${CMDIAG_IF}" promisc up

        echo "ifconfig $CMDIAG_IF $LAN_IP netmask $LAN_NETMASK up"
        ifconfig "$CMDIAG_IF" "$LAN_IP" netmask "$LAN_NETMASK" up

        if [ "$LAN_IP" != "$dst_ip" ]; then
                ifconfig "$CMDIAG_IF" $dst_ip netmask "$LAN_NETMASK" up
        fi
        sysevent set ipv4_4-status down
    else
        ifconfig "$CMDIAG_IF" down
        ifconfig l"${CMDIAG_IF}" down
        ip link del "$CMDIAG_IF"
        virtual_interface_ebtables_rules disable
    fi
}

virtual_interface_ebtables_rules ()
{
    CMDIAG_IF=`syscfg get cmdiag_ifname`
    CMDIAG_MAC=`cat /sys/class/net/"${CMDIAG_IF}"/address`   
    for iface in eth0 erouter0; do
        if [ -e /sys/class/net/$iface/address ]; then
            EROUTER_MAC=$(cat /sys/class/net/$iface/address)
            [ -n "$EROUTER_MAC" ] && break
        fi
    done
    # Optional: handle the case where no MAC address was found
    if [ -z "$EROUTER_MAC" ]; then
        echo "No valid MAC address found for eth0, or erouter0."
    fi
    BRIDGE_NAME=`syscfg get lan_ifname`
    LAN_IP=`syscfg get lan_ipaddr`
     if [ "$1" = "enable" ] ; then
##Filter table
           #--------------------------------------------------------------------------------------
           #####Forward rules for virtual interface(Dont allow lan0 to send traffic to erouter0)
           #--------------------------------------------------------------------------------------

        ebtables -N BRIDGE_FORWARD_FILTER
        ebtables -F BRIDGE_FORWARD_FILTER 2> /dev/null
        ebtables -I FORWARD -j BRIDGE_FORWARD_FILTER

        echo "ebtables -A BRIDGE_FORWARD_FILTER -s $CMDIAG_MAC -o erouter0 -j DROP"
        ebtables -A BRIDGE_FORWARD_FILTER -s "$CMDIAG_MAC" -o erouter0 -j DROP

        echo "ebtables -A BRIDGE_FORWARD_FILTER -j RETURN"
        ebtables -A BRIDGE_FORWARD_FILTER -j RETURN

##NAT TABLE
         #--------------------------------------------------------------------------------------
         ####Redirect traffic destined to lan0 IP to lan0 MAC address from brlan0(Prerouting rules)
         #--------------------------------------------------------------------------------------
        ebtables -t nat -N BRIDGE_REDIRECT
        ebtables -t nat -F BRIDGE_REDIRECT 2> /dev/null
        ebtables -t nat -I PREROUTING -j BRIDGE_REDIRECT

        echo "ebtables -t nat -A BRIDGE_REDIRECT --logical-in $BRIDGE_NAME -p ipv4 --ip-dst $LAN_IP 
              -j dnat --to-destination $CMDIAG_MAC"
        ebtables -t nat -A BRIDGE_REDIRECT --logical-in "$BRIDGE_NAME" -p ipv4 --ip-dst "$LAN_IP" -j dnat --to-destination "$CMDIAG_MAC"

        #echo "ebtables -t nat -A BRIDGE_REDIRECT --logical-in $BRIDGE_NAME -p ipv4 --ip-dst $LAN_IP 
         #    -j forward --forward-dev l$CMDIAG_IF"
        #ebtables -t nat -A BRIDGE_REDIRECT --logical-in $BRIDGE_NAME -p ipv4 --ip-dst $LAN_IP -j forward --forward-dev l$CMDIAG_IF

        echo "ebtables -t nat -A BRIDGE_REDIRECT -j RETURN"
        ebtables -t nat -A BRIDGE_REDIRECT -j RETURN

###BROUTE TABLE
         #--------------------------------------------------------------------------------------
         #DROP target in this BROUTING chain actually broutes the frame(frame has to be routed)
         #--------------------------------------------------------------------------------------
        echo "ebtables -t broute -A BROUTING -i erouter0 -d $EROUTER_MAC -j redirect --redirect-target DROP"
        ebtables -t broute -A BROUTING -i erouter0 -d "$EROUTER_MAC" -j redirect --redirect-target DROP

   else
        echo "ebtables -D FORWARD -j BRIDGE_FORWARD_FILTER"
        ebtables -D FORWARD -j BRIDGE_FORWARD_FILTER

        echo "ebtables -X BRIDGE_FORWARD_FILTER"
        ebtables -X BRIDGE_FORWARD_FILTER

        echo "ebtables -t nat -D PREROUTING -j BRIDGE_REDIRECT"
        ebtables -t nat -D PREROUTING -j BRIDGE_REDIRECT

        echo "ebtables -t nat -X BRIDGE_REDIRECT"
        ebtables -t nat -X BRIDGE_REDIRECT
    fi
}

wan_wait ()
{
   retry=0 
   if [ ! -f /tmp/wan_ip_assigned_to_erouter ]; then 
   while [ "30" -ge "$retry" ]
   do 
       sleep 1
       retry=`expr $retry + 1` 
       #Make sure WAN interface has an IP address before mounting to brlan0
       WAN_IP=`ifconfig -a "$wan-if" grep inet | grep -v inet6 | tr -s " " | cut -d ":" -f2 | cut -d " " -f1`
       if [ -n "$WAN_IP" ] ; then
          touch /tmp/wan_ip_assigned_to_erouter
          break
       fi
   done
   fi
}

add_to_group()
{

  wan_wait
  bridge_name=`syscfg get lan_ifname`
  
  bridge_dir="/sys/class/net/$bridge_name"
  lan_ethernet_ifname=`syscfg get lan_ethernet_physical_ifnames`

  if [  -d "$bridge_dir" ] ;then
     bridge_status=`cat /sys/class/net/"$bridge_name"/operstate`
     if [ "$bridge_status" = "down" ] ; then
        echo "brctl addbr $bridge_name"
        brctl addbr "$bridge_name"
        ip link set "$bridge_name" up
     fi
  else
        echo "brctl addbr $bridge_name"
        brctl addbr "$bridge_name"
        ip link set "$bridge_name" up
  fi

  ifconfig "$lan_ethernet_ifname" up
  brctl addif "$bridge_name" "$lan_ethernet_ifname"

  cmdiag_if=`syscfg get cmdiag_ifname`

  echo "brctl addif brlan0 l$cmdiag_if"
  brctl addif brlan0 l"$cmdiag_if"

  echo "brctl addif brlan0 $wan_if"
  brctl addif brlan0 "$wan_if"

  echo "brctl delif $bridge_name wlan0"
  brctl delif "$bridge_name" wlan0

  echo "brctl delif $bridge_name wlan1"
  brctl delif "$bridge_name" wlan1
  
  bridge_curr_status=`ifconfig -a brlan0 | grep "inet addr" | cut -d ':' -f2 | cut -d ' ' -f1`
  if [ "$bridge_curr_status" != " " ]; then
  lan_ipaddr=`syscfg get lan_ipaddr`
  lan_maskaddr=`ifconfig -a brlan0 | grep Mask | cut -d ':' -f4`
  if [ "$lan_maskaddr" = "255.255.255.0" ] ; then
      subnet=24
  elif [ "$lan_maskaddr" = "255.0.0.0" ] ; then
      subnet=8
  else
      subnet=24 
  fi 
  ip addr del $lan_ipaddr/$subnet dev $bridge_name
  fi
}

del_from_group()
{
  bridge_name=`syscfg get lan_ifname`
  brctl addif "$bridge_name" wlan0
  brctl addif "$bridge_name" wlan1

  cmdiag_if=`syscfg get cmdiag_ifname`

  echo "brctl delif brlan0 l$cmdiag_if $wan_if"
  brctl delif brlan0 l"$cmdiag_if" "$wan_if"
}

filter_local_traffic()
{
     if [ "$1" = "enable" ] ; then
        echo "ebtables -N BRIDGE_OUTPUT_FILTER"
        ebtables -N BRIDGE_OUTPUT_FILTER
        ebtables -F BRIDGE_OUTPUT_FILTER 2> /dev/null
        ebtables -I OUTPUT -j BRIDGE_OUTPUT_FILTER

        echo "ebtables -A BRIDGE_OUTPUT_FILTER --logical-out $BRIDGE_NAME -j DROP"
        ebtables -A BRIDGE_OUTPUT_FILTER --logical-out "$BRIDGE_NAME" -j DROP
        echo "ebtables -A BRIDGE_OUTPUT_FILTER -o erouter0 -j DROP"
        ebtables -A BRIDGE_OUTPUT_FILTER -o erouter0 -j DROP

        #Return from filter chain
        echo "ebtables -A BRIDGE_OUTPUT_FILTER -j RETURN"
        ebtables -A BRIDGE_OUTPUT_FILTER -j RETURN
     else
        ebtables -D OUTPUT -j BRIDGE_OUTPUT_FILTER
        ebtables -X BRIDGE_OUTPUT_FILTER
     fi
}


routing_rules(){
    CMDIAG_IF=`syscfg get cmdiag_ifname`
    LAN_IP=`syscfg get lan_ipaddr`
    if [ "$1" = "enable" ] ; then

        #Send responses from $BRIDGE_NAME IP to a separate bridge mode route table
        echo "ip rule add from $LAN_IP lookup $BRIDGE_MODE_TABLE"
        ip rule add from "$LAN_IP" lookup $BRIDGE_MODE_TABLE

        #if [ "$LAN_IP" != "$dst_ip" ]; then
        #        echo "ip rule add from $dst_ip lookup $BRIDGE_MODE_TABLE"
        #        ip rule add from $dst_ip lookup $BRIDGE_MODE_TABLE
        #fi

        echo "ip route add table $BRIDGE_MODE_TABLE default dev $CMDIAG_IF"
        ip route add table $BRIDGE_MODE_TABLE default dev "$CMDIAG_IF"

    else
        echo "ip rule del from $LAN_IP lookup $BRIDGE_MODE_TABLE"
        ip rule del from "$LAN_IP" lookup $BRIDGE_MODE_TABLE

        #if [ $LAN_IP != $dst_ip ]; then
        #        ip rule del from $dst_ip lookup $BRIDGE_MODE_TABLE
        #fi

        echo "ip route flush table $BRIDGE_MODE_TABLE"
        ip route flush table $BRIDGE_MODE_TABLE
    fi
}

block_bridge(){
    ebtables -A FORWARD -i erouter0 -j DROP
}

#Unblock bridged traffic through erouter0
unblock_bridge(){
    ebtables -D FORWARD -i erouter0 -j DROP
}


#--------------------------------------------------------------
# service_start
#--------------------------------------------------------------
service_start ()
{
   wait_till_end_state ${SERVICE_NAME}
   STATUS=`sysevent get ${SERVICE_NAME}-status`
   echo "sysevent get ${SERVICE_NAME}-status $STATUS"
   if [ "started" != "$STATUS" ] ; then

         sysevent set ${SERVICE_NAME}-errinfo
         sysevent set ${SERVICE_NAME}-status starting

         block_bridge

         virtual_interface enable #create lan0 interface and write ebtable rules

         routing_rules enable

         add_to_group

         filter_local_traffic enable 

         unblock_bridge

         # Force a DHCP renew by issuing a physical link down/up, when WAN port mode switches between bridging and routing
         PSM_MODE=`sysevent get system_psm_mode`
         #if [ "$PSM_MODE" != "1" ]; then
            # It is not a good practice to force all physical links to refresh -- should have used arguments to specify which ports/links
            #gw_lan_refresh
         #fi

       prepare_hostname
       if [  -f /tmp/wifi_initialized ];then
          sysevent set ${SERVICE_NAME}-errinfo
          sysevent set ${SERVICE_NAME}-status started
       else
            sleep 60
            sysevent set ${SERVICE_NAME}-errinfo
            sysevent set ${SERVICE_NAME}-status started
       fi

   fi
}

#--------------------------------------------------------------
# service_stop
#--------------------------------------------------------------
service_stop ()
{
   wait_till_end_state ${SERVICE_NAME}
   #STATUS=`sysevent get ${SERVICE_NAME}-status` 
   #if [ "stopped" != "$STATUS" ] ; then

        sysevent set ${SERVICE_NAME}-errinfo
        sysevent set ${SERVICE_NAME}-status stopping

        block_bridge

        del_from_group

        #Disconnect management interface
        virtual_interface disable
        filter_local_traffic disable
        routing_rules disable

        unblock_bridge

        #Flush connection tracking and packet processor sessions to avoid stale information
        flush_connection_info

        sysevent set ${SERVICE_NAME}-errinfo
        sysevent set ${SERVICE_NAME}-status stopped

#    fi

}

#------------------------------------------------------------------
# ENTRY
#------------------------------------------------------------------
BRIDGE_NAME="$SYSCFG_lan_ifname"
CMDIAG_IF=`syscfg get cmdiag_ifname`

INSTANCE=`sysevent get primary_lan_l2net`
LAN_NETMASK=`syscfg get lan_netmask`

determine_wan_ifname

service_init 
echo "service_bridge_arm.sh called with $1 $2" > /dev/console
case "$1" in
   "${SERVICE_NAME}-start")
      firewall firewall-stop
      service_start
      if [ ! -f "$POSTD_START_FILE" ];
      then
          touch $POSTD_START_FILE
          execute_dir /etc/utopia/post.d/
      fi         
      #gw_lan_refresh
      sysevent set firewall-restart
      ;;
   "${SERVICE_NAME}-stop")
        service_stop
        if [ ! -f "$POSTD_START_FILE" ];
        then
              touch $POSTD_START_FILE
              execute_dir /etc/utopia/post.d/
        fi           
        #gw_lan_refresh
        sysevent set firewall-restart

      ;;
   "${SERVICE_NAME}-restart")
      sysevent set lan-restarting 1
      service_stop
      service_start
      sysevent set lan-restarting 0
      ;;
   *)
      echo "Usage: service-${SERVICE_NAME} [ ${SERVICE_NAME}-start | ${SERVICE_NAME}-stop | ${SERVICE_NAME}-restart]" > /dev/console
      exit 3
      ;;
esac

