# System Image management using btrfs snapshots, systemd-boot and EFI

`efi-image-manager` imports system images into btrfs subvolumes and snapshots,
as well as managing systemd-boot entries for them.

In the future it will manage [Unified Kernel Images (UKI)](https://wiki.archlinux.org/title/Unified_kernel_image)
and support use cases like "test and commit" of new system images.

Compared to similar tools in other Linux distribution, `efi-image-manager`
works on the design assumption that the new system image and included kernel
is a complete *replacement* for the running system, with user data carried over
in other btrfs subvolumes.

## Proposed image definition schema

```
struct SystemImage {
    image_name: String,
    root_volume_id: u64,
    nvram_volume_id: u64,
    read_write_volume_id: u64,
    cmdline_extra: String
}
```

```
{
  "rdkb-2025-q1-12345678": {
    "root_volume_id": 123,
    "nvram_volume_id": 456,
    "read_write_volume_id": 124,
    "cmdline_extra": "net.ifnames=0"
  }
}
```

Kernel and initramfs (optional) images are to be organized under `/boot/efi/rdkb/...`:

```
/boot/efi/rdkb/rdkb-2025-q1-12345678/Image
/boot/efi/rdkb/rdkb-2025-q1-12345678/initrd
/boot/efi/rdkb/rdkb-2025-q1-1234568/image.json
```

## Utilities

1. Image ingestion

Ingest images from the distribution format (currently `.tar.gz`) and setup boot loader entries for them

2. Image management util

## Usage

This project is still a work in progress, but the following features are implemented:

* Import image
* Remove image

Additionally, some internal utility functions are exposed
(such as `get-part-uuid`, `is-boot-ro` and `boot-line`).

```
Usage: efi-image-manager <COMMAND>

Commands:
  list-images
  remove-image
  import
  set-active
  commit
  revert
  get-part-uuid
  is-boot-ro
  boot-line
  help           Print this message or the help of the given subcommand(s)

Options:
  -h, --help     Print help
  -V, --version  Print version
```

## Implementation discussion

When built in debug mode (NOT `cargo build --release`), the presence of `/etc/device.properties`
is used to determine if the utility is running on a "real device".

If `/etc/device.properties` is not found, the following paths will be
used as substitutes:

* `/boot` -> `$PWD/fakeboot`
* `/volumes` -> `$PWD/volumes`

## Development

The btrfs utility libraries need to be installed, as well as clang to compile the
Rust bindings for them.

You may find this build environment useful (using the container tool of your choice):

```
# With Ubuntu 22.04
apt-get update && \
    apt-get install -y build-essential linux-headers-generic curl clang libbtrfsutil-dev
curl --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/rustup.sh && chmod +x /tmp/rustup.sh && /tmp/rustup.sh -y
```

## Backends

1. systemd-boot / Boot Loader Spec configuration files (`/boot/loader/`)

2. systemd-stub (see [systemd-stub(7)](https://www.freedesktop.org/software/systemd/man/latest/systemd-stub.html), [ukify(1)](https://www.freedesktop.org/software/systemd/man/latest/ukify.html#))

3. EFI variable management (`BootNext`)

### Recommended Reading

* FOSDEM-2024: ["systemd-boot, systemd-stub, UKIs"](https://archive.fosdem.org/2024/events/attachments/fosdem-2024-1987-systemd-boot-systemd-stub-ukis/slides/22834/systemd-boot_systemd-stub_UKIs_mNuvmv0.pdf)

* [sdbootutil](https://github.com/openSUSE/sdbootutil). A tool implementing similar functionality in the openSUSE distribution.

### Credits and licensing

This project was originally authored by Mathew McBride <matt@traverse.com.au> for the
RDK-B generic Arm (SystemReady compatible) port.

As per other RDK components, the code is distributed under the
[Apache 2.0 license](https://www.apache.org/licenses/LICENSE-2.0).

