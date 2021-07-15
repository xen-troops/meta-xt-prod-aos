FILESEXTRAPATHS_prepend := "${THISDIR}/optee-os:"

LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=c1f21c4f72f372ef38a5a4aee55ec173"

SRCREV = "dcec4b70f34a387ec0445728295873f19fab6e35"

PV = "git${SRCPV}"

inherit python3native

DEPENDS_append = " python3-pycryptodome-native python3-pyelftools-native"
DEPENDS_remove = " python-pycrypto-native"

OPTEEMACHINE = "rcar"
OPTEEOUTPUTMACHINE = "rcar"

OPTEEFLAVOR_salvator-xs-m3n-xt = "salvator_m3n"

OPTEEFLAVOR_m3ulcb-xt = "salvator_m3"
OPTEEFLAVOR_salvator-x-m3-xt = "salvator_m3"

OPTEEFLAVOR_h3ulcb-xt = "salvator_h3"
OPTEEFLAVOR_h3ulcb-cb-xt = "salvator_h3"

OPTEEFLAVOR_salvator-x-h3-xt = "salvator_h3"
OPTEEFLAVOR_salvator-xs-h3-xt = "salvator_h3"

OPTEEFLAVOR_salvator-x-h3-4x2g-xt = "salvator_h3_4x2g"
OPTEEFLAVOR_salvator-xs-h3-4x2g-xt = "salvator_h3_4x2g"
OPTEEFLAVOR_h3ulcb-4x2g-xt = "salvator_h3_4x2g"
OPTEEFLAVOR_h3ulcb-4x2g-kf-xt = "salvator_h3_4x2g"
OPTEEFLAVOR_salvator-xs-m3-2x4g-xt = "salvator_m3_2x4g"

EXTRA_OEMAKE += " \
    PLATFORM_FLAVOR=${OPTEEFLAVOR} \
    CFG_VIRTUALIZATION=y \
    CFG_SYSTEM_PTA=y \
    CFG_ASN1_PARSER=y \
    CFG_CORE_MBEDTLS_MPI=y \
"

do_deploy() {
    # Create deploy folder
    install -d ${DEPLOYDIR}

    # Copy TEE OS to deploy folder
    install -m 0644 ${S}/out/arm-plat-${OPTEEMACHINE}/core/tee.elf ${DEPLOYDIR}/tee-${MACHINE}.elf
    install -m 0644 ${S}/out/arm-plat-${OPTEEMACHINE}/core/tee.bin ${DEPLOYDIR}/tee-${MACHINE}.bin
    install -m 0644 ${S}/out/arm-plat-${OPTEEMACHINE}/core/tee.srec ${DEPLOYDIR}/tee-${MACHINE}.srec
    install -m 0644 ${S}/out/arm-plat-${OPTEEMACHINE}/core/tee-raw.bin ${DEPLOYDIR}/tee_raw-${MACHINE}.bin
}
