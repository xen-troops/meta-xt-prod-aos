#!/bin/bash -e

MOUNT_POINT="/tmp/mntpoint"
CUR_STEP=1

usage()
{
	echo "###############################################################################"
	echo "SD card image builder script for AOS product. v0.1"
	echo "###############################################################################"
	echo "Usage:"
	echo "`basename "$0"` <-p image-folder> <-d image-file> [-s image-size-gb] [-u dom0|domd|domf]"
	echo "	-p image-folder	Base daily build folder where artifacts live"
	echo "	-d image-file	Output image file or physical device"
	echo "	-s image-size	Optional, image size in GiB"
	echo "	-u domain	Optional, unpack the domain specified"

	exit 1
}

print_step()
{
	local caption=$1
	echo "###############################################################################"
	echo "Step $CUR_STEP: $caption"
	echo "###############################################################################"
	((CUR_STEP++))
}

###############################################################################
# Inflate image
###############################################################################
inflate_image()
{
	local dev=$1
	local size_gb=$2

	print_step "Inflate image"
	echo "DEV -" $dev
	if  [ -b "$dev" ] ; then
		echo "Using physical block device $dev"
		return 0
	fi

	echo "Inflating image file at $dev of size ${size_gb}GiB"

	local inflate=1
	if [ -e $1 ] ; then
		echo ""
		read -r -p "File $dev exists, remove it? [y/N]:" yesno
		case "$yesno" in
		[yY])
			sudo rm -f $dev || exit 1
		;;
		*)
			echo "Reusing existing image file"
			inflate=0
		;;
		esac
	fi
	if [[ $inflate == 1 ]] ; then
		sudo dd if=/dev/zero of=$dev bs=1M count=0 seek=$(($size_gb*1024)) || exit 1
	fi
}

###############################################################################
# Partition image
###############################################################################
partition_image()
{
	print_step "Make partitions"

	sudo parted -s $1 mklabel msdos || true

	sudo parted -s $1 mkpart primary ext4 1MiB 257MiB || true
	sudo parted -s $1 mkpart primary ext4 257MiB 4257MiB || true
	sudo parted -s $1 mkpart primary ext4 4257MiB 8257MiB || true
	sudo parted $1 print
	sudo partprobe $1
}

###############################################################################
# Make file system
###############################################################################

mkfs_one()
{
	local img_output_file=$1
	local loop_base=$2
	local part=$3
	local label=$4
	local loop_dev="${loop_base}p${part}"

	print_step "Making ext4 filesystem for $label"

	sudo mkfs.ext4 -O ^64bit -F $loop_dev -L $label
}

mkfs_boot()
{
	local img_output_file=$1
	local loop_dev=$2

	mkfs_one $img_output_file $loop_dev 1 boot
}

mkfs_domd()
{
	local img_output_file=$1
	local loop_dev=$2

	mkfs_one $img_output_file $loop_dev 2 domd
}

mkfs_domf()
{
	local img_output_file=$1
	local loop_dev=$2

	mkfs_one $img_output_file $loop_dev 3 domf
}

mkfs_image()
{
	local img_output_file=$1
	local loop_dev=$2
	sudo losetup -P $loop_dev $img_output_file

	mkfs_boot $img_output_file $loop_dev
	mkfs_domd $img_output_file $loop_dev
	mkfs_domf $img_output_file $loop_dev
}

###############################################################################
# Mount partition
###############################################################################

mount_part()
{
	local loop_base=$1
	local img_output_file=$2
	local part=$3
	local mntpoint=$4
	local loop_dev=${loop_base}p${part}

	mkdir -p "${mntpoint}" || true
	sudo mount $loop_dev "${mntpoint}"
}

umount_part()
{
	local loop_base=$1
	local part=$2
	local loop_dev=${loop_base}p${part}

	sudo umount $loop_dev
}

###############################################################################
# Unpack domain
###############################################################################

unpack_dom_from_tar()
{
	local db_base_folder=$1
	local loop_base=$2
	local img_output_file=$3
	local part=$4
	local domain=$5
	local loop_dev=${loop_base}p${part}

	local dom_name=`ls $db_base_folder | grep $domain`
	local dom_root=$db_base_folder/$dom_name
	# take the latest - useful if making image from local build
	local rootfs=`find $dom_root -name "*rootfs.tar.bz2" | xargs ls -t | head -1`

	echo "Root filesystem is at $rootfs"

	mount_part $loop_base $img_output_file $part $MOUNT_POINT

	sudo tar --extract --bzip2 --numeric-owner --preserve-permissions --preserve-order --totals \
		--xattrs-include='*' --directory="${MOUNT_POINT}" --file=$rootfs

	umount_part $loop_base $part
}

unpack_dom0()
{
	local db_base_folder=$1
	local loop_base=$2
	local img_output_file=$3

	local part=1

	print_step "Unpacking Dom0"

	local dom0_name=`ls $db_base_folder | grep dom0-image-thin`
	local dom0_root=$db_base_folder/$dom0_name

	local domd_name=`ls $db_base_folder | grep domd`
	local domd_root=$db_base_folder/$domd_name

	local Image=`find $dom0_root -name Image`
	local uInitramfs=`find $dom0_root -name uInitramfs`
	local dom0dtb=`find $domd_root -name dom0.dtb`
	local xenpolicy=`find $domd_root -name xenpolicy`
	local xenuImage=`find $domd_root -name xen-uImage`

	echo "Dom0 kernel image is at $Image"
	echo "Dom0 initramfs is at $uInitramfs"
	echo "Dom0 device tree is at $dom0dtb"
	echo "Xen policy is at $xenpolicy"
	echo "Xen image is at $xenuImage"

	mount_part $loop_base $img_output_file $part $MOUNT_POINT

	sudo mkdir "${MOUNT_POINT}/boot" || true

	for f in $Image $uInitramfs $dom0dtb $xenpolicy $xenuImage ; do
		sudo cp -L $f "${MOUNT_POINT}/boot/"
	done

	umount_part $loop_base $part
}

unpack_domd()
{
	local db_base_folder=$1
	local loop_dev=$2
	local img_output_file=$3

	print_step  "Unpacking DomD"

	unpack_dom_from_tar $db_base_folder $loop_dev $img_output_file 2 domd
}

unpack_domf()
{
	local db_base_folder=$1
	local loop_dev=$2
	local img_output_file=$3

	print_step  "Unpacking DomF"

	unpack_dom_from_tar $db_base_folder $loop_dev $img_output_file 3 domu
}

unpack_image()
{
	local db_base_folder=$1
	local loop_dev=$2
	local img_output_file=$3

	unpack_dom0 $db_base_folder $loop_dev $img_output_file
	unpack_domd $db_base_folder $loop_dev $img_output_file
	unpack_domf $db_base_folder $loop_dev $img_output_file
}

###############################################################################
# Common
###############################################################################

make_image()
{
	local db_base_folder=$1
	local img_output_file=$2
	local image_sg_gb=${3:-5}
	local loop_dev="$(losetup -f)"

	print_step "Preparing image at ${img_output_file}"

	sudo umount -f ${MOUNT_POINT} || true
	ls ${img_output_file}?* | xargs -n1 sudo umount -l -f || true

	inflate_image $img_output_file $image_sg_gb
	partition_image $img_output_file
	mkfs_image $img_output_file $loop_dev
	unpack_image $db_base_folder $loop_dev $img_output_file

	sync
	sudo losetup -d $loop_dev || true
}

unpack_domain()
{
	local db_base_folder=$1
	local img_output_file=$2
	local domain=$3

	print_step "Unpacking single domain: $domain"

	sudo umount -f ${img_output_file}* || true

	case $domain in
		dom0)
			sudo losetup -P -f $img_output_file
			loop_dev=`sudo losetup -j $img_output_file | cut -d":" -f1`
			mkfs_boot $img_output_file $loop_dev
			unpack_dom0 $db_base_folder $loop_dev $img_output_file
		;;
		domd)
			sudo losetup -P -f $img_output_file
			loop_dev=`sudo losetup -j $img_output_file | cut -d":" -f1`
			mkfs_domd $img_output_file $loop_dev
			unpack_domd $db_base_folder $loop_dev $img_output_file
		;;
		domf)
			sudo losetup -P -f $img_output_file
			loop_dev=`sudo losetup -j $img_output_file | cut -d":" -f1`
			mkfs_domf $img_output_file $loop_dev
			unpack_domf $db_base_folder $loop_dev $img_output_file
		;;
		\?) echo "Invalid domain -$OPTARG" >&2
		exit 1
		;;
	esac
	sudo losetup -d $loop_dev
}



print_step "Parsing input parameters"

while getopts ":p:d:s:u:" opt; do
	case $opt in
		p) ARG_DEPLOY_PATH="$OPTARG"
		;;
		d) ARG_DEPLOY_DEV="$OPTARG"
		;;
		s) ARG_IMG_SIZE_GB="$OPTARG"
		;;
		u) ARG_UNPACK_DOM="$OPTARG"
		;;
		\?) echo "Invalid option -$OPTARG" >&2
		exit 1
		;;
	esac
done

if [ -z "${ARG_DEPLOY_PATH}" ]; then
	echo "No path to deploy directory passed with -p option"
	usage
fi

if [ -z "${ARG_DEPLOY_DEV}" ]; then
	echo "No device/file name passed with -d option"
	usage
fi

# Check that deploy path contains dom0, domd and doma
dom0_name=`ls ${ARG_DEPLOY_PATH} | grep dom0-image-thin` || true
domd_name=`ls ${ARG_DEPLOY_PATH} | grep domd` || true
domf_name=`ls ${ARG_DEPLOY_PATH} | grep domu-image-fusion` || true
if [ -z "$dom0_name" ]; then
	echo "Error: deploy path has no dom0."
	exit 2
fi
if [ -z "$domd_name" ]; then
	echo "Error: dploy path has no domd."
	exit 2
fi
if [ -z "$domf_name" ]; then
	echo "Error: deploy path has no domf."
	exit 2
fi

echo "Using deploy path: \"$ARG_DEPLOY_PATH\""
echo "Using device     : \"$ARG_DEPLOY_DEV\""

sudo losetup -P -f $ARG_DEPLOY_DEV
loop_dev_in=`sudo losetup -j $ARG_DEPLOY_DEV | cut -d":" -f1`

if [ ! -z "${ARG_UNPACK_DOM}" ]; then
	unpack_domain $ARG_DEPLOY_PATH $loop_dev_in $ARG_UNPACK_DOM
else
	make_image $ARG_DEPLOY_PATH $loop_dev_in $ARG_IMG_SIZE_GB
fi

print_step "Syncing"
sync
sudo losetup -d $loop_dev_in
print_step "Done"
