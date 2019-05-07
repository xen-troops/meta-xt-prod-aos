RENESAS_BSP_URL = "git://github.com/xen-troops/linux.git"

BRANCH = "v4.14/rcar-3.7-ctc"
SRCREV = "${AUTOREV}"
LINUX_VERSION = "4.14.75"
PV = "${LINUX_VERSION}+git${SRCPV}"
SRC_URI_remove = " \
    file://0001-soc-renesas-rcar-sysc-Update-power-control-flow-for-.patch \
    file://0002-soc-renesas-rcar-sysc-Add-SYSCEXTMASK-info-for-r8a77.patch \
    file://0003-soc-renesas-rcar-sysc-Add-SYSCEXTMASK-info-for-r8a77.patch \
    file://0004-soc-renesas-rcar-sysc-Add-SYSCEXTMASK-info-for-r8a77.patch \
    file://0005-soc-renesas-rcar-sysc-Add-SYSCEXTMASK-info-for-r8a77.patch \
    file://0006-soc-renesas-rcar-sysc-Add-SYSCEXTMASK-info-for-r8a77.patch \
"
