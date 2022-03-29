# meta-xt-prod-aos #

This repository contains Renesas RCAR Gen3-specific Yocto layers for
Xen Troops distro and `moulin` project file to build it. Layers in this
repository provide final recipes to build meta-xt-prod-devel
distro. This distro is the main Xen Troops product, that we use to
develop and integrate new features

Those layers *may* be added and used manually, but they were written
with [Moulin](https://moulin.readthedocs.io/en/latest/) build system,
as Moulin-based project files provide correct entries in local.conf

# Moulin project file

Work is still in progress, but right now the following features are tested and working:

* GPU sharing between domains
* 3 domains are being built: Linux based Dom0, DomD and DomU
* Networking in DomD and DomF
* Network (NFS) boot for DomD and DomF
* OP-TEE client in DomF
* Virtualized OP-TEE build
* ARM-TF that boots into EL2

Features that are present but not tested:

* AosBox with Starter Kit Premiere 8GB board
* SD or eMMC boot

# Building
## Requirements

1. Ubuntu 18.0+ or any other Linux distribution which is supported by Poky/OE
2. Development packages for Yocto. Refer to [Yocto
   manual](https://www.yoctoproject.org/docs/current/mega-manual/mega-manual.html#brief-build-system-packages).
3. You need `Moulin` installed in your PC. Recommended way is to
   install it for your user only: `pip3 install --user
   git+https://github.com/xen-troops/moulin`. Make sure that your
   `PATH` environment variable includes `${HOME}/.local/bin`.
4. Ninja build system: `sudo apt install ninja-build` on Ubuntu

## Fetching

You can fetch/clone this whole repository, but you actually need only
one file from it: `prod-aos-rcar.yaml`. During build `moulin` will
fetch this repository again into `yocto/` directory. So, to reduce
possible confuse, we recommend to download only
`prod-devel-rcar.yaml`:

```
# curl -O https://raw.githubusercontent.com/xen-troops/meta-xt-prod-aos/master/prod-aos-rcar.yaml
```

## Building

Moulin is used to generate Ninja build file: `moulin
prod-aos-rcar.yaml`. This project have provides number of additional
options. You can use check them with `--help-config` command line
option:

```
# moulin prod-devel-rcar.yaml --help-config
usage: moulin prod-aos-rcar.yaml

Config file description: Xen-Troops development setup for Renesas RCAR Gen3
hardware

```

Moulin will generate `build.ninja` file. After that - run `ninja` to
build the images. This will take some time and disk space, as it will
built 3 separate Yocto images.

## Creating SD card image

Image file can be created with `rouge` tool. This is a companion
application for `moulin`.

It can be invoked either as a standalone tool, or via Ninja.

### Creating image(s) via Ninja

Newer versions of `moulin` (>= 0.5) will generate two additional Ninja
targets:

 - `image-full`

Thus, you can just run `ninja image-full` or `ninja full.img` which
will generate the `full.img` in your build directory.

Then you can use `dd` to write this image to your SD card. Don't
forget `conv=sparse` option for `dd` to speed up writing.

### Using `rouge` in standalone mode

In this mode you can write image right to SD card. But it requires
additional options.

In standalone mode`rouge` accepts the same parameters like
`--MACHINE`, `--ENABLE_ANDROID`, `--ENABLE_DOMU` as `moulin` do.
But, it is not required for the prod-aos product, because there is just a
configuration hardcoded in prod-aos-rcar.yaml:
MACHINE:h3ulcb
DomF domain is used by default.

This XT product provides one image: `full`.

You can prepare image by running

```
# rouge prod-aos-rcar.yaml -i full
```

This will create file `full.img` in your current directory.

Also you can write image directly to a SD card by running

```
# sudo rouge prod-aos-rcar.yaml -i full -so /dev/sdX
```

**BE SURE TO PROVIDE CORRECT DEVICE NAME**. `rouge` have no
interactive prompts and will overwrite your device right away. **ALL
DATA WILL BE LOST**.

For more information about `rouge` check its
[manual](https://moulin.readthedocs.io/en/latest/rouge.html).
