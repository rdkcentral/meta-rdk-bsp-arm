SUMMARY = "Package group for required firmware binary blobs"
DESCRIPTION = "Bundles all firmware blobs for supported hardware together"

LICENSE = "MIT"

# Ensure this recipe is treated strictly as a packagegroup
inherit packagegroup

# Define the package(s) this recipe will generate
PACKAGES = "${PN}"

# List the packages that must be installed when this packagegroup is called
RDEPENDS:${PN} = " \
    virtual/firmware-mtk-wifi6 \
    linux-firmware-bcm43455 \
"
