# On other implementations, these files are installed into /nvram
# As our /nvram mount point is separate, these instead will be
# copied by a pre-start script at runtime

do_install:append() {
    install -d ${D}/usr/ccsp/EasyMesh/nvram
    install -m 664 ${S}/src/import/install/config/*  ${D}/usr/ccsp/EasyMesh/nvram
    rm -rf ${D}/nvram
}

FILES_${PN}:remove = "/nvram/*"
FILES_${PN} =+ " /usr/ccsp/EasyMesh/nvram/*"
