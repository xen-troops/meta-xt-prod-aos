#!/bin/sh

. "$(dirname "$0")/rootfs_full.sh"

mask_file() {
    mknod $1 -m0 c 0 0
}

containsElement () {
    search=$1
    massive=$2

    for e in $massive
    do
        if [ "$e" = "$search" ]; then 
            echo "File <"$search"> is detected in update list"
            return 1
        fi
    done
    return 0
}

create_rootfs_overlay() {
    PARENT_ROOTFS=$1
    UPDATE_ROOTFS=$2
    RESULT_ROOTFS_DIR=$3

    rm -rf $RESULT_ROOTFS_DIR
    mkdir -p $RESULT_ROOTFS_DIR

    old_files=`find $PARENT_ROOTFS -type f,l 2>/dev/null | cut -d'/' -f2-`

    if [ -z "$old_files" ]; then
        echo "Parent directory is empty"
        exit 1
    fi

    update_list=`rsync -avhH --update --dry-run $UPDATE_ROOTFS/ $PARENT_ROOTFS/ 2>/dev/null | tail -n +2 | head -n -3 | awk '{print $1}'`

    for file in $old_files
    do
        if [ -f $PARENT_ROOTFS/$file ] || [ -L $PARENT_ROOTFS/$file ]; then
	    containsElement $file "$update_list"

	    if [ $? -eq 0 ]; then
	        if [ -h $PARENT_ROOTFS/$file ]; then
	            echo "Symlink: $PARENT_ROOTFS/$file"
	            if [ -h $PARENT_ROOTFS/$file ] && [ ! -h $UPDATE_ROOTFS/$file ]; then
	                mkdir -p $(dirname $RESULT_ROOTFS_DIR/$file)
	                mask_file $RESULT_ROOTFS_DIR/$file
	            fi
	        elif [ -f $PARENT_ROOTFS/$file ]; then
	            echo "Regular: $PARENT_ROOTFS/$file"
	            if [ -e $PARENT_ROOTFS/$file ] && [ ! -e $UPDATE_ROOTFS/$file ]; then
	                mkdir -p $(dirname $RESULT_ROOTFS_DIR/$file)
	                mask_file $RESULT_ROOTFS_DIR/$file
	            fi
	        fi
	    fi
        fi
    done

    echo "Copy updated files to result directory"

    for file in $update_list
    do
        if [ -f $UPDATE_ROOTFS/$file ] || [ -L $UPDATE_ROOTFS/$file ]; then
	        mkdir -p $(dirname $RESULT_ROOTFS_DIR/$file)
	        cp -aP $UPDATE_ROOTFS/$file $RESULT_ROOTFS_DIR/$file
        fi
    done
}

create_squashfs_incremental_rootfs() {
    parent_db_dir=$1
    image_db_dir=$2
    work_dir=$3
    update_image_path=$4
    target=$5

    extract_parent_dir=$work_dir/$target/parent_rootfs
    extract_image_dir=$work_dir/$target/image_rootfs
    overlay_image_dir=$work_dir/$target/overlay_rootfs

    mkdir -p $extract_parent_dir
    mkdir -p $extract_image_dir
    mkdir -p $overlay_image_dir

    old_rootfs_tar=`find_rootfs_tar $parent_db_dir $target`
    new_rootfs_tar=`find_rootfs_tar $image_db_dir $target`

    rootfs_is_differ $old_rootfs_tar $new_rootfs_tar

	if [ $? -eq 0 ]; then
		echo "Old and new rootfs are same. No need to create update"
        return 0
	fi

    untar_bzip2 $old_rootfs_tar $extract_parent_dir

    untar_bzip2 $new_rootfs_tar $extract_image_dir

    create_rootfs_overlay $extract_parent_dir $extract_image_dir $overlay_image_dir

    mksquashfs $overlay_image_dir/ $update_image_path

    return 1
}

