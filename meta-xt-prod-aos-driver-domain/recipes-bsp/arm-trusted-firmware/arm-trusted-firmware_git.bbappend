FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

ATFW_OPT_LOSSY_remove = "${@oe.utils.conditional("USE_MULTIMEDIA", "1", "RCAR_LOSSY_ENABLE=1", "", d)}"
ATFW_OPT_LOSSY = "RCAR_LOSSY_ENABLE=0"
ADDITIONAL_ATFW_OPT ??= ""

SRC_URI_remove = "0003-rcar-Add-BOARD_SALVATOR_X-case-in-ddr_rank_judge.patch"

SRC_URI += " \
    file://0001-rcar-Use-UART-instead-of-Secure-DRAM-area-for-loggin.patch \
    file://0002-tools-Produce-two-cert_header_sa6-images.patch \
"

ido_ipl_opt_compile_rcar () {
    oe_runmake distclean
    oe_runmake bl2 bl31 dummytool PLAT=${PLATFORM} ${EXTRA_ATFW_OPT} ${ATFW_OPT_LOSSY} ${ADDITIONAL_ATFW_OPT}
}

do_compile_rcar() {
    oe_runmake distclean
    oe_runmake bl2 bl31 dummytool PLAT=${PLATFORM} ${ATFW_OPT} ${ADDITIONAL_ATFW_OPT}
}

do_deploy_append () {
    install -m 0644 ${S}/tools/dummy_create/bootparam_sa0.bin ${DEPLOYDIR}/bootparam_sa0.bin
    install -m 0644 ${S}/tools/dummy_create/cert_header_sa6.bin ${DEPLOYDIR}/cert_header_sa6.bin
    install -m 0644 ${S}/tools/dummy_create/cert_header_sa6_emmc.bin ${DEPLOYDIR}/cert_header_sa6_emmc.bin
    install -m 0644 ${S}/tools/dummy_create/cert_header_sa6_emmc.srec ${DEPLOYDIR}/cert_header_sa6_emmc.srec
}

