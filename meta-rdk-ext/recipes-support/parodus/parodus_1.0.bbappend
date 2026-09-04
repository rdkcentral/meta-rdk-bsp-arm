LDFLAGS:append = " -Wl,--no-as-needed -lm -llog4c -lrdkloggers"

inherit systemd coverity
