FILESEXTRAPATHS_prepend := "${THISDIR}/optee-os:"

LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=c1f21c4f72f372ef38a5a4aee55ec173"

SRC_URI += " \
    file://0001-ta-pkcs11-Add-RSA-key-pair-generation-support.patch \
    file://0002-ta-pkcs11-Add-support-for-RSA-signing-verification.patch \
    file://0003-ta-pkcs11-Add-support-for-RSA-PSS-signing-verificati.patch \
    file://0004-ta-pkcs11-Add-support-for-RSA-OAEP-encryption-decryp.patch \
    file://0005-wip-fix-rsa-public-key-import.patch \
    file://0006-ta-pkcs11-Add-certificate-object-support.patch \
    file://0007-wip-ecdh.patch \
    file://0008-wip-checkpatch.patch \
    file://0009-ta-pkcs11-Add-support-to-generate-optional-attribute.patch \
    file://0010-wip-key-size-check-for-rsa-pss.patch \
"

SRCREV = "bc9618c0b6e6585ada3efcab4ce5ba155507d777"

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