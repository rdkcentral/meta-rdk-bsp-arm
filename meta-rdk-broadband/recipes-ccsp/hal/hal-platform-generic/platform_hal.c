/************************************************************************************
  If not stated otherwise in this file or this component's LICENSE file the
  following copyright and licenses apply:

  Copyright 2025 RDK Management

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
 **************************************************************************/

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

/* Derived from platform_hal.c in Raspberry Pi RDK-B HAL */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "utctx/utctx.h"
#include "utctx/utctx_api.h"

#include "platform_hal.h"

#define MAX_CMD_SIZE        512
#define MAX_BUFFER_SIZE     1024
#define TMP_BUFFER_SIZE     128
#define ONE_KILOBYTE        1024
#define FACTORY_RESET_COUNT_FILE "/nvram/.factory_reset_count"

#define DHCP_VENDOR_OPTION_FILE         "/etc/udhcpc.vendor_specific"
#define DHCPV6_OPT_VAL_16               "0x0000118b000a65526f75746572312e30"
#define DHCPV6_OPT_VAL_17               "0x0000118b000100020026"
#define V6_PREFIX_CONFIG                "\n{ prefix ::/64 }"
#define CONSOLE_LOG_FILE "/rdklogs/logs/WANMANAGERLog.txt.0"

#define DHCP_DBG_PRINT(fmt ...)     {\
    FILE     *fp        = NULL;\
    fp = fopen ( CONSOLE_LOG_FILE, "a+");\
    if (fp)\
    {\
        fprintf(fp,fmt);\
        fclose(fp);\
    }\
}\

static int execute(char *command, char *result)
{
    FILE *fp = NULL;
    char output[MAX_BUFFER_SIZE] = {0};
    char *str = NULL,*pos=NULL;

    fp = popen(command, "r");
    if(NULL == fp)
    {
        printf("Failed to run command\n" );
        return RETURN_ERR;
    }

    /* only the first line of the output is of interest */
    fgets(output, sizeof(output)-1, fp);
    if (NULL != (pos=strchr(output, '\n')) ) {
        *pos = '\0';
    }
    str = strstr(output, ":");

    if(NULL != str)
    {
        strcpy(result, (str + 1));
    }
    else
    {
        strcpy(result,output);
    }

    printf("\nresult = %s\n", result);
    pclose(fp);

    return RETURN_OK;
}

static int execute_cmd(char *command, char *result)
{
	FILE *fp = NULL;
	char buf[MAX_BUFFER_SIZE] = {0}, copy_buf[MAX_BUFFER_SIZE] ={0};
	int count = 0;

	fp = popen(command,"r");
	if(fp == NULL)
	{
		return RETURN_ERR;
	}

	if(fgets(buf,sizeof(buf) -1,fp) != NULL)
	{
		for(count=0;buf[count]!='\n';count++)
			copy_buf[count]=buf[count];
		copy_buf[count]='\0';
	}
	strcpy(result,copy_buf);
	pclose(fp);
	return RETURN_OK;
}

/* Note that 0 == RETURN_OK == STATUS_OK    */
/* Note that -1 == RETURN_ERR == STATUS_NOK */

INT platform_hal_GetDeviceConfigStatus(CHAR *pValue) { strcpy(pValue, "Complete"); return RETURN_OK; }

INT platform_hal_GetTelnetEnable(BOOLEAN *pFlag) { *pFlag = FALSE; return RETURN_OK; }
INT platform_hal_SetTelnetEnable(BOOLEAN Flag) { return RETURN_ERR; }
INT platform_hal_GetSSHEnable(BOOLEAN *pFlag)
{
#if 0
#ifndef _64BIT_ARCH_SUPPORT_
    char ssh_access[2] = { 0 };
    UtopiaContext ctx;

    if(NULL==pFlag)
        return RETURN_ERR;

    if (!Utopia_Init(&ctx))
        return RETURN_ERR;

    if (!Utopia_RawGet(&ctx, NULL, "mgmt_wan_sshaccess",
                       ssh_access, sizeof(ssh_access))) {
        Utopia_Free(&ctx, 0);
        return RETURN_ERR;
    }
    *pFlag = atoi(ssh_access);
    Utopia_Free(&ctx, 0);
#endif
#endif    
    return RETURN_OK;
}
INT platform_hal_SetSSHEnable(BOOLEAN Flag)
{
#if 0
#ifndef _64BIT_ARCH_SUPPORT_
    char ssh_access[2] = { 0 };
    UtopiaContext ctx;
    ssh_access[0] = '0' + ! !Flag;
    if (!Utopia_Init(&ctx))
        return RETURN_ERR;
    if (!Utopia_RawSet(&ctx, NULL, "mgmt_wan_sshaccess", ssh_access)) {
        Utopia_Free(&ctx, 0);
        return RETURN_ERR;
    }
    Utopia_SetEvent(&ctx, Utopia_Event_Firewall_Restart);
    Utopia_Free(&ctx, 1);
#endif    
#endif    
    return RETURN_OK;
}

INT platform_hal_GetSNMPEnable(CHAR* pValue) { return RETURN_ERR; }
INT platform_hal_SetSNMPEnable(CHAR* pValue) { return RETURN_ERR; }
INT platform_hal_GetWebUITimeout(ULONG *pValue) { return RETURN_ERR; }
INT platform_hal_SetWebUITimeout(ULONG value) { return RETURN_ERR; }
INT platform_hal_GetWebAccessLevel(INT userIndex, INT ifIndex, ULONG *pValue) { return RETURN_ERR; }
INT platform_hal_SetWebAccessLevel(INT userIndex, INT ifIndex, ULONG value) { return RETURN_ERR; }

INT platform_hal_PandMDBInit(void)
{
    return RETURN_OK;

}
INT platform_hal_DocsisParamsDBInit(void) { return RETURN_OK; }

INT platform_hal_GetModelName(CHAR* pValue)
{
    char model[TMP_BUFFER_SIZE]= {'\0'};
    FILE *dt_model_file;
    int ret = RETURN_ERR;

    if(NULL == pValue)
    {
        return RETURN_ERR;
    }

    if (access("/sys/firmware/devicetree/base/model", F_OK) == 0)
    {
        dt_model_file = fopen("/sys/firmware/devicetree/base/model","r");
        if (dt_model_file == NULL)
            return RETURN_ERR;
        fgets(model, TMP_BUFFER_SIZE, dt_model_file);
        fclose(dt_model_file);
    }
    else
    {
        ret = execute_cmd("grep 'MODEL_NAME' /etc/device.properties | cut -d '=' -f2", model);
        if(RETURN_OK != ret)
        {
            printf("\nError %s\n", __func__);
            return RETURN_ERR;
        }
    }
    ret = RETURN_OK;
    strncpy(pValue, model, strlen(model));

    return ret;
}

INT platform_hal_GetSerialNumber(CHAR* pValue)
{
    char sn[TMP_BUFFER_SIZE] = {'\0'};
    FILE *serial_number_file;
    int ret = RETURN_ERR;

    if(NULL == pValue)
    {
        return RETURN_ERR;
    }
    if (access("/sys/firmware/devicetree/base/serial-number", F_OK) == 0)
    {
        serial_number_file = fopen("/sys/firmware/devicetree/base/serial-number","r");
        if (serial_number_file == NULL)
            return RETURN_ERR;
        fgets(sn, TMP_BUFFER_SIZE, serial_number_file);
    }
    else
    {
        ret = execute("grep 'Serial' /proc/cpuinfo", sn);
        if(RETURN_OK != ret)
        {
            printf("\nError %s\n", __func__);
            return ret;
        }
    }
    strncpy(pValue, sn, strlen(sn));
    ret = RETURN_OK;

    return ret;
}

INT platform_hal_GetHardwareVersion(CHAR* pValue)
{
    int ret = RETURN_ERR;
    char hwVer[TMP_BUFFER_SIZE] = {'\0'};
    if(NULL == pValue )
    {
        return RETURN_ERR;
    }

    ret = execute("grep 'Revision' /proc/cpuinfo", hwVer);
    if(RETURN_OK != ret)
    {
        printf("\nError %s\n", __func__);
    }

    strcpy(pValue, hwVer);

    return ret;
}

INT platform_hal_GetSoftwareVersion(CHAR* pValue, ULONG maxSize)
{
    if(NULL == pValue )
    {
        return RETURN_ERR;
    }

    strcpy(pValue, "Not Supported");

    return RETURN_OK;
}

INT platform_hal_GetBootloaderVersion(CHAR* pValue, ULONG maxSize)
{
    if(NULL == pValue )
    {
        return RETURN_ERR;
    }

    strcpy(pValue, "Bootloader Version");

    return RETURN_OK;
}

INT platform_hal_GetFirmwareName(CHAR* pValue, ULONG maxSize)
{
    char fn[TMP_BUFFER_SIZE] = {'\0'};
    int ret = RETURN_ERR;

    if(NULL == pValue )
    {
        return RETURN_ERR;
    }
    ret = execute("grep 'imagename' /version.txt", fn);
    if(RETURN_OK != ret)
    {
        printf("\nError %s\n", __func__);
    }
    else
    {
        strncpy(pValue, fn, strlen(fn));
    }

    return ret;
}


INT platform_hal_GetBaseMacAddress(CHAR *pValue)
{
    if( NULL == pValue )
    {
        return RETURN_ERR;
    }
    execute_cmd("ifconfig eth0 | grep HWaddr | cut -d ' ' -f7",pValue);
    return RETURN_OK;
}

INT platform_hal_GetHardware(CHAR *pValue)
{
    char cmd[MAX_CMD_SIZE], output[MAX_BUFFER_SIZE];
    unsigned long flash_size_bytes, flash_size_mb;

    if (!pValue)
        return RETURN_ERR;

    //Getting the number of sectors
    snprintf(cmd, sizeof(cmd), "cat /sys/block/mmcblk0/size");
    execute(cmd, output);
    flash_size_bytes = atol(output)*512;
    flash_size_mb= flash_size_bytes/(1024*1024);
    snprintf(pValue, 16, "%lu", flash_size_mb);

    return RETURN_OK;
}
INT platform_hal_GetTotalMemorySize(ULONG *pulSize)
{
    char totMem[TMP_BUFFER_SIZE] = {'\0'};
    int ret = RETURN_ERR;

    if(NULL == pulSize)
    {
        return RETURN_ERR;
    }

    ret = execute("grep 'MemTotal' /proc/meminfo", totMem);
    if(RETURN_OK != ret)
    {
        printf("\nError %s\n", __func__);
    }
    else
    {
        sscanf(totMem, "%d", pulSize );
     *pulSize = *pulSize/ONE_KILOBYTE;
    }

    return ret;
}

INT platform_hal_GetHardware_MemUsed(CHAR *pValue)
{
    char usedMem[TMP_BUFFER_SIZE]={'\0'};
    int ret = RETURN_ERR;
    long tmp;

    if(NULL == pValue)
    {
        return RETURN_ERR;
    }

    ret = execute("df | grep '/dev' | awk '{print $3}'", usedMem);
    if(RETURN_OK != ret)
    {
        printf("Error: %s", __func__);
    }
    else
    {
        tmp = atoi(usedMem)/ONE_KILOBYTE;
        sprintf(pValue, "%ld",  tmp);
    }

    return ret;
}


INT platform_hal_GetHardware_MemFree(CHAR *pValue)
{
   char freeMem[TMP_BUFFER_SIZE] = {'\0'};
   int ret = RETURN_ERR;
   long tmp;

   if(NULL == pValue)
   {
       return RETURN_ERR;
   }
   ret = execute("df | grep '/dev' | awk '{print $4}'", freeMem);
   if(RETURN_OK != ret)
   {
       printf("Error:%s", __func__);
   }
   else
   {
      tmp = atoi(freeMem)/ONE_KILOBYTE;
      sprintf(pValue, "%ld", tmp);
   }

   return ret;
}

INT platform_hal_GetFreeMemorySize(ULONG *pulSize)
{
    char freeMem[TMP_BUFFER_SIZE] = {'\0'};
    int ret = RETURN_ERR;

    if(NULL == pulSize)
    {
        return RETURN_ERR;
    }

    ret = execute("free| grep 'Mem'| awk '{print $4}'", freeMem);
    if(RETURN_OK != ret)
    {
        printf("Error:%s", __func__);
    }
    else
    {
        *pulSize = atoi(freeMem)/ONE_KILOBYTE;
    }

    return ret;
}

INT platform_hal_GetUsedMemorySize(ULONG *pulSize)
{
    int ret = RETURN_ERR;
    char usedMem[TMP_BUFFER_SIZE] = {'\0'};
    int tmp;

    if(NULL == pulSize)
    {
        return RETURN_ERR;
    }

    ret = execute("free| grep 'Mem'| awk '{print $3}'", usedMem);
    if(RETURN_OK != ret)
    {
        printf("Error: %s", __func__);
    }
    else
    {
        *pulSize = atoi(usedMem)/ONE_KILOBYTE;
    }

    return ret;
}

INT platform_hal_GetFactoryResetCount(ULONG *pulSize)
{

    if(NULL == pulSize)
    {
        return RETURN_ERR;
    }
    FILE *pdbFile = NULL;
    char buf[128]={0};
    pdbFile = fopen(FACTORY_RESET_COUNT_FILE, "r");
    if(pdbFile != NULL)
    {
	 fread(buf,sizeof(buf),1,pdbFile);
	 fclose(pdbFile);
	 *pulSize = atoi(buf);
    }
    else
    {
         *pulSize = 0;
    }


    return RETURN_OK;
}

INT platform_hal_ClearResetCount(BOOLEAN bFlag)
{
    return RETURN_OK;
}

INT platform_hal_getTimeOffSet(CHAR *pValue)
{
    return RETURN_OK;
}

INT platform_hal_SetDeviceCodeImageTimeout(INT seconds)
{
    return RETURN_OK;
}

INT platform_hal_SetDeviceCodeImageValid(BOOLEAN flag)
{
    return RETURN_OK;
}

INT platform_hal_getCMTSMac(CHAR *pValue)
{ 
	 if (pValue == NULL)
	 {
	     return RETURN_ERR;
	 }
	execute_cmd("ifconfig eth6 | grep HWaddr | cut -d ' ' -f7",pValue);
	return RETURN_OK; 
}

//temperature and fan control
INT platform_hal_GetChipTemperature(UINT chipIndex, ULONG *pTempValue) {  //chipIndex:0 for main CPU, 1 for wifi chip.  TempValue is in degrees Celcius 
	if(chipIndex==0) 
		*pTempValue=40;
	else if (chipIndex==0) 
		*pTempValue=41;
	else
		*pTempValue=0;
	return RETURN_OK;
}

INT platform_hal_GetFanSpeed(ULONG *pSpeedValue) {  //SpeedValue is in RPMs 
	*pSpeedValue=3600;
	return RETURN_OK; 
}

INT platform_hal_SetFanSpeed(ULONG SpeeddInRpms) {
	//set the fan speed
	return RETURN_OK; 
}

/* platform_hal_SetSNMPOnboardRebootEnable() function */
/**
* @description : Set SNMP Onboard Reboot Enable value
*                to allow or ignore SNMP reboot
* @param IN    : pValue - SNMP Onboard Reboot Enable value
                 ("disable" or "enable")
*
* @return      : The status of the operation
* @retval      : RETURN_OK if successful
* @retval      : RETURN_ERR if any error is detected
*/
INT platform_hal_SetSNMPOnboardRebootEnable(CHAR* pValue)
{
	return RETURN_OK;
}

INT platform_hal_GetRouterRegion(CHAR* pValue)
{
    return RETURN_OK;
}

/* Utility apis to return common parameters from firewall_lib.c */
char *get_current_wan_ifname()
{
    char *interface_names[]={"erouter0", "wwan0", NULL};//list of available wan interfaces
    char interface_name[128]="";
    unsigned int i;

    execute_cmd("ip r | grep default | head -1 | cut -d ' ' -f5", interface_name);

    for(i=0; interface_names[i]!=NULL; i++)
           if(!strcmp(interface_names[i],interface_name))
                   return interface_names[i];
    return "0";
}

INT platform_hal_GetDhcpv4_Options ( dhcp_opt_list ** req_opt_list, dhcp_opt_list ** send_opt_list)
{
    if ((req_opt_list == NULL) || (send_opt_list == NULL))
    {
        return RETURN_ERR;
    }
    return RETURN_OK;
}

/*
 * add_dhcp_opt_to_list ()
 * @description: This function add DHCP SEND/REQUEST option and option value
                 to the to a list that is passed to this function as argument.
 * @params     : opt_list - input list to add a node
               : opt - DHCP option tag eg: 43, 60
               : opt_val - DHCP option value
 * @return     : RETURN_OK or RETURN_ERR
 *
 */
static int add_dhcp_opt_to_list (dhcp_opt_list ** opt_list, int opt, char * opt_val)
{
    if ((opt_list == NULL) || (opt <= 0) ||(opt >= DHCPV4_OPT_END) )
    {
        return RETURN_ERR;
    }

    dhcp_opt_list * new_dhcp_opt = malloc (sizeof(dhcp_opt_list));
    if (new_dhcp_opt == NULL)
    {
        return RETURN_ERR;
    }
    memset (new_dhcp_opt, 0, sizeof(dhcp_opt_list));

    new_dhcp_opt->dhcp_opt = opt;
    new_dhcp_opt->dhcp_opt_val = opt_val;

    if (*opt_list != NULL)
    {
        new_dhcp_opt->next = *opt_list;
    }
    *opt_list = new_dhcp_opt;

    DHCP_DBG_PRINT("%s %d: Added %d to list\n", __FUNCTION__, __LINE__, opt);
    dhcp_opt_list * t = *opt_list;
    while(t)
    {
        DHCP_DBG_PRINT("%d ", t->dhcp_opt);
        t = t->next;
    }
    DHCP_DBG_PRINT("\n");

    return RETURN_OK;
}
/*
 * free_dhcp_opt_list ()
 * @description: This function is to free all nodes in linked list created to hold dhcp options.
 * @params     : opt_list - list to free
 * @return     : no return
 *
 */
void free_dhcp_opt_list (dhcp_opt_list * opt_list)
{
    dhcp_opt_list * tmp_node = NULL;

    if (opt_list == NULL)
        return;

    while (opt_list)
    {
        tmp_node = opt_list;
        opt_list = opt_list->next;
        if (tmp_node->dhcp_opt_val)
        {
            // DHCP opt will have opt_val
            free(tmp_node->dhcp_opt_val);
        }
        free(tmp_node);
    }

}

int ascii_to_hex (char *in, char *out, int size)
{
    int i = 0;

    if (size < (strlen(in) * 2) + 2)
        return 0;

    memset (out, 0, size);
    for (i = 0; *in; i++, in++)
    {
        snprintf((out+i*2), size-i*2, "%02X", *in);
    }

    return i*2;
}

/*
 * add_dhcpv6_option_17 ()
 * @description: This function add DHCP SEND option 17
                 to the to a list that is passed to this function as argument.
 * @params     : v4_send_opt_list - list to update option 17
 * @return     : RETURN_OK or RETURN_ERR
 *
 */
static int add_dhcpv6_option_17 (dhcp_opt_list **send_opt_list)
{
    char buff[512], line[128], mode[16], subop[32], value[64], *opt_val;
    char tmp[256], hex[128];
    int len;
    FILE *fp;

    if(!(fp = fopen(DHCP_VENDOR_OPTION_FILE, "r")))
    {
        DHCP_DBG_PRINT("returning since vendor option file is not present %s.\n", __FUNCTION__);
        return RETURN_OK;
    }

    //Using default Option17 value
    strcpy(buff, DHCPV6_OPT_VAL_17);

    while (fgets(line, sizeof(line), fp))
    {
        sscanf(line, "%s  %s %s", mode, subop, value);

        memset (tmp, 0, sizeof(tmp));
        if (!strncmp(subop, "SUBOPTION2", 10))
        {
            len = ascii_to_hex(value, hex, sizeof(hex));
            snprintf(tmp, sizeof(tmp), "0002%04X%s", len, hex);
            strcat(buff, tmp);
        }
        else if (!strncmp(subop, "SUBOPTION3", 10))
        {
            if (!strcmp(mode, "ETHWAN"))
            {
                len = ascii_to_hex(value, hex, sizeof(hex));
                snprintf(tmp, sizeof(tmp), "0002%04X%s", len, hex);
                strcat(buff, tmp);
            }
        }
    }

    fclose(fp);

    if(!(opt_val = malloc(strlen(buff) + 1)))
        return RETURN_ERR;

    memset (opt_val, 0, strlen(buff) + 1);
    strncpy(opt_val, buff, strlen(buff));

    if (add_dhcp_opt_to_list(send_opt_list, DHCPV6_OPT_17, opt_val) != RETURN_OK)
        return RETURN_ERR;

    return RETURN_OK;
}

INT platform_hal_GetDhcpv6_Options ( dhcp_opt_list ** req_opt_list, dhcp_opt_list ** send_opt_list)
{
    int ret;

    if (!req_opt_list || !send_opt_list)
        return RETURN_ERR;

    do
    {
        // Request options
        if ((ret=add_dhcp_opt_to_list(req_opt_list, DHCPV6_OPT_5, NULL)) != RETURN_OK)     // IA Address Option
            break;
        if ((ret=add_dhcp_opt_to_list(req_opt_list, DHCPV6_OPT_23, NULL)) != RETURN_OK)    // DNS
            break;
        if ((ret=add_dhcp_opt_to_list(req_opt_list, DHCPV6_OPT_24, NULL)) != RETURN_OK)    // Optional Domain Name List
            break;

        // SEND OPTION addition
        if ((ret=add_dhcp_opt_to_list(send_opt_list, DHCPV6_OPT_25, strdup(V6_PREFIX_CONFIG))) != RETURN_OK)    // Prefix Delegation Option
            break;
        if ((ret=add_dhcp_opt_to_list(send_opt_list, DHCPV6_OPT_16, strdup(DHCPV6_OPT_VAL_16))) != RETURN_OK)    // Vendor Class Option
            break;
        if ((ret=add_dhcpv6_option_17(send_opt_list)) != RETURN_OK)  // OPTION_VENDOR_OPTS
            break;
    }while(0);

    if(ret!=RETURN_OK)
    {
        free_dhcp_opt_list (*req_opt_list);
        *req_opt_list = NULL;
        free_dhcp_opt_list (*send_opt_list);
        *send_opt_list = NULL;
         return RETURN_ERR;
    }

     return RETURN_OK;
}

INT platform_hal_GetFirmwareBankInfo(FW_BANK bankIndex, PFW_BANK_INFO pFW_Bankinfo)
{
    return RETURN_OK;
}

INT platform_hal_SetLowPowerModeState(PPSM_STATE pState)
{
#if defined(_PSM_TRANS_RDK_TRIGG_)
    if(NULL != pState)
    {
        return RETURN_OK;
    }
    return RETURN_ERR;
#else
    return RETURN_OK;
#endif
}

INT platform_hal_SetPppUserName(CHAR* pUserName, ULONG maxSize) { return RETURN_OK; }
INT platform_hal_SetPppPassword(CHAR* pPassword, ULONG maxSize) { return RETURN_OK; }
INT platform_hal_GetPppUserName(CHAR* pUserName, ULONG maxSize) { return RETURN_OK; }
INT platform_hal_GetPppPassword(CHAR* pPassword, ULONG maxSize) { return RETURN_OK; }

INT platform_hal_GetInterfaceStats(const char *ifname,PINTF_STATS pIntfStats) { return RETURN_OK; }

int platform_hal_initLed (char * config_file_name)
{
    return RETURN_OK;
}

int platform_hal_setLed (PLEDMGMT_PARAMS led_data)
{
    return RETURN_OK;
}

int platform_hal_getLed(PLEDMGMT_PARAMS led_data)
{
    return RETURN_OK;
}

#ifdef _PLATFORM_HAL_TEST_
int main(int argc,char **argv)
{
    INT ret=0;
    char buf[1024]="";
    ULONG size=0;
    BOOLEAN flag=FALSE;

    if(argc!=2)
    {
        printf("Usage: platformhal <platform_hal_API>\n");
        exit(-1);
    }
    if(strstr(argv[1], "platform_hal_GetFirmwareName")!=NULL)
    {
        platform_hal_GetFirmwareName(buf, sizeof(buf));
        printf("FirmwareName:%s.\n", buf);
        exit(0);
    }
    if(strstr(argv[1], "platform_hal_GetSoftwareVersion")!=NULL)
    {
        platform_hal_GetSoftwareVersion(buf, sizeof(buf));
        printf("SoftwareVersion:%s.\n", buf);
        exit(0);
    }
    if(strstr(argv[1], "platform_hal_GetBootloaderVersion")!=NULL)
    {
        platform_hal_GetBootloaderVersion(buf, sizeof(buf));
        printf("BootloaderVersion:%s.\n", buf);
        exit(0);
    }
    if(strstr(argv[1], "platform_hal_GetModelName")!=NULL)
    {
        platform_hal_GetModelName(buf);
        printf("GetModelName:%s.\n", buf);
        exit(0);
    }
    if(strstr(argv[1], "platform_hal_GetSerialNumber")!=NULL)
    {
        platform_hal_GetSerialNumber(buf);
        printf("GetSerialNumber:%s.\n", buf);
        exit(0);
    }
    if(strstr(argv[1], "platform_hal_GetHardwareVersion")!=NULL)
    {
        platform_hal_GetHardwareVersion(buf);
        printf("GetHardwareVersion:%s.\n", buf);
        exit(0);
    }
    if(strstr(argv[1], "platform_hal_GetBaseMacAddress")!=NULL)
    {
        platform_hal_GetBaseMacAddress(buf);
        printf("GetBaseMacAddress:%s.\n", buf);
        exit(0);
    }
    if(strstr(argv[1], "platform_hal_GetHardware")!=NULL)
    {
        platform_hal_GetHardware(buf);
        printf("GetHardware:%s.\n", buf);
        exit(0);
    }
    if(strstr(argv[1], "platform_hal_GetHardware_MemUsed")!=NULL)
    {
        platform_hal_GetHardware_MemUsed(buf);
        printf("GetHardware_MemUsed:%s.\n", buf);
        exit(0);
    }
    if(strstr(argv[1], "platform_hal_GetHardware_MemFree")!=NULL)
    {
        platform_hal_GetHardware_MemFree(buf);
        printf("GetHardware_MemFree:%s.\n", buf);
        exit(0);
    }
    if(strstr(argv[1], "platform_hal_getCMTSMac")!=NULL)
    {
        platform_hal_getCMTSMac(buf);
        printf("getCMTSMac:%s.\n", buf);
        exit(0);
    }
    if(strstr(argv[1], "platform_hal_GetTotalMemorySize")!=NULL)
    {
        platform_hal_GetTotalMemorySize(&size);
        printf("GetTotalMemorySize:%lu.\n", size);
        exit(0);
    }
    if(strstr(argv[1], "platform_hal_GetFreeMemorySize")!=NULL)
    {
        platform_hal_GetFreeMemorySize(&size);
        printf("GetFreeMemorySize:%lu.\n", size);
        exit(0);
    }
    if(strstr(argv[1], "platform_hal_GetUsedMemorySize")!=NULL)
    {
        platform_hal_GetUsedMemorySize(&size);
        printf("GetUsedMemorySize:%lu.\n", size);
        exit(0);
    }
    if(strstr(argv[1], "platform_hal_GetFactoryResetCount")!=NULL)
    {
        platform_hal_GetFactoryResetCount(&size);
        printf("GetFactoryResetCount:%lu.\n", size);
        exit(0);
    }
    if(strstr(argv[1], "platform_hal_GetChipTemperature")!=NULL)
    {
        unsigned int chip =0;
        platform_hal_GetChipTemperature(chip, &size);
        printf("ChipIndex:%u, Temperature:%lu\n", chip, size);
        exit(0);
    }
    if(strstr(argv[1], "platform_hal_GetFanSpeed")!=NULL)
    {
        platform_hal_GetFanSpeed(&size);
        printf("GetFanSpeed:%lu.\n", size);
        exit(0);
    }
    if(strstr(argv[1], "platform_hal_SetFanSpeed")!=NULL)
    {
        platform_hal_SetFanSpeed(size);
        printf("SetFanSpeed:%lu.\n", size);
        exit(0);
    }
    printf("Invalid platform_hal_API name\n");
    exit(1);
}
#endif //_PLATFORM_HAL_TEST_
