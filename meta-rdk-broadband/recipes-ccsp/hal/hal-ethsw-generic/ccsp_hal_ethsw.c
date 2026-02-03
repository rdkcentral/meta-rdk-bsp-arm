/*
 * If not stated otherwise in this file or this component's LICENSE file the
 * following copyright and licenses apply:
 *
 * Copyright 2015 RDK Management
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

/**********************************************************************
   Copyright [2014] [Cisco Systems, Inc.]
 
   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at
 
       http://www.apache.org/licenses/LICENSE-2.0
 
   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
**********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <stdbool.h>
#include <pthread.h>

#include "ccsp_hal_ethsw.h" 

#include <netlink/netlink.h>
#include <netlink/route/link.h>
#include <linux/if.h>

/**********************************************************************
                    DEFINITIONS
**********************************************************************/

#define  CcspHalEthSwTrace(msg)                     printf("%s - ", __FUNCTION__); printf msg;
#define MAX_BUF_SIZE 1024
#define MACADDRESS_SIZE 6
#define LM_ARP_ENTRY_FORMAT  "%63s %63s %63s %63s %17s %63s"

#if defined(FEATURE_RDKB_WAN_MANAGER)
static pthread_t ethsw_tid;
static int hal_init_done = 0;
appCallBack ethWanCallbacks;
#define  ETH_INITIALIZE  "/tmp/ethagent_initialized"
#define  LINK_VALUE_SIZE  50
#endif

INT (*linkEventCallback)(CHAR *ifname, CHAR *state) = NULL;

/**********************************************************************
                            MAIN ROUTINES
**********************************************************************/

CCSP_HAL_ETHSW_ADMIN_STATUS admin_status;
struct nl_sock *sk;

int is_interface_exists(const char *fname)
{
    if (!access(fname, 0|F_OK ))
        return 1;
    return 0;
}

typedef enum {
    FIRST_RUN,
    LINK_WAS_DOWN,
    LINK_WAS_UP
} previous_link_status_t;

#define ETH_INTF_MAX 10

/* Why does CosaDmlEthPortLinkStatusCallback want these? */
#define ETHOE_STATUS_UP_TEXT        "Up"
#define ETHOE_STATUS_DOWN_TEXT      "Down"

#if defined(FEATURE_RDKB_WAN_MANAGER)
void *ethsw_thread_main(void *context __attribute__((unused)))
{
    FILE *fp = NULL;
    char cmd[128], buff[LINK_VALUE_SIZE], *pLink, *previousLinkDetected = "no";
    int retries = 180;
    int err;
    unsigned int link_flags;
    struct rtnl_link *link;
    uint8_t x;
    char eth_intf_names[32];
    /* TODO: Get link list dynamically on each run,
     * to handle interfaces appearing/disappearing,
     * especially during the boot process
     */
    previous_link_status_t link_statuses[ETH_INTF_MAX];
    
    CcspHalEthSwTrace(("%s called\n", __func__));

    sleep(60);
  
    for(x=0; x<ETH_INTF_MAX; x++) {
        link_statuses[x] = FIRST_RUN;
    }

    CcspHalEthSwTrace(("%s: Netlink version active\n", __func__));
    while(1) {
        if (linkEventCallback == NULL) {
            sleep(1);
            continue;
        }
        for(x=0; x<ETH_INTF_MAX; x++) {
            snprintf(eth_intf_names,32,"eth%d", x);
            if ((err = rtnl_link_get_kernel(sk, 0, &eth_intf_names, &link)) < 0) {
                /* Ignore "missing" interfaces */
                if (err == -NLE_NODEV)
                    continue;
                CcspHalEthSwTrace(("%s: Unable to get link for interface %s (%d)\n",__func__, eth_intf_names, err));
                continue;
            }
            link_flags = rtnl_link_get_flags(link);
            if (link_flags & IFF_RUNNING) {
                if (link_statuses[x] != LINK_WAS_UP) {
                    CcspHalEthSwTrace(("%s: Reporting interface %s as UP\n",__func__, eth_intf_names));
                    linkEventCallback((char *)&eth_intf_names[0], "Up");
                    link_statuses[x] = LINK_WAS_UP;
                }
            } else if (link_statuses[x] != LINK_WAS_DOWN) {
                    CcspHalEthSwTrace(("%s: Reporting interface %s as DOWN\n",__func__, eth_intf_names));
                    linkEventCallback((char *)&eth_intf_names[0], "Down");
                    link_statuses[x] = LINK_WAS_DOWN;
            }
        }
        sleep(1);
    }

    return NULL;
}

void CcspHalEthSw_RegisterLinkEventCallback(INT (*newLinkEventCallback)(CHAR *ifname, CHAR *state))
{
    CcspHalEthSwTrace(("%s called\n", __func__));
    linkEventCallback = newLinkEventCallback;
}

void GWP_RegisterEthWan_Callback(appCallBack *obj)
{
    if (obj != NULL)
    {
        ethWanCallbacks.pGWP_act_EthWanLinkUP = obj->pGWP_act_EthWanLinkUP;
        ethWanCallbacks.pGWP_act_EthWanLinkDown = obj->pGWP_act_EthWanLinkDown;
    }

    return;
}

INT
    GWP_GetEthWanInterfaceName
(
 unsigned char * Interface,
 ULONG           maxSize
 )
{
    FILE *fp = NULL;
    char temp_ifname[20] = {0};

    CcspHalEthSwTrace(("%s called\n", __func__));

    if (!Interface)
    {
        printf("ERROR: Invalid argument (NULL Interface).\n");
        return RETURN_ERR;
    }

    fp = popen("psmcli get dmsb.wanmanager.if.1.Name", "r");
    if (!fp)
    {
        CcspHalEthSwTrace(("%s: Failed to run psmcli\n", __FUNCTION__));
        return RETURN_ERR;
    }

    if (!fgets(temp_ifname, sizeof(temp_ifname), fp))
    {
        CcspHalEthSwTrace(("%s: No output from psmcli (WAN interface not found)\n",
                            __FUNCTION__));
        pclose(fp);
        return RETURN_ERR;
    }

    pclose(fp);
    temp_ifname[strcspn(temp_ifname, "\n")] = 0;

    if (strlen(temp_ifname) == 0)
    {
        CcspHalEthSwTrace(("%s: ERROR: WAN interface empty after psmcli\n",
                            __FUNCTION__));
        return RETURN_ERR;
    }

    if (maxSize < strlen(temp_ifname) + 1)
    {
        CcspHalEthSwTrace(("WARNING: Buffer too small for interface (%s)\n",
                            temp_ifname));
        return RETURN_ERR;
    }
    snprintf(Interface, maxSize, "%s", temp_ifname);
    return RETURN_OK;
}
#endif

/* CcspHalEthSwInit :  */
/**
* @description Do what needed to intialize the Eth hal.
* @param None
*
* @return The status of the operation.
* @retval RETURN_OK if successful.
* @retval RETURN_ERR if any error is detected
*
* @execution Synchronous.
* @sideeffect None.

*
* @note This function must not suspend and must not invoke any blocking system
* calls. It should probably just send a message to a driver event handler task.
*
*/
INT
CcspHalEthSwInit
    (
        void
    )
{
#if defined(FEATURE_RDKB_WAN_MANAGER)
    int rc;
    int err;

    if (hal_init_done) {
        return RETURN_OK;
    }

    sk = nl_socket_alloc();
    if ((err = nl_connect(sk, NETLINK_ROUTE)) < 0) {
        CcspHalEthSwTrace(("%s: Unable to connect netlink socket (%d)\n",__func__,err));
		return RETURN_ERR;
	}
    // Create thread to handle async events and callbacks.
    rc = pthread_create(&ethsw_tid, NULL, ethsw_thread_main, NULL);
    if (rc != 0) {
        return RETURN_ERR;
    }

    hal_init_done = 1;
#endif
    return  RETURN_OK;
}


/* CcspHalEthSwGetPortStatus :  */
/**
* @description Retrieve the current port status -- link speed, duplex mode, etc.

* @param PortId      -- Port ID as defined in CCSP_HAL_ETHSW_PORT
* @param pLinkRate   -- Receives the current link rate, as in CCSP_HAL_ETHSW_LINK_RATE
* @param pDuplexMode -- Receives the current duplex mode, as in CCSP_HAL_ETHSW_DUPLEX_MODE
* @param pStatus     -- Receives the current link status, as in CCSP_HAL_ETHSW_LINK_STATUS

*
* @return The status of the operation.
* @retval RETURN_OK if successful.
* @retval RETURN_ERR if any error is detected
*
* @execution Synchronous.
* @sideeffect None.

*
* @note This function must not suspend and must not invoke any blocking system
* calls. It should probably just send a message to a driver event handler task.
*
*/
INT
CcspHalEthSwGetPortStatus
    (
        CCSP_HAL_ETHSW_PORT         PortId,
        PCCSP_HAL_ETHSW_LINK_RATE   pLinkRate,
        PCCSP_HAL_ETHSW_DUPLEX_MODE pDuplexMode,
        PCCSP_HAL_ETHSW_LINK_STATUS pStatus
    )
{
    int eth_if;

    if(!pLinkRate || !pDuplexMode || !pStatus)
    {
        printf("ERROR: Invalid argument. \n");
        return RETURN_ERR;
    }
    eth_if=is_interface_exists("/sys/class/net/eth1");

    if(!admin_status && eth_if)
        *pStatus  = CCSP_HAL_ETHSW_LINK_Up;
    else
        *pStatus   = CCSP_HAL_ETHSW_LINK_Down;

    switch (PortId)
    {
        case CCSP_HAL_ETHSW_EthPort1:
        {
            *pLinkRate      = CCSP_HAL_ETHSW_LINK_100Mbps;
            *pDuplexMode    = CCSP_HAL_ETHSW_DUPLEX_Full;
            break;
        }

        case CCSP_HAL_ETHSW_EthPort2:
        {
            *pLinkRate      = CCSP_HAL_ETHSW_LINK_1Gbps;
            *pDuplexMode    = CCSP_HAL_ETHSW_DUPLEX_Full;
            break;
        }

        case CCSP_HAL_ETHSW_EthPort3:
        {
            *pLinkRate      = CCSP_HAL_ETHSW_LINK_NULL;
            *pDuplexMode    = CCSP_HAL_ETHSW_DUPLEX_Auto;
            break;
        }

        case CCSP_HAL_ETHSW_EthPort4:
        {
            *pLinkRate      = CCSP_HAL_ETHSW_LINK_NULL;
            *pDuplexMode    = CCSP_HAL_ETHSW_DUPLEX_Auto;
            break;
        }

        default:
        {
            CcspHalEthSwTrace(("Unsupported port id %d\n", PortId));
            return  RETURN_ERR;
        }
    }
    return  RETURN_OK;
}


/* CcspHalEthSwGetPortCfg :  */
/**
* @description Retrieve the current port config -- link speed, duplex mode, etc.

* @param PortId      -- Port ID as defined in CCSP_HAL_ETHSW_PORT
* @param pLinkRate   -- Receives the current link rate, as in CCSP_HAL_ETHSW_LINK_RATE
* @param pDuplexMode -- Receives the current duplex mode, as in CCSP_HAL_ETHSW_DUPLEX_MODE

*
* @return The status of the operation.
* @retval RETURN_OK if successful.
* @retval RETURN_ERR if any error is detected
*
* @execution Synchronous.
* @sideeffect None.

*
* @note This function must not suspend and must not invoke any blocking system
* calls. It should probably just send a message to a driver event handler task.
*
*/
INT
CcspHalEthSwGetPortCfg
    (
        CCSP_HAL_ETHSW_PORT         PortId,
        PCCSP_HAL_ETHSW_LINK_RATE   pLinkRate,
        PCCSP_HAL_ETHSW_DUPLEX_MODE pDuplexMode
    )
{
    if(!pLinkRate || !pDuplexMode)
    {
        printf("ERROR: Invalid argument. \n");
        return RETURN_ERR;
    }
    switch (PortId)
    {
        case CCSP_HAL_ETHSW_EthPort1:
        {
            *pLinkRate      = CCSP_HAL_ETHSW_LINK_Auto;
            *pDuplexMode    = CCSP_HAL_ETHSW_DUPLEX_Auto;

            break;
        }

        case CCSP_HAL_ETHSW_EthPort2:
        {
            *pLinkRate      = CCSP_HAL_ETHSW_LINK_1Gbps;
            *pDuplexMode    = CCSP_HAL_ETHSW_DUPLEX_Full;

            break;
        }

        case CCSP_HAL_ETHSW_EthPort3:
        {
            *pLinkRate      = CCSP_HAL_ETHSW_LINK_100Mbps;
            *pDuplexMode    = CCSP_HAL_ETHSW_DUPLEX_Auto;

            break;
        }

        case CCSP_HAL_ETHSW_EthPort4:
        {
            *pLinkRate      = CCSP_HAL_ETHSW_LINK_10Mbps;
            *pDuplexMode    = CCSP_HAL_ETHSW_DUPLEX_Half;

            break;
        }

        default:
        {
            CcspHalEthSwTrace(("Unsupported port id %d", PortId));
            return  RETURN_ERR;
        }
    }

    return  RETURN_OK;
}


/* CcspHalEthSwSetPortCfg :  */
/**
* @description Set the port configuration -- link speed, duplex mode

* @param PortId      -- Port ID as defined in CCSP_HAL_ETHSW_PORT
* @param LinkRate    -- Set the link rate, as in CCSP_HAL_ETHSW_LINK_RATE
* @param DuplexMode  -- Set the duplex mode, as in CCSP_HAL_ETHSW_DUPLEX_MODE

*
* @return The status of the operation.
* @retval RETURN_OK if successful.
* @retval RETURN_ERR if any error is detected
*
* @execution Synchronous.
* @sideeffect None.

*
* @note This function must not suspend and must not invoke any blocking system
* calls. It should probably just send a message to a driver event handler task.
*
*/
INT
CcspHalEthSwSetPortCfg
    (
        CCSP_HAL_ETHSW_PORT         PortId,
        CCSP_HAL_ETHSW_LINK_RATE    LinkRate,
        CCSP_HAL_ETHSW_DUPLEX_MODE  DuplexMode
    )
{
    CcspHalEthSwTrace(("set port %d LinkRate to %d, DuplexMode to %d", PortId, LinkRate, DuplexMode));

    switch (PortId)
    {
        case CCSP_HAL_ETHSW_EthPort1:
        {
            break;
        }

        case CCSP_HAL_ETHSW_EthPort2:
        {
            break;
        }

        case CCSP_HAL_ETHSW_EthPort3:
        {
            break;
        }

        case CCSP_HAL_ETHSW_EthPort4:
        {
            break;
        }

        default:
            CcspHalEthSwTrace(("Unsupported port id %d", PortId));
            return  RETURN_ERR;
    }

    return  RETURN_OK;
}


/* CcspHalEthSwGetPortAdminStatus :  */
/**
* @description Retrieve the current port admin status.

* @param PortId      -- Port ID as defined in CCSP_HAL_ETHSW_PORT
* @param pAdminStatus -- Receives the current admin status

*
* @return The status of the operation.
* @retval RETURN_OK if successful.
* @retval RETURN_ERR if any error is detected
*
* @execution Synchronous.
* @sideeffect None.

*
* @note This function must not suspend and must not invoke any blocking system
* calls. It should probably just send a message to a driver event handler task.
*
*/
/*readlink info has changed for Port 1 and 4 hence making the required changes to get the port info and set as well
 *
 * interface 1  --> mapped to usb2
 *sys/devices/platform/scb/fd500000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0/usb2/2-2/2-2:1.0/net/eth1

 *interface 2  --> mapped to usb1
 *sys/devices/platform/scb/fd500000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0/usb1/1-1/1-1.3/1-1.3:1.0/net/eth1

 *interface 3  --> mapped to usb1
 *sys/devices/platform/scb/fd500000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0/usb1/1-1/1-1.4/1-1.4:1.0/net/eth1

 *interface 4  --> mapped to usb2
 *sys/devices/platform/scb/fd500000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0/usb2/2-1/2-1:1.0/net/eth1
*/
INT
CcspHalEthSwGetPortAdminStatus
    (
        CCSP_HAL_ETHSW_PORT           PortId,
        PCCSP_HAL_ETHSW_ADMIN_STATUS  pAdminStatus
    )
{
    FILE *fp;
    char port_id[256], *val1="-2:", *val= "/1-1.", *val2="-1:",*p= NULL, *next = NULL;
    int port_num=0;

    CcspHalEthSwTrace(("port id %d", PortId));

    if(!pAdminStatus)
    {
        printf("ERROR: Invalid argument. \n");
        return RETURN_ERR;
    }
    if(!(fp = popen("readlink -f /sys/class/net/eth1", "r")))
        return RETURN_ERR;
    fgets(port_id, sizeof(port_id), fp);
    if((p=strstr(port_id, val1))){
        p=strtok(p, "-:");
        port_num = atoi(p);
        if(port_num == 2)
            port_num--;

    }
    else if((p=strstr(port_id, val2))){
        p=strtok(p, "-:");
        port_num = atoi(p);
        if(port_num == 1)
            port_num = 4;
    }
    else if((p = strstr(port_id, val))){
        strtok_r(p, ".", &next);
        p = strtok_r(next, "/", &next);
        port_num = atoi(p);
        if (port_num != 1)
              port_num--;
        else
              port_num = 4;
    }
    else
        printf("string not matching\n");

    switch (PortId)
    {
        case CCSP_HAL_ETHSW_EthPort1:
        case CCSP_HAL_ETHSW_EthPort2:
        case CCSP_HAL_ETHSW_EthPort3:
        case CCSP_HAL_ETHSW_EthPort4:
        {
        if(port_num==PortId)
             *pAdminStatus = CCSP_HAL_ETHSW_AdminUp;
        else
             *pAdminStatus = CCSP_HAL_ETHSW_AdminDown;
            break;
        }
        default:
            CcspHalEthSwTrace(("Unsupported port id %d", PortId));
            return  RETURN_ERR;
    }
    if(admin_status)
        *pAdminStatus = CCSP_HAL_ETHSW_AdminDown;

  return  RETURN_OK;
}

/* CcspHalEthSwSetPortAdminStatus :  */
/**
* @description Set the ethernet port admin status

* @param AdminStatus -- set the admin status, as defined in CCSP_HAL_ETHSW_ADMIN_STATUS

*
* @return The status of the operation.
* @retval RETURN_OK if successful.
* @retval RETURN_ERR if any error is detected
*
* @execution Synchronous.
* @sideeffect None.

*
* @note This function must not suspend and must not invoke any blocking system
* calls. It should probably just send a message to a driver event handler task.
*
*/
INT
CcspHalEthSwSetPortAdminStatus
    (
        CCSP_HAL_ETHSW_PORT         PortId,
        CCSP_HAL_ETHSW_ADMIN_STATUS AdminStatus
    )
{
    FILE *fp;
    char cmd[128], port_id[256], *val1="-2:", *val= "/1-1.", *val2="-1:",*p, *next;
    char *interface = "eth1";
    int port_num=0;

    CcspHalEthSwTrace(("set port %d AdminStatus to %d", PortId, AdminStatus));
    if(!(AdminStatus == CCSP_HAL_ETHSW_AdminUp || AdminStatus == CCSP_HAL_ETHSW_AdminDown || AdminStatus == CCSP_HAL_ETHSW_AdminTest))
        return RETURN_ERR;
    if(!is_interface_exists("/sys/class/net/eth1"))
        return  RETURN_ERR;

    if(!(fp= popen("readlink -f /sys/class/net/eth1","r")))
        return  RETURN_ERR;
    fgets(port_id,sizeof(port_id),fp);

    if((p=strstr(port_id, val1))){
        p=strtok(p, "-:");
        port_num = atoi(p);
        if(port_num == 2)
            port_num--;

    }
    else if((p=strstr(port_id, val2))){
        p=strtok(p, "-:");
        port_num = atoi(p);
        if(port_num == 1)
            port_num = 4;
    }  
    else if((p = strstr(port_id, val))){
        strtok_r(p, ".", &next);
        p = strtok_r(next, "/", &next);
        port_num = atoi(p);
        if (port_num != 1)
              port_num--;
        else
              port_num = 4;
    }
    else
        printf("string not matching\n");

    switch (PortId)
    {
        case CCSP_HAL_ETHSW_EthPort1:
        case CCSP_HAL_ETHSW_EthPort2:
        case CCSP_HAL_ETHSW_EthPort3:
        case CCSP_HAL_ETHSW_EthPort4:
        {
            if(port_num==PortId)
            {
                 if(AdminStatus==0)
                 {
                    snprintf(cmd, sizeof(cmd), "ip link set %s up", interface);
                    system(cmd);
                    admin_status=0;
                 }
                 else
                 {
                     snprintf(cmd, sizeof(cmd), "ip link set %s down", interface);
                     system(cmd);
                     admin_status=1;
                 }
             }
             break;
        }
        default:
            CcspHalEthSwTrace(("Unsupported port id %d", PortId));
            return  RETURN_ERR;
    }
    return  RETURN_OK;
}


/* CcspHalEthSwSetAgingSpeed :  */
/**
* @description Set the ethernet port configuration -- admin up/down, link speed, duplex mode

* @param PortId      -- Port ID as defined in CCSP_HAL_ETHSW_PORT
* @param AgingSpeed  -- integer value of aging speed
*
* @return The status of the operation.
* @retval RETURN_OK if successful.
* @retval RETURN_ERR if any error is detected
*
* @execution Synchronous.
* @sideeffect None.

*
* @note This function must not suspend and must not invoke any blocking system
* calls. It should probably just send a message to a driver event handler task.
*
*/
INT
CcspHalEthSwSetAgingSpeed
    (
        CCSP_HAL_ETHSW_PORT         PortId,
        INT                         AgingSpeed
    )
{
    CcspHalEthSwTrace(("set port %d aging speed to %d", PortId, AgingSpeed));

    return  RETURN_OK;
}

/* get_port_number */
/**
* @description Retrieve the port number

* @return The value of the port number.
*/
static int get_port_number()
{
    FILE *fp = NULL;
    char port_id[256], *val1="-2:", *val= "/1-1.", *val2="-1:",*p= NULL, *next = NULL;
    int port_num=-1;

    if(!(fp = popen("readlink -f /sys/class/net/eth1", "r")))
        return RETURN_ERR;
    fgets(port_id, sizeof(port_id), fp);
    if((p=strstr(port_id, val1))){
        p=strtok(p, "-:");
        port_num = atoi(p);
        if(port_num == 2)
            port_num--;
    }
    else if((p=strstr(port_id, val2))){
        p=strtok(p, "-:");
        port_num = atoi(p);
        if(port_num == 1)
            port_num = 4;
    }
    else if((p = strstr(port_id, val))){
        strtok_r(p, ".", &next);
        p = strtok_r(next, "/", &next);
        port_num = atoi(p);
        if (port_num != 1)
              port_num--;
        else
              port_num = 4;
    }
    else
    {
        fprintf(stderr,"string not matching\n");
    }
    return port_num;
}

/* CcspHalEthSwLocatePortByMacAddress :  */
/**
* @description Retrieve the port number that the specificed MAC address is associated with (seen)

* @param pMacAddr    -- Specifies the MAC address -- 6 bytes
* @param pPortId     -- Receives the found port number that the MAC address is seen on

*
* @return The status of the operation.
* @retval RETURN_OK if successful.
* @retval RETURN_ERR if any error is detected
*
* @execution Synchronous.
* @sideeffect None.

*
* @note This function must not suspend and must not invoke any blocking system
* calls. It should probably just send a message to a driver event handler task.
*
*/
INT
CcspHalEthSwLocatePortByMacAddress
    (
		unsigned char * pMacAddr, 
		INT * pPortId
    )
{
    eth_device_t *pstRecvEthDevice      = NULL;
    ULONG         ulTotalEthDeviceCount = 0;
    INT           iLoopCount, i;
    UCHAR         macAddrChar[MACADDRESS_SIZE];

    //Validate NULL
    if( ( NULL == pMacAddr ) || ( NULL == pPortId ) )
    {
        CcspHalEthSwTrace(("Invalid Argument\n"));
        return RETURN_ERR;
    }

    if(MACADDRESS_SIZE  != sscanf(pMacAddr, "%02hhx:%02hhx:%02hhx:%02hhx:%02hhx:%02hhx", &macAddrChar[0], &macAddrChar[1], &macAddrChar[2],
                            &macAddrChar[3], &macAddrChar[4], &macAddrChar[5]))
    {
        CcspHalEthSwTrace(("Wrong MAC address due to wrong format\n"));
        return RETURN_ERR;
    }

    CcspHalEthSwTrace
        ((
            "%s -- search for MAC address after conversion is =  %02X:%02X:%02X:%02X:%02X:%02X \n",
            __FUNCTION__,
            macAddrChar[0], macAddrChar[1], macAddrChar[2],
            macAddrChar[3], macAddrChar[4], macAddrChar[5]
        ));

    //Get Associated Device Details.
    if( -1 == CcspHalExtSw_getAssociatedDevice( &ulTotalEthDeviceCount, &pstRecvEthDevice ) )
    {
        CcspHalEthSwTrace(("%s %d - Fail to get AssociatedDevice details\n" ,__FUNCTION__,__LINE__));
        return RETURN_ERR;
    }

    for( iLoopCount = 0; iLoopCount < ulTotalEthDeviceCount; iLoopCount++ )
    {
        for( i = 0; i < MACADDRESS_SIZE; i++)
        {
            //Check whether received MAC is matching with associated list or not
            if( macAddrChar[i] != pstRecvEthDevice[ iLoopCount ].eth_devMacAddress[i])
            {
                break;
            }
        }
        //Return valid port number
        if( i == MACADDRESS_SIZE )
        {
            *pPortId = get_port_number();
            return RETURN_OK;
        }
    }
    return RETURN_ERR;
}

//For Getting Current Interface Name from corresponding hostapd configuration
void GetInterfaceName(char *interface_name, char *conf_file)
{
    FILE *fp = NULL;
    char path[MAX_BUF_SIZE] = {0},output_string[MAX_BUF_SIZE] = {0},fname[MAX_BUF_SIZE] = {0};
    int count = 0;
    char *interface = NULL;

    fp = fopen(conf_file, "r");
    if(fp == NULL)
    {
        printf("conf_file %s not exists \n", conf_file);
        return;
    }
    fclose(fp);

    sprintf(fname,"%s%s%s","cat ",conf_file," | grep interface=");
    fp = popen(fname,"r");
    if(fp == NULL)
    {
        printf("Failed to run command in Function %s\n",__FUNCTION__);
        strcpy(interface_name, "");
        return;
    }
    if(fgets(path, sizeof(path)-1, fp) != NULL)
    {
        interface = strchr(path,'=');

        if(interface != NULL)
            strcpy(output_string, interface+1);
    }

    for(count = 0;output_string[count]!='\n';count++)
            interface_name[count] = output_string[count];
    interface_name[count]='\0';

    pclose(fp);
}

/* CcspHalExtSw_getAssociatedDevice :  */
/**
* @description Collected the active wired clients information

* @param output_array_size    -- Size of the active wired connected clients
* @param output_struct     -- Structure of  wired clients informations

*
* @return The status of the operation.
* @retval RETURN_OK if successful.
* @retval RETURN_ERR if any error is detected
*
*/

INT CcspHalExtSw_getAssociatedDevice(ULONG *output_array_size, eth_device_t **output_struct)
{
    CHAR buf[MAX_BUF_SIZE] = {0};
    FILE *fp = NULL;
    INT count = 0;
    ULONG maccount = 0, port_no = 0;
    INT arr[MACADDRESS_SIZE] = {0};
    UCHAR mac[MACADDRESS_SIZE] = {0};

    if(output_struct == NULL)
    {
        fprintf(stderr,"\nNot enough memory\n");
        return RETURN_ERR;
    }
    if( access( "/tmp/ethernetmac.txt", F_OK ) != -1 ) {
        remove("/tmp/ethernetmac.txt");
    }

#if 0
/*
port no mac addr                is local?       ageing time
  2     20:7b:d2:73:28:b4       yes                0.00
  2     58:8a:5a:18:e4:2c       no                 0.08
*/
/* Getting the mac addresses of only ethernet connected devices
 * cat /sys/class/net/brlan0/lower_eth1/brport/port_no to get port number of eth1 interface
 */
    fp=popen("cat /sys/class/net/brlan0/lower_eth1/brport/port_no","r");
    if(fp == NULL)
        return RETURN_ERR;
    else
    {
        fgets(buf,MAX_BUF_SIZE,fp);
        port_no = strtol(buf,NULL,16);
        fprintf(stderr,"eth1 interface port number is = %d \n",port_no);
    }
    pclose(fp);
    memset(buf,0,sizeof(buf));
    snprintf(buf, sizeof(buf), "brctl showmacs brlan0 | grep no | awk '$1 == \"%d\" {print $2}' > /tmp/ethernetmac.txt", port_no);
    system(buf);
    fp=popen("cat /tmp/ethernetmac.txt | wc -l","r"); // For getting the  ethernet connected mac count
    if(fp == NULL)
        return RETURN_ERR;
    else
    {
        memset(buf,0,sizeof(buf));
        fgets(buf,MAX_BUF_SIZE,fp);
        maccount = atol(buf);
        fprintf(stderr,"ethernet umac is %d \n",maccount);
    }
    pclose(fp);
    eth_device_t *temp=NULL;
    temp = (eth_device_t*)calloc(1, sizeof(eth_device_t)*maccount);
    if(temp == NULL)
    {
        fprintf(stderr,"Not enough memory \n");
        return RETURN_ERR;
    }
    fp=fopen("/tmp/ethernetmac.txt","r"); // reading the ethernet associated device information
    if(fp == NULL)
    {
        *output_struct = NULL;
        *output_array_size = 0;
        return RETURN_ERR;
    }
    else
    {
        memset(buf,0,sizeof(buf));
        for(count = 0;count < maccount ; count++)
        {
            fgets(buf,sizeof(buf),fp);
            if(MACADDRESS_SIZE  == sscanf(buf, "%02x:%02x:%02x:%02x:%02x:%02x",&arr[0],&arr[1],&arr[2],&arr[3],&arr[4],&arr[5]) )
            {
                for( int ethclientindex = 0; ethclientindex < 6; ++ethclientindex )
                {
                    mac[ethclientindex] = (unsigned char) arr[ethclientindex];
                }
                memcpy(temp[count].eth_devMacAddress,mac,(sizeof(unsigned char))*6);
                fprintf(stderr,"MAC %d = %X:%X:%X:%X:%X:%X \n", count, temp[count].eth_devMacAddress[0],temp[count].eth_devMacAddress[1], temp[count].eth_devMacAddress[2], temp[count].eth_devMacAddress[3], temp[count].eth_devMacAddress[4], temp[count].eth_devMacAddress[5]);
            }
            temp[count].eth_port=1;
            temp[count].eth_vlanid=10;
            temp[count].eth_devTxRate=100;
            temp[count].eth_devRxRate=100;
            temp[count].eth_Active=1;
        }
    }
    fclose(fp);
    *output_struct = temp;
    *output_array_size = maccount;
    fprintf(stderr,"Connected Active ethernet clients count is %ld \n",*output_array_size);
#else
    fprintf(stderr,"%s not implemented on generic arm platforms yet\n", __func__);
#endif
    return 	RETURN_OK;
}

/* CcspHalExtSw_getEthWanEnable  */
/**
* @description Return the Ethwan Enbale status

* @param enable    -- Having status of WANMode ( Ethernet,DOCSIS)

*
* @return The status of the operation.
* @retval RETURN_OK if successful.
* @retval RETURN_ERR if any error is detected
*
*/

INT CcspHalExtSw_getEthWanEnable(BOOLEAN *enable)
{
    CcspHalEthSwTrace(("%s called\n", __func__));
    *enable = 1; // Raspberrypi doesn't have docsis support.so, it always return as 1.
    return RETURN_OK;
}

/* CcspHalExtSw_getEthWanPort:  */
/**
* @description Return the ethwan port

* @param port    -- having ethwan port

*
* @return The status of the operation.
* @retval RETURN_OK if successful.
* @retval RETURN_ERR if any error is detected
*
*/

INT CcspHalExtSw_getEthWanPort(UINT *Port)
{
    CcspHalEthSwTrace(("%s called\n",__func__));
    *Port = 0;
    return RETURN_OK;
}

/* CcspHalExtSw_setEthWanEnable :  */
/**
* @description setting the ethwan enable status

* @enable    -- Switch from ethernet mode to docsis mode or vice-versa

*
* @return The status of the operation.
* @retval RETURN_OK if successful.
* @retval RETURN_ERR if any error is detected
*
*/

INT CcspHalExtSw_setEthWanEnable(BOOLEAN enable)
{
    enable = 0;
    return RETURN_OK;
}


/* CcspHalExtSw_setEthWanPort :  */
/**
* @description  Need to set the ethwan port

* @param port    -- Setting the ethwan port

*
* @return The status of the operation.
* @retval RETURN_OK if successful.
* @retval RETURN_ERR if any error is detected
*
*/

INT CcspHalExtSw_setEthWanPort(UINT Port)
{
    Port = 0;
    return RETURN_OK;
}

bool rpiNet_isInterfaceLinkUp(const char *ifname)
{
    int  skfd;
    struct ifreq intf;
    bool isUp = FALSE;

    if(ifname == NULL) {
        return FALSE;
    }

    if ((skfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
        return FALSE;
    }

    strcpy(intf.ifr_name, ifname);

    if (ioctl(skfd, SIOCGIFFLAGS, &intf) == -1) {
        isUp = 0;
    } else {
        isUp = (intf.ifr_flags & (IFF_RUNNING | IFF_LOWER_UP)) ? TRUE : FALSE;
    }

    close(skfd);
    return isUp;
}

INT GWP_GetEthWanLinkStatus()
{
    INT status = 0;
    char wan_ifname[IFNAMSIZ];

    if (GWP_GetEthWanInterfaceName(&wan_ifname, IFNAMSIZ) != RETURN_OK) {
        fprintf(stderr, "%s: Failed to get WAN Interface name\n");
        return RETURN_ERR;
    }

    status = rpiNet_isInterfaceLinkUp((char *)&wan_ifname) ? TRUE : FALSE;
    return status;
}
