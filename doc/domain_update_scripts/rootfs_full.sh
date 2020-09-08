#!/bin/sh

find_rootfs_tar() {
    base_folder=$1
    dom_name=$2

    result=$(find $base_folder -name "*rootfs.tar.bz2")
    echo "$result" | grep "$dom_name"
}

untar_bzip2() {
    tar_file=$1
    dest_dir=$2

    echo "Unpack rootfs $tar_file file into $dest_dir directory"

    tar --extract --bzip2 --numeric-owner --preserve-permissions --preserve-order --totals \
    --xattrs-include='*' --file=$tar_file -C $dest_dir
}

tar_to_squashfs() {
    workdir=$1
    rootfs_tar=$2
    update_image=$3
    rootfs_extract_dir=$workdir/rootfs

    echo "Root filesystem: $rootfs_tar"

    if [ -d $rootfs_extract_dir ]; then
	    rm -rf $rootfs_extract_dir/*
    else
	    mkdir -p $rootfs_extract_dir
    fi

    untar_bzip2 $rootfs_tar $rootfs_extract_dir

    mksquashfs $rootfs_extract_dir $update_image
}

rootfs_is_differ() {
    old_tar=$1
    new_tar=$2

    if diff -q $old_tar $new_tar; then
	    return 0
    fi

    return 1
}

prepare_full_rootfs_update() {
    old_db_dir=$1
    new_db_dir=$2
    work_dir=$3
    update_image=$4
    target=$5

    new_rootfs_tar=`find_rootfs_tar $new_db_dir $target`
    old_rootfs_tar=`find_rootfs_tar $old_db_dir $target`

    rootfs_is_differ $old_rootfs_tar $new_rootfs_tar

    if [ $? -eq 1 ]; then
	    echo "Prepare new rootfs squashfs image ..."
	    tar_to_squashfs $work_dir $new_rootfs_tar $update_image
        return 1
    fi

    return 0
}
