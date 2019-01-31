require ../agl/inc/domd-agl-image.inc

SRC_URI_remove_rcar = " \
    git://git@gitpct.epam.com/epmd-aepr/img-proprietary;protocol=ssh;branch=master;name=img-proprietary;destsuffix=repo/proprietary \
"

configure_versions_rcar() {
    local local_conf="${S}/build/conf/local.conf"

    cd ${S}
    base_update_conf_value ${local_conf} PREFERRED_VERSION_xen "4.10.0+git\%"
    base_update_conf_value ${local_conf} PREFERRED_VERSION_u-boot_rcar "v2015.04\%"
    base_update_conf_value ${local_conf} PREFERRED_VERSION_linux-renesas "4.14.35+git\%"
    base_update_conf_value ${local_conf} PREFERRED_VERSION_linux-libc-headers "4.14.35+git\%"
    
    # Disable shared link for GO packages
    base_set_conf_value ${local_conf} GO_LINKSHARED ""

    base_set_conf_value ${local_conf} DISTRO_FEATURES_remove "h264dec_lib h264enc_lib aaclcdec_lib aaclcdec_mdw"
    base_set_conf_value ${local_conf} MACHINE_FEATURES_remove "gsx"

    # override console specified by default by the meta-rcar-gen3
    # to be hypervisor's one
    base_update_conf_value ${local_conf} SERIAL_CONSOLE "115200 hvc0"

    # set default timezone to Las Vegas
    base_update_conf_value ${local_conf} DEFAULT_TIMEZONE "US/Pacific"

    base_update_conf_value ${local_conf} XT_GUESTS_INSTALL "${XT_GUESTS_INSTALL}"

    # U-boot/IPL option for H3 (SoC: r8a7795)
    # For H3 SiP DDR 4GiB (1GiB x 4ch)
    #H3_OPTION = "0"
    # For H3 SiP DDR 8GiB (2GiB x 4ch)
    #H3_OPTION = "1"
    # For H3 SiP DDR 4GiB (2GiB x 2ch)
    #H3_OPTION = "2"
    if [ "${MACHINE}" == "salvator-xs-h3" ] || [ "${MACHINE}" == "salvator-x-h3" ];then
        base_set_conf_value ${local_conf} H3_OPTION "0"
    fi
    if [ "${MACHINE}" == "salvator-xs-h3-4x2g" ] || [ "${MACHINE}" == "salvator-x-h3-4x2g" ];then
        base_set_conf_value ${local_conf} H3_OPTION "1"
    fi
    if [ "${MACHINE}" == "salvator-xs-h3-2x2g" ] || [ "${MACHINE}" == "salvator-x-h3-2x2g" ];then
        base_set_conf_value ${local_conf} H3_OPTION "2"
    fi
}

python do_configure_append_rcar() {
    bb.build.exec_func("configure_versions_rcar", d)
}

