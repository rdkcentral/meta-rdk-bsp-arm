inherit cargo cargo-update-recipe-crates pkgconfig

DESCRIPTION = "EFI System Image Manager"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://src/main.rs;beginline=1;endline=18;md5=eac3c723f69bb9355246e3c2b8f54e5d"

SRC_URI += " \
    file://Cargo.lock \
    file://Cargo.toml \
    file://src/btrfs_driver.rs \
    file://src/image_info.rs \
    file://src/image_ingestion.rs \
    file://src/image_list.rs \
    file://src/image_mgmt.rs \
    file://src/system_info.rs \
    file://src/main.rs \
"

SRCREV = "896d82f9609b9a423563f4c558bbf316148217b5"

DEPENDS  = "btrfs-tools clang-native"

S = "${WORKDIR}"
require efi-image-manager-crates.inc

