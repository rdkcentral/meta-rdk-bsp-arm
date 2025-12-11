include ccsp_common_genericarm.inc
DEPENDS:append = " dbus"
LDFLAGS:append = " -Wl,--no-as-needed -ldbus-1 -Wl,--as-needed"
