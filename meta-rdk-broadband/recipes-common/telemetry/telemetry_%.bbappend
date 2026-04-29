# Workaround a compile issue when BUILD_DEBUG="1"

CFLAGS:append = " -Wno-error=maybe-uninitialized"