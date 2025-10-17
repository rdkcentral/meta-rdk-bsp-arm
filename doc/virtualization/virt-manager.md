# RDK-B router testing with virt-manager

## Requirements

Ideal: Native/Bare metal Aarch64 host with virtualization capabilities 

_Examples: Traverse Technologies armefi64, Amazon AWS a1.metal_

Recommended: 8 GiB host RAM, 16GiB available free disk space

Virt-manager can be used to emulate Aarch64 on x86, but at a fraction of native performance.

Host OS: Any distribution with virt-manager. 
So far, we have tested SuSE Enterprise Linux(SLES) 15-SP6/openSUSE Leap 15.6 and Ubuntu 24.04.

Ubuntu 24.04 has stricter enforcement of secure boot and disk access permissions. These are good things, but can complicate matters when working with non-release images. Therefore, (open)SUSE is a bit easier to use for RDK Development.

**SuSE Enterprise Linux / openSUSE Leap**

```
# Install virtualization tools
zypper in -t pattern kvm_server kvm_tools

# Enable virt-manager modular daemons
for drv in qemu network nodedev nwfilter secret storage
do
sudo systemctl enable virt${drv}d.service
sudo systemctl enable virt${drv}d{,-ro,-admin}.socket
done

# If on x86, manually install qemu-arm
$ sudo zypper install qemu-arm

# Reboot so we get into a "clean" state with all virt-manager daemons started
/sbin/reboot
```

**Ubuntu**

```
$ sudo apt install virt-manager
```

## virt-manager setup

Create dedicated networks for the RDK router "LAN" and "WAN"(*):

```
$ cat <<EOF > rdk_client_network.xml
<network>
<name>rdk_client</name>
</network>
EOF
$ sudo virsh net-create rdk_client_network.xml
Network rdk_client created from rdk_client_network.xml

# WAN network setup
# (if virsh net-list shows a "default" network, you can skip this)
cat <<EOF > rdk_wan_network.xml
<network>
<name>rdk_wan</name>
<bridge name="virbrwan"/>
<forward mode="nat"/>
<ip address="192.168.122.1" netmask="255.255.255.0">
<dhcp>
<range start="192.168.122.2" end="192.168.122.254"/>
</dhcp>
</ip>
</network>
EOF
$ sudo virsh net-create rdk_wan_network.xml
Network rdk_wan created from rdk_wan_network.xml
```

If your distribution has created a `default` network in virt-manager already, you can skip creating the `rdk_wan` network and use `default` in it's place.
 
_\* For the purposes of our demonstration, we will use the VM host to create a NAT'ed host network as the RDK-B WAN. For information on more advanced configurations (such as bridging to an existing Ethernet port), see the [relevant documentation](https://documentation.suse.com/sles/15-SP6/html/SLES-all/cha-libvirt-host.html#libvirt-host-network)._

## RDK-B router VM setup

Download a copy of `rdk-generic-broadband-image-armefi64-rdk-broadband.wic` and convert it to qcow2:

```
qemu-img convert -O qcow2 rdk-generic-broadband-image-armefi64-rdk-broadband.wic rdk.qcow2    
qemu-img resize rdk.qcow2 10G
```

Create the RDK router VM:
```
# On Ubuntu, you may need to move rdk.qcow2 into a location readable by libvirt
# (replace the ${HOME} in virt-install with /opt/vm)
mkdir -p /opt/vm
mv rdk.qcow2 /opt/vm
chown -R libvirt-qemu:kvm /opt/vm/

sudo virt-install --name rdk --memory 2048 --vcpus 2 --hvm --virt-type kvm \
	--network network=rdk_client \
	--network network=rdk_wan \
	--disk ${HOME}/rdk.qcow2 --import \
        --os-variant linux2022 \
        --boot firmware=efi,firmware.feature0.enabled=no,firmware.feature0.name=secure-boot
```
**If you are using an x86 host, change `--hvm --virt-type kvm` to `--arch aarch64`**

If you do not get a console (you see "Waiting for the installation to complete"), then run the following command in a seperate terminal:

```
$ sudo virsh console rdk
```

virt-install will boot RDK-B console mode, you will get a root prompt:
```
root@armefi64-rdk-broadband:~# uname -a
Linux Traverse-Gateway 5.15.162-yocto-standard #1 SMP Tue Jul 9 13:57:41 UTC 2024 aarch64 GNU/Linux
```

The WAN interface (eth6) should acquire an IP address shortly (a few minutes) after boot:

```
ifconfig eth6
eth6      Link encap:Ethernet  HWaddr 52:54:00:41:AD:3B
          inet addr:192.168.122.156  Bcast:192.168.122.255  Mask:255.255.255.0
          inet6 addr: fe80::5054:ff:fe41:ad3b/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:70 errors:0 dropped:0 overruns:0 frame:0
          TX packets:18 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:4718 (4.6 KiB)  TX bytes:2744 (2.6 KiB)
```

Shutdown RDK, so virt-manager will consider RDK as "installed".

```
root@armefi64-rdk-broadband:~# /sbin/poweroff
```

You can then start RDK-B again:
```
sudo virsh --connect qemu:///system start rdk
```

And it will appear in virsh list:
```
sudo virsh list
 Id   Name   State
----------------------
 3    rdk    running
```

## Connecting a client to the RDK-B LAN
We will boot up a minimal LiveCD (Alpine Linux) to demonstrate routing through the RDK-B VM:

```
wget https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/aarch64/alpine-virt-3.20.2-aarch64.iso

sudo virt-install --name rdk_network_client --memory 1024 --vcpus 1 --hvm --virt-type kvm \
	--network network=rdk_client \
	--disk size=10 \
	--cdrom ${HOME}/alpine-virt-3.20.2-aarch64.iso \
        --os-variant linux2022 \
        --boot firmware=efi,firmware.feature0.enabled=no,firmware.feature0.name=secure-boot
```

(\* x86 host note: You may wish to switch to a "native" Alpine x86-64 ISO. Otherwise, the same note as the RDK-B VM applies about replacing the hvm mode switch with the aarch64 switch).

The Alpine ISO is a LiveCD environment, so it will drop you to a root prompt where you can bring up a network:

```
localhost login: root
Welcome to Alpine!

The Alpine Wiki contains a large amount of how-to guides and general
information about administrating Alpine systems.
See <https://wiki.alpinelinux.org/>.

You can setup the system with the command: setup-alpine

You may change this message by editing /etc/motd.

localhost:~# ifconfig eth0 up
localhost:~# udhcpc -i eth0 -R
udhcpc: started, v1.36.1
udhcpc: broadcasting discover
udhcpc: broadcasting discover
udhcpc: broadcasting select for 10.0.0.161, server 10.0.0.1
udhcpc: lease of 10.0.0.161 obtained from 10.0.0.1, lease time 604800
localhost:~# traceroute 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 46 byte packets
 1  Traverse-Gateway.utopia.net (10.0.0.1)  0.223 ms  0.123 ms  0.113 ms
 2  192.168.122.1 (192.168.122.1)  0.250 ms  0.184 ms  0.175 ms
 3  100.64.88.13 (100.64.88.13)  6.500 ms  100.64.88.109 (100.64.88.109)  6.771 ms  100.64.88.123 (100.64.88.123)  5.822 ms
 4  240.1.236.35 (240.1.236.35)  0.452 ms  0.430 ms  0.391 ms
 5  240.1.220.9 (240.1.220.9)  8.650 ms  100.66.12.186 (100.66.12.186)  119.855 ms  100.66.12.4 (100.66.12.4)  1.402 ms
```

For further use of the Alpine client VM, you can run `setup-alpine`. Refer to the [Alpine Linux installation guide](https://wiki.alpinelinux.org/wiki/Installation) for more details.
