SUMMARY = "Target to generate AOS update bundle"
LICENSE = "Apache-2.0"

# Inherit

inherit metadata-generator bundle-generator rootfs-image-generator

# Require

require recipes-domx/meta-xt-prod-domx/inc/xt_shared_env.inc

# Depends

DEPENDS_remove = " ostree-native squashfs-tools-native"

# Variables

BUNDLE_DIR ?= "${DEPLOY_DIR}/update"
BUNDLE_FILE ?= "${IMAGE_BASENAME}-${MACHINE}-${BUNDLE_IMAGE_VERSION}.tar"

BUNDLE_DOM0_TYPE ?= "full"
BUNDLE_DOMD_TYPE ?= "full"
BUNDLE_DOMF_TYPE ?= "full"

BUNDLE_OSTREE_REPO ?= "${DEPLOY_DIR}/update/repo"

# Dependencies

do_build[depends] += "dom0-image-thin-initramfs:do_${BB_DEFAULT_TASK}"
do_build[cleandirs] = "${BUNDLE_WORK_DIR}"
do_build[dirs] = "${BUNDLE_DIR}"
do_create_dom0_image[cleandirs] = "${WORKDIR}/rootfs"

# Configuration

BUNDLE_DOM0_ID = "dom0"
BUNDLE_DOMD_ID = "domd"
BUNDLE_DOMF_ID = "domf"

BUNDLE_DOM0_DESC = "Dom0 image"
BUNDLE_DOMD_DESC = "DomD image"
BUNDLE_DOMF_DESC = "DomF image"

ROOTFS_IMAGE_DIR = "${BUNDLE_WORK_DIR}"
ROOTFS_EXCLUDE_FILES = "var/*"

DOM0_IMAGE_FILE = "${BUNDLE_DOM0_ID}-${MACHINE}-${BUNDLE_DOM0_TYPE}-${DOM0_IMAGE_VERSION}.gz"
DOMD_IMAGE_FILE = "${BUNDLE_DOMD_ID}-${MACHINE}-${BUNDLE_DOMD_TYPE}-${DOMD_IMAGE_VERSION}.squashfs"
DOMF_IMAGE_FILE = "${BUNDLE_DOMF_ID}-${MACHINE}-${BUNDLE_DOMF_TYPE}-${DOMF_IMAGE_VERSION}.squashfs"

DOM0_PART_SIZE = "128"
DOM0_PART_LABEL = "boot"

# Tasks

python do_create_metadata() {
    components_metadata = []
    
    if d.getVar("BUNDLE_DOM0_TYPE") == "full":
        components_metadata.append(create_component_metadata(d.getVar("BUNDLE_DOM0_ID"), d.getVar("DOM0_IMAGE_FILE"),
            d.getVar("DOM0_IMAGE_VERSION"), d.getVar("BUNDLE_DOM0_DESC")))
    elif d.getVar("BUNDLE_DOM0_TYPE"):
        bb.fatal("Wrong dom0 image type: %s" % d.getVar("BUNDLE_DOM0_TYPE"))

    if d.getVar("BUNDLE_DOMD_TYPE"):
        install_dep = {}
        annotations = {}

        if d.getVar("BUNDLE_DOMD_TYPE") == "incremental":
            install_dep = create_dep(d.getVar("BUNDLE_DOMD_ID"), d.getVar("DOMD_REF_VERSION"))
            annotations = {"type": "incremental"}
        elif d.getVar("BUNDLE_DOMD_TYPE") == "full":
            annotations = {"type": "full"}
        else:
            bb.fatal("Wrong domd image type: %s" % d.getVar("BUNDLE_DOMD_TYPE"))

        components_metadata.append(create_component_metadata(d.getVar("BUNDLE_DOMD_ID"), d.getVar("DOMD_IMAGE_FILE"),
            d.getVar("DOMD_IMAGE_VERSION"), d.getVar("BUNDLE_DOMD_DESC"), install_dep, None, annotations))

    if d.getVar("BUNDLE_DOMF_TYPE"):
        install_dep = {}
        annotations = {}

        if d.getVar("BUNDLE_DOMF_TYPE") == "incremental":
            install_dep = create_dep(d.getVar("BUNDLE_DOMF_ID"), d.getVar("DOMF_REF_VERSION"))
            annotations = {"type": "incremental"}
        elif d.getVar("BUNDLE_DOMF_TYPE") == "full":
            annotations = {"type": "full"}
        else:
            bb.fatal("Wrong domf image type: %s" % d.getVar("BUNDLE_DOMF_TYPE"))

        components_metadata.append(create_component_metadata(d.getVar("BUNDLE_DOMF_ID"), d.getVar("DOMF_IMAGE_FILE"),
            d.getVar("DOMF_IMAGE_VERSION"), d.getVar("BUNDLE_DOMF_DESC"), install_dep, None, annotations))

    write_image_metadata(d.getVar("BUNDLE_WORK_DIR"), d.getVar("BOARD_MODEL"), components_metadata)
}

do_create_dom0_image() {
    dom0_name=`ls ${DEPLOY_DIR} | grep dom0`
    dom0_root="${DEPLOY_DIR}/${dom0_name}"

    image=`find $dom0_root -name Image`
    uinitramfs=`find $dom0_root -name uInitramfs`
    aos=`find $dom0_root -name aos`

    domd_name=`ls ${DEPLOY_DIR} | grep domd`
    domd_root="${DEPLOY_DIR}/${domd_name}"

    dom0dtb=`find $domd_root -name dom0.dtb`
    xenpolicy=`find $domd_root -name xenpolicy`
    xenuimage=`find $domd_root -name xen-uImage`

    install -d ${WORKDIR}/rootfs/boot

    for f in $image $uinitramfs $dom0dtb $xenpolicy $xenuimage ; do
        cp -Lrf $f ${WORKDIR}/rootfs/boot
    done

    cp -Lrf $aos ${WORKDIR}/rootfs

    dd if=/dev/zero of=${WORKDIR}/dom0.part bs=1M count=${DOM0_PART_SIZE}
    mkfs.ext4 -F -L ${DOM0_PART_LABEL} -E root_owner=0:0 -d ${WORKDIR}/rootfs ${WORKDIR}/dom0.part

    gzip < ${WORKDIR}/dom0.part > ${BUNDLE_WORK_DIR}/${DOM0_IMAGE_FILE}
}

python do_create_domd_image() {
    d.setVar("ROOTFS_OSTREE_REPO", os.path.join(d.getVar("BUNDLE_OSTREE_REPO"), d.getVar("BUNDLE_DOMD_ID")))
    d.setVar("ROOTFS_IMAGE_TYPE", d.getVar("BUNDLE_DOMD_TYPE"))
    d.setVar("ROOTFS_IMAGE_VERSION", d.getVar("DOMD_IMAGE_VERSION"))
    d.setVar("ROOTFS_REF_VERSION", d.getVar("DOMD_REF_VERSION"))
    d.setVar("ROOTFS_IMAGE_FILE", d.getVar("DOMD_IMAGE_FILE"))
    d.setVar("ROOTFS_SOURCE_DIR", os.path.join(d.getVar("XT_DIR_ABS_SHARED_ROOTFS_DOMD"),"core-image-minimal"))

    bb.build.exec_func("do_create_rootfs_image", d)
}

python do_create_domf_image() {
    d.setVar("ROOTFS_OSTREE_REPO", os.path.join(d.getVar("BUNDLE_OSTREE_REPO"), d.getVar("BUNDLE_DOMF_ID")))
    d.setVar("ROOTFS_IMAGE_TYPE", d.getVar("BUNDLE_DOMF_TYPE"))
    d.setVar("ROOTFS_IMAGE_VERSION", d.getVar("DOMF_IMAGE_VERSION"))
    d.setVar("ROOTFS_REF_VERSION", d.getVar("DOMF_REF_VERSION"))
    d.setVar("ROOTFS_IMAGE_FILE", d.getVar("DOMF_IMAGE_FILE"))
    d.setVar("ROOTFS_SOURCE_DIR", os.path.join(d.getVar("XT_DIR_ABS_SHARED_ROOTFS_DOMF"),"core-image-minimal"))

    bb.build.exec_func("do_create_rootfs_image", d)
}

python do_build() {
    if not d.getVar("BUNDLE_DOM0_TYPE") and not d.getVar("BUNDLE_DOMD_TYPE") and not d.getVar("BUNDLE_DOMF_TYPE"):
        bb.fatal("There are no componenets to add to the bundle")

    bb.build.exec_func("do_create_metadata", d)
    bb.build.exec_func("do_create_dom0_image", d)
    bb.build.exec_func("do_create_domd_image", d)
    bb.build.exec_func("do_create_domf_image", d)
    bb.build.exec_func("do_pack_bundle", d)
}
