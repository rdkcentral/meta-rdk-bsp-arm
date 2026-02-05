CFLAGS:append:kirkstone = " ${@bb.utils.contains('DISTRO_FEATURES', 'safec', ' -fPIC -I${STAGING_INCDIR}/safeclib', '-fPIC', d)}"
