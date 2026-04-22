require ccsp_common_genericarm.inc

# In function 'snoop_AddClientListEntry':
# dhcpsnooper.c:864:57: error: 'pNewClient' may be used
# uninitialized in this function [-Werror=maybe-uninitialized]
CFLAGS:append = " -Wno-error=maybe-uninitialized"