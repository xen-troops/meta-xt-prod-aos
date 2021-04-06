###############################################################################
# PVR graphics
###############################################################################
# number of supported OSes for VGPU virtualization
XT_PVR_NUM_OSID="2"

###############################################################################
# locations of various artifacts within root file systems
# and shared rootfs folder
###############################################################################

# known domains
XT_DIR_REL_DOM0 = "dom0"
XT_DIR_REL_DOMD = "domd"
XT_DIR_REL_DOMA = "doma"
XT_DIR_REL_DOMF = "domf"
XT_DIR_REL_DOMR = "domr"
XT_DIR_REL_DOMU = "domu"

# these are the folders within domain's root filesystem where all
# installed artifacts live
XT_DIR_ABS_ROOTFS = "/xt"

XT_DIR_ABS_ROOTFS_DOM0 = "${XT_DIR_ABS_ROOTFS}/${XT_DIR_REL_DOM0}/"
XT_DIR_ABS_ROOTFS_DOMD = "${XT_DIR_ABS_ROOTFS}/${XT_DIR_REL_DOMD}/"
XT_DIR_ABS_ROOTFS_DOMA = "${XT_DIR_ABS_ROOTFS}/${XT_DIR_REL_DOMA}/"
XT_DIR_ABS_ROOTFS_DOMF = "${XT_DIR_ABS_ROOTFS}/${XT_DIR_REL_DOMF}/"
XT_DIR_ABS_ROOTFS_DOMR = "${XT_DIR_ABS_ROOTFS}/${XT_DIR_REL_DOMR}/"
XT_DIR_ABS_ROOTFS_DOMU = "${XT_DIR_ABS_ROOTFS}/${XT_DIR_REL_DOMU}/"

# these are folder names to be used accross domains to install
# various types of artifacts
XT_DIR_ABS_ROOTFS_SCRIPTS = "${XT_DIR_ABS_ROOTFS}/scripts"
XT_DIR_ABS_ROOTFS_CFG = "${XT_DIR_ABS_ROOTFS}/cfg"
XT_DIR_ABS_ROOTFS_DOM_CFG = "${XT_DIR_ABS_ROOTFS}/dom.cfg"

# these are the folders within ${XT_SHARED_ROOTFS_DIR}
# directory used to exchange boot artifacts between domains
# being built, e.g. kernel image, dtb etc.
XT_DIR_ABS_SHARED_BOOT_DOM0 = "${XT_SHARED_ROOTFS_DIR}/${XT_DIR_REL_DOM0}/boot"
XT_DIR_ABS_SHARED_BOOT_DOMD = "${XT_SHARED_ROOTFS_DIR}/${XT_DIR_REL_DOMD}/boot"
XT_DIR_ABS_SHARED_BOOT_DOMA = "${XT_SHARED_ROOTFS_DIR}/${XT_DIR_REL_DOMA}/boot"
XT_DIR_ABS_SHARED_BOOT_DOMF = "${XT_SHARED_ROOTFS_DIR}/${XT_DIR_REL_DOMF}/boot"
XT_DIR_ABS_SHARED_BOOT_DOMR = "${XT_SHARED_ROOTFS_DIR}/${XT_DIR_REL_DOMR}/boot"
XT_DIR_ABS_SHARED_BOOT_DOMU = "${XT_SHARED_ROOTFS_DIR}/${XT_DIR_REL_DOMU}/boot"

XT_DIR_ABS_SHARED_INITRAMFS_DOMD = "${XT_SHARED_ROOTFS_DIR}/${XT_DIR_REL_DOMD}/initramfs"
XT_DIR_ABS_SHARED_INITRAMFS_DOMF = "${XT_SHARED_ROOTFS_DIR}/${XT_DIR_REL_DOMF}/initramfs"

XT_DIR_ABS_SHARED_ROOTFS_DOMD = "${XT_SHARED_ROOTFS_DIR}/${XT_DIR_REL_DOMD}/rootfs"
XT_DIR_ABS_SHARED_ROOTFS_DOMF = "${XT_SHARED_ROOTFS_DIR}/${XT_DIR_REL_DOMF}/rootfs"

###############################################################################
# Upddate bundle
###############################################################################

BOARD_MODEL ?= "h3ulcb;1.0"
BOARD_MODEL_cetibox ?= "cetibox;1.0"

# Bundle image version used as suffix in the bundle name
BUNDLE_IMAGE_VERSION ?= "1.0.0"

# Dom0 image type. Dom0 supports only "full". Empty value means dom0 update image
# will not be included into the bunle.
BUNDLE_DOM0_TYPE ?= "full"
# DomD image type. DomD supports "full" and "incremental" update. Empty value
# means DomD update image will not be included into the bunle.
BUNDLE_DOMD_TYPE ?= "full"
# DomF image type. DomF supports "full" and "incremental" update. Empty value
# means DomF update image will not be included into the bunle.
BUNDLE_DOMF_TYPE ?= "full"

# Dom0 image version
DOM0_IMAGE_VERSION ?= "1.0.0"
# DomD image version
DOMD_IMAGE_VERSION ?= "1.0.0"
# DomF image version
DOMF_IMAGE_VERSION ?= "1.0.0"

# DomD reference version, used for incremental update.
DOMD_REF_VERSION ?= "1.0.0"
# DomF reference version, used for incremental update.
DOMF_REF_VERSION ?= "1.0.0"
