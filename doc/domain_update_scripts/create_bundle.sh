#!/bin/sh

. "$(dirname "$0")/dom0_update.sh"
. "$(dirname "$0")/rootfs_full.sh"
. "$(dirname "$0")/rootfs_incremental.sh"

usage() {
    echo "./$(basename $0)"
    echo ""
    echo "\t--old_dir=<path>"
    echo "\t--new_dir=<path>"
    echo "\t--staging_dir=<path>"
    echo "\t--update_dir=<path>"
    echo "\t--dom0_update=full/incremental"
    echo "\t--domd_update=full/incremental"
    echo "\t--domu_update=full/incremental"
    echo ""
    echo "When current script will be completed, update_dir will consist update artifacts and update bundle"
}

# json

end_of_main_json() {
	json_dir=$1
	cat >> $json_dir/metadata.json << EOF
    ]
}
EOF
}

append_update_item_json() {
    json_fir=$1
    base_dir=$2
    type=$3

    cat >> $json_fir/metadata.json << EOF
    {
        "type": "${type}",
        "path": "./${base_dir}"
    },
EOF
}

main_update_header_json() {
	json_dir=$1

	cat > $json_dir/metadata.json << EOF
{
    "platformId": "AOS-OTA",
    "bundleVersion": "v1.0 01-09-2020",
    "bundleDescription": "MultiDomain update",
    "updateItems": [
EOF
}

add_rootfs_child_json_file() {
    version=$1
    target=$2
    update_type=$3
    json_dir=$4
    resource=$5

    cat > $json_dir/metadata.json << EOF
    {
        "version": $version,
        "description": "${target} update rootfs",
        "componentType": "${target}",
        "updateType": "${update_type}",
        "resources": "./${resource}"
    }
EOF
}

# --- json

compress_tar_gzip() {
	src_dir=$1
	tar_file=$2

    cd $src_dir

    if [ "$src_dir" = "$(dirname $tar_file)" ]; then
        name=$(basename $tar_file)
        touch $name
	    tar -czvf ./$name --exclude=$name *
    else
        tar -czvf $tar_file *
    fi
}

# --- Main
dom0_update_file=boot.img
domd_update_file=update.sqs
domu_update_file=update.sqs

dom0_update_dir=dom0_update
domd_update_dir=domd_update
domu_update_dir=domu_update

dom0_update_file_path=$dom0_update_dir/$dom0_update_file
domd_update_file_path=$domd_update_dir/$domd_update_file
domu_update_file_path=$domu_update_dir/$domu_update_file

old_dir=""
new_dir=""
staging_dir=""
update_dir=""
dom0_update=""
domd_update=""
domu_update=""

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --old_dir)
            old_artifactory_dir=$VALUE
            ;;
        --new_dir)
            new_artifactory_dir=$VALUE
            ;;
        --staging_dir)
            staging_dir=$VALUE
            ;;
        --update_dir)
            update_dir=$VALUE
            ;;
        --dom0_update)
            dom0_update=$VALUE
            ;;
        --domd_update)
            domd_update=$VALUE
            ;;
        --domu_update)
            domu_update=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

if [ -z "$old_artifactory_dir" ] || [ -z "$new_artifactory_dir" ]; then
    echo "Need to define new and old artifacory dirs"
    exit 1
fi

if [ -z "$dom0_update" ] && [ -z "$domd_update" ] && [ -z "$domu_update" ]; then
    echo "Upgrade type not defined. Use --help for datailed info about using this script"
    exit 1
fi

echo "Create update bundle"
echo "Old artifactory dir: $old_artifactory_dir"
echo "New artifactory dir: $new_artifactory_dir"
echo "Staging dir: $staging_dir"
echo "Update dir: $update_dir"

echo "Dom0 update type: $dom0_update"
echo "DomD update type: $domd_update"
echo "DomU update type: $domu_update"

rm -rf $staging_dir
rm -rf $update_dir
mkdir -p $update_dir
mkdir -p $staging_dir

# Create header of main json
main_update_header_json $update_dir

if [ "$dom0_update" = "full" ]; then
    echo "Create Dom0 update at $update_dir/$dom0_update_file_path"
    mkdir -p $(dirname $update_dir/$dom0_update_file_path)

    create_dom0_blob $old_artifactory_dir $new_artifactory_dir $update_dir/$dom0_update_file_path

    if [ $? -eq 1 ]; then
	    append_update_item_json $update_dir $dom0_update_dir dom0
	    add_rootfs_child_json_file 1 dom0 full $update_dir/$dom0_update_dir $dom0_update_file
    else
	    echo "Dom0 artifacts are same. No need to create a new update"
    fi
fi

if [ "$domd_update" = "full" ]; then
    echo "Create DomD full update at $update_dir/$domd_update_file_path"
    mkdir -p $(dirname $update_dir/$domd_update_file_path)

    prepare_full_rootfs_update $old_artifactory_dir $new_artifactory_dir $staging_dir $update_dir/$domd_update_file_path domd

    if [ $? -eq 1 ]; then
	    append_update_item_json $update_dir $domd_update_dir rootfs
	    add_rootfs_child_json_file 1 domd full $update_dir/$domd_update_dir $domd_update_file
    else
	    echo "DomD artifacts are same. No need to create a new update"
    fi
elif [ "$domd_update" = "incremental" ]; then
    echo "Create DomD incremental update at $update_dir/$domd_update_file_path"
    mkdir -p $(dirname $update_dir/$domd_update_file_path)

    create_squashfs_incremental_rootfs $old_artifactory_dir $new_artifactory_dir $staging_dir $update_dir/$domd_update_file_path domd

    if [ $? -eq 1 ]; then
	    append_update_item_json $update_dir $domd_update_dir rootfs
	    add_rootfs_child_json_file 1 domd incremental $update_dir/$domd_update_dir $domd_update_file
    else
	    echo "DomD artifacts are same. No need to create a new update"
    fi
fi

if [ "$domu_update" = "full" ]; then
    echo "Create DomU full update at $update_dir/$domu_update_file_path"
    mkdir -p $(dirname $update_dir/$domu_update_file_path)

    prepare_full_rootfs_update $old_artifactory_dir $new_artifactory_dir $staging_dir $update_dir/$domu_update_file_path domu

    if [ $? -eq 1 ]; then
	    append_update_item_json $update_dir $domu_update_dir rootfs
	    add_rootfs_child_json_file 1 domu full $update_dir/$domu_update_dir $domu_update_file
    else
	    echo "DomU artifacts are same. No need to create a new update"
    fi
elif [ "$domu_update" = "incremental" ]; then
    echo "Create DomU incremental update at $update_dir/$domu_update_file_path"
    mkdir -p $(dirname $update_dir/$domu_update_file_path)

    create_squashfs_incremental_rootfs $old_artifactory_dir $new_artifactory_dir $staging_dir $update_dir/$domu_update_file_path domu

    if [ $? -eq 1 ]; then
	    append_update_item_json $update_dir $domu_update_dir rootfs
	    add_rootfs_child_json_file 1 domu incremental $update_dir/$domu_update_dir $domu_update_file
    else
	    echo "DomU artifacts are same. No need to create a new update"
    fi
fi

end_of_main_json $update_dir

compress_tar_gzip $update_dir $update_dir/update.tar.gz

rm -rf $staging_dir
