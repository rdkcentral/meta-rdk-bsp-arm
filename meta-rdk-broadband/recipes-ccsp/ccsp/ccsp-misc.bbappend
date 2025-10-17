require ccsp_common_genericarm.inc

CFLAGS += " -DDHCPV4_CLIENT_UDHCPC -DDHCPV6_CLIENT_DIBBLER -DUDHCPC_RUN_IN_BACKGROUND "

LDFLAGS_append_aarch64 = " -lutctx"
