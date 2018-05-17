# Testing rustwall in Qemu

Tested on Ubuntu 16.04 and Qemu 2.12

## Prerequisites
Perform these steps before running the seL4 images. Typically you have to do this only once.



### Bridge utils
1. First, fetch bridge utils: 
```
sudo apt install bridge-utils
```
2. Create a bridge for QEMU so it can be accessed from the host machine (or run `brigde_init.sh`)
```
sudo brctl addbr br0
sudo ip addr add 192.168.179.1/24 broadcast 192.168.179.255 dev br0
sudo ip link set br0 up

sudo ip tuntap add dev tap0 mode tap
sudo ip link set tap0 up promisc on

sudo brctl addif br0 tap0

sudo dnsmasq --interface=br0 --bind-interfaces --dhcp-range=192.168.179.10,192.168.179.254
```

### Qemu
1. To download and build QEMU 2.12.0:
```
wget https://download.qemu.org/qemu-2.12.0.tar.xz
tar xvJf qemu-2.12.0.tar.xz
cd qemu-2.12.0
./configure
make
```
2. Add a symlink to `qemu-system-x86_64` (for 64 bit targets):
```
cd ~/bin
ln -s QEMU_2.12_build_directory/x86_64-softmmu/qemu-system-x86_64 qemu-system-x86_64
```
3. Make sure that you have `~/bin` in your `$PATH`, ideally edit `~/.bashrc` and add:
```
# add HOME/bin
export PATH=~/bin:$PATH
```
4. Test:
```
$ cd ~
$ qemu-system-x86_64 --version
QEMU emulator version 2.12.0
Copyright (c) 2003-2017 Fabrice Bellard and the QEMU Project developers
```
5. Do the same for `qemu-system-i386` (32 bit target):
```
cd ~/bin
ln -s QEMU_2.12_build_directory/i386-softmmu/qemu-system-i386 qemu-system-i386
```


### Enable IOMMU
Note: you have to have a CPU that supports virtualization (VT-x/d) and IOMMU. 

1. In BIOS settings, make sure you enable VT-x/d virtualization and IOMMU. Then boot your OS.
2. From a terminal run:
```
sudo gedit /etc/default/grub
```
3. Find the line starting with `GRUB_CMDLINE_LINUX_DEFAULT` and append `intel_iommu=on` (Intel CPU) or `amd_iommu=on` (AMD CPU)
to its end. 
4. Finally, start a terminal and run:
```
sudo update-grub
```
to update GRUB's configuration file.

On the next reboot, the kernel should be started with the boot parameter.
To permanently remove it, simply remove the parameter from `GRUB_CMDLINE_LINUX_DEFAULT` and run sudo update-grub again.

To verify your changes, you can see exactly what parameters your kernel booted with by executing `cat /proc/cmdline`.

Make sure you get the following output:
```
$ dmesg|grep IOMMU
[    0.000000] DMAR: IOMMU enabled
```


## Testing
1. Build the seL4 image with:
```
make clean; make cma34cr_centos_defconfig; make silentoldconfig; make;
```
2. Run the qemu from the build directory (x86_64):
```
qemu-system-x86_64 -m 1024 -cpu Nehalem,+vmx,+fsgsbase -serial /dev/stdout -vga std -netdev tap,id=t0,ifname=tap0,script=no,downscript=no -device e1000e,netdev=t0,id=nic0 --enable-kvm -smp 2 -kernel images/kernel-x86_64-pc99 -initrd images/capdl-loader-experimental-image-x86_64-pc99 -device intel-iommu,intremap=on,caching-mode=on -machine q35,kernel-irqchip=split
```
or for 32-bit targets (no IOMMU):

```
qemu-system-i386 -m 1024 -cpu Nehalem,+vmx,+fsgsbase -serial /dev/stdout -vga std -netdev tap,id=t0,ifname=tap0,script=no,downscript=no -device e1000,netdev=t0,id=nic0 --enable-kvm -smp 2 -kernel images/kernel-ia32-pc99 -initrd images/capdl-loader-experimental-image-ia32-pc99  -machine q35
```
