#!/bin/sh

dom0_files="Image uInitramfs"
domd_files="dom0.dtb xenpolicy xen-uImage"

list_dom0_artifacts() {
	db_base_folder=$1

	dom0_root=`find $db_base_folder -type d -name "dom0-image-thin*"`

	domd_name=`ls $db_base_folder | grep domd`
	domd_root=$db_base_folder/$domd_name

	files=""

	for file in $dom0_files
	do
		files="$files `find $dom0_root -name $file`"
	done

	for file in $domd_files
	do
		files="$files `find $domd_root -name $file`"
	done

	echo "$files"
}

# size in MiB
make_dom0_blob() {
	image_path=$1
	size=$2
	fs_type=$3
	copied_files=$4

	dd if=/dev/zero of=$image_path bs=1M count=$size conv=sync
	mkfs -t $fs_type $image_path

	block_dev=`udisksctl loop-setup -f $image_path | awk '{print $5}' | sed 's/.$//'`

	mount_point=`udisksctl mount -b $block_dev | awk '{print $4}' | sed 's/.$//'`

	for file in $copied_files
	do
		echo "Copy $file to $mount_point ..."
		cp -L $file $mount_point/
	done

	udisksctl unmount -b $block_dev
	udisksctl loop-delete -b $block_dev
}

dom0_artifacts_is_differ() {
    old_files=$1
    new_files=$2

    for old_file in $old_files
    do
        file_available=0

        for new_file in $new_files
        do
            old_name=$(basename $old_file)
            new_name=$(basename $new_file)
            if [ "$old_name" = "$new_name" ]; then
                new_dir=$(dirname $new_file)
                old_dir=$(dirname $old_file)

                if ! diff -q $old_dir/$old_name $new_dir/$new_name; then
                    return 1
                fi

                file_available=1
            fi
        done

        if [ $file_available -eq 0 ]; then
            echo "Old and new Dom0 files are not consistent"
            exit 1
        fi
	done

    return 0
}

create_dom0_blob() {
	old_artifactory=$1
	new_artifactory=$2
	image_path=$3

	old_files=`list_dom0_artifacts $old_artifactory`
	new_files=`list_dom0_artifacts $new_artifactory`

	echo "Dom0 old files: \n$old_files"
	echo "Dom0 new files: \n$new_files"

	dom0_artifacts_is_differ "$old_files" "$new_files"

	if [ $? -eq 1 ]; then
	    make_dom0_blob $image_path 256 ext4 "$new_files"
        return 1
	fi

    return 0
}
