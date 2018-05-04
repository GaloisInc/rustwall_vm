# Testing rustwall in Qemu

Tested on Ubuntu 16.04 and Qemu 2.12

## Prerequisites


### Bridge utils
First, fetch bridge utils: 

```
sudo apt install bridge-utils
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
