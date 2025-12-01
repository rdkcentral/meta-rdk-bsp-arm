inherit cargo cargo-update-recipe-crates pkgconfig

DESCRIPTION = "EFI System Image Manager"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://src/main.rs;beginline=1;endline=18;md5=eac3c723f69bb9355246e3c2b8f54e5d"

SRC_URI = "git://github.com/rdkcentral/efi-image-manager.git;branch=main;protocol=https"
SRCREV = "49f45ab53bb0ab5b5808cabba0ed631f6471971c"

DEPENDS  = "btrfs-tools clang-native"

S = "${WORKDIR}/git"
require efi-image-manager-crates.inc

