FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "\
    file://0001-ARM-rcar_gen3-Add-R8A7795-8GiB-RAM-Salvator-X-board-.patch \
    file://0001-Revert-net-ravb-Fix-stop-RAVB-module-clock-before-OS.patch \
    file://0001-r8a7795_ulcb_defconfig-Disable-CONFIG_MMC_HS400_SUPP.patch \
"