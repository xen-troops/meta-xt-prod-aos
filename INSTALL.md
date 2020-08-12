Prerequisites:
==============
1. Install tools:
```
   apt-get install gawk wget diffstat texinfo chrpath socat libsdl1.2-dev \
                    python-crypto repo checkpolicy python-git python-github \
                    python-ctypeslib bzr pigz m4 lftp openjdk-8-jdk git-core \
                    gnupg flex bison gperf build-essential zip curl zlib1g-dev \
                    gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev \
                    x11proto-core-dev libx11-dev lib32z-dev ccache libgl1-mesa-dev \
                    libxml2-utils xsltproc unzip python-clang-5.0 gcc-5 g++-5 -y
```
2. Checked with Python v 2.7.12, but other should also work

About:
======
prod-aos product is based on Renesas BSP, AGL, Xen hypervisor and AOS.

There are three domains which are running on top of Xen:
1. Generic machine independent control domain named "Domain-0". This initramfs based domain is responsible
   for managing VMs only (create/destroy/reboot guest domains). There is no HW assigned to this domain.
2. Machine dependent driver domain named "DomD". This domain is based on agl-image-minimal and contains
   AOS VIS and AOS telemetry emulator.
3. AOS domain named "DomF". This domain is based on core-image-minimal and contains AOS Service Manager,
   drives AOS services etc.

Build:
======
Our build system uses set of additional meta layers and tools.
1. Please, clone the following build scripts, master branch:
```
git clone https://github.com/xen-troops/build-scripts.git
cd build-scripts
```
2. In the build-scripts directory you will find a sample configuration
file `xt-build-server.cfg`:
```
cp xt-build-server.cfg xt-prod-aos.cfg
```
3. Edit it to fit your environment:
 - `workspace_base_dir`: change it to point to the place where the build will happen
 - `workspace_storage_base_dir`: change it to where downloads and other files will be put
 - comment out `XT_RCAR_EVAPROPRIETARY_DIR`
 - `XT_GUESTS_INSTALL = "domf"`
 - `XT_GUESTS_BUILD = "domf"`

For example,
```
[path]
workspace_base_dir = /home/workspace_base
workspace_storage_base_dir = /home/workspace_storage_base

[local_conf]
# correct path to the eva archives set
# XT_RCAR_EVAPROPRIETARY_DIR = "/path/to/eva/archives"
# guests domains which to be built and installed
XT_GUESTS_INSTALL = "domf"
XT_GUESTS_BUILD = "domf"
```
4. Run the build script for current stable release:
```
python ./build_prod.py --build-type dailybuild --machine MACHINE_NAME --product aos \
    --with-local-conf --config xt-prod-aos.cfg
```
The supported MACHINE_NAMEs are:
- h3ulcb     Starter Kit with H3 ES2 4GB
- h3ulcb-cb  Starter Kit with H3 ES2 4GB inside Cetibox

5. After that you will have all the build environment setup at workspace_base_dir
directory.

6. Now, to build the images you can run the same command as in 4) but with
additional argument --continue-build:
```
python ./build_prod.py --build-type dailybuild --machine MACHINE_NAME --product aos \
    --with-local-conf --config xt-prod-aos.cfg --continue-build
```
7. You are done. The artifacts of the build are located at workspace_base directory:
```
workspace_base/build/build/deploy/
├── dom0-image-thin-initramfs
│   └── images
│       └── generic-armv8-xt
│  
├── domd-agl-image-minimal
│   └── images
│       └── MACHINE_NAME-xt
│  
└── domu-image-fusion
     └── images
        └── generic-armv8-xt
```
Images are located at:

Domain-0: `workspace_base/build/build/deploy/dom0-image-thin-initramfs/images/generic-armv8-xt`.
Here we get a part of boot images:
* `uInitramfs` - thin-initramfs for Domain-0
* `Image` - Kernel image for Domain-0

DomD: `workspace_base/build/build/deploy/domd-agl-image-minimal/images/MACHINE-NAME-xt`.
Here we get a part of boot images, all bootloader images and rootfs image for DomD:
* `xen-uImage` - Xen main image
* `xenpolicy` - special image for Xen usage
* `dom0.dtb` - device-tree image for Domain-0
* `bootloader` images in both binary and srec formats
* `agl-image-minimal-MACHINE_NAME-xt.tar.bz2` - rootfs image for DomD

DomF: 
`workspace_base/build/build/deploy/domu-image-fusion/images/generic-armv8-xt`.
Here we get a rootfs image for DomF:
* `Image` -> vmlinux - Kernel image for DomF
* `core-image-minimal-generic-armv8-xt.tar.bz2` - rootfs image for DomF
  
Build logs are located at:
* Domain-0: `workspace_base/build/build/log/dom0-image-thin-initramfs/cooker/generic-armv8-xt`
* DomD: `workspace_base/build/tmp/log/domd-agl-image-minimal/cooker/MACHINE-NAME-xt`
* DomF: `workspace_base/build/build/log/domu-image-fusion/cooker/generic-armv8-xt`

If one wants to build any domain's images by hand, at the time of development
for instance, it is possible by going into desired directory and using poky to build:

For building Domain-0:
```
cd workspace_base/build/build/tmp/work/x86_64-xt-linux/dom0-image-thin-initramfs/1.0-r0/repo/
```
For building DomD:
```
cd workspace_base/build/build/tmp/work/x86_64-xt-linux/domd-agl-image-minimal/1.0-r0/repo/
```
For building DomF:
```
cd workspace_base/build/build/tmp/work/x86_64-xt-linux/domu-image-fusion/1.0-r0/repo/
```
Then:
```
source poky/oe-init-build-env
```
For building Domain-0:
```
bitbake core-image-thin-initramfs
```
For building DomD:
```
bitbake agl-image-minimal
```
For building DomF:
```
bitbake core-image-minimal
```

Usage:
======

Different helpers scripts and docs are located at: 
`build-workspace/build/meta-xt-prod-aos/doc`

Let's consider available boot options in details.

Using a storage device.
In order to boot system using a storage device, required storage device should be prepared
and flashed beforehand. The mk_sdcard_image.sh script is intended to help with that:
```
sudo ./mk_sdcard_image.sh -p /IMAGE_FOLDER -d /IMAGE_FILE -c aos
```
Where, `IMAGE_FOLDER` is a path to a folder where artifacts live (in the context of this document
it is a `deploy` directory) and `IMAGE_FILE` is an output image file or physical device how
it is appears in the filesystem (`/dev/sdx`). As far as script intended to support different products,
we need to specify `-c aos` for this product.

In case of SDx card booting we just have to insert SD card to a Host machine and run a script,
the latter will do all required actions automatically. All what we need to care about is to write
proper environment variables from U-Boot command line (boot_dev/bootcmd) according to the chosen SDx.
See `u-boot-env.txt` for details.

In case of eMMC booting, we have to have an access to it in order to flash images.
It is going to be not quite easy as for removable SD card, but the one of the possible ways is
to prepare the image blob using the same script, copy resulting blob to NFS root directory,
set system to boot via NFS, go to a DomD on target (where eMMC device is available)
and using "dd" command just copy blob to eMMC.

For example, prepare an image blob:
```
sudo ./mk_sdcard_image.sh -p /IMAGE_FOLDER -d /home/emmc.img -c aos
```
and then run on target:
```
dd if=/home/emmc.img of=/dev/mmcblk0
```
After getting eMMC flashed we have to choose it to be an boot device in a similar way as it is done
for SD card. See `u-boot-env.txt` for details.

So, as you can see, varying U-Boot's `boot_dev` and `bootcmd` environment variables
and domain config's `extra` and `disk` options it is possible to choose  different boot device
for each system component.

When you create image (or flash product to SD-card) using `mk_sdcard_image.sh`
it will have partitions Dom0, DomD, DomF.

You can inspect partitions inside image using `losetup` and `lsblk`.
See example below for Ubuntu 18, assuming that the image was named 'prod-aos.img'.
Pay attention that text after ## is a comment to console output.
Sizes of partitions may vary.

```
 sudo losetup --find --partscan --show ./prod-aos.img
/dev/loop23

$ lsblk /dev/loop23
NAME       MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
loop23       7:23   0    7G  0 loop
├─loop23p1 259:0    0  256M  0 loop                 ## Dom0, also is used by U-Boot to load xen
├─loop23p2 259:1    0  3.9G  0 loop                 ## DomD
└─loop23p3 259:2    0  3.9G  0 loop                 ## DomF

$ sudo losetup -d /dev/loop23
```

Additional script available in the product: `uirfs.sh`.

This script is intended to pack/unpack uInitramfs for Domain-0. It might be helpful since uInitramfs
contains a lot of things which may changed during testing. The "xt" directory ships all guest domain
configs, device-tree and Kernel images, etc.

For example, unpack uInitramfs:
```
cd /srv
sudo mkdir initramfs
sudo ./uirfs.sh unpack uInitramfs initramfs
```
Modify it's components if needed.
For example, domain config files located at: `/srv/initramfs/xt/dom.cfg/`

pack it back:
```
sudo ./uirfs.sh pack uInitramfs initramfs
```
