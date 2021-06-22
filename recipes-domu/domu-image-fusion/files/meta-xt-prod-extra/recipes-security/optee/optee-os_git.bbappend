FILESEXTRAPATHS_prepend := "${THISDIR}/optee-os:"

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
    file://0011-ta-pkcs11-Increate-data-size-from-64k-to-256k.patch \
"

SRCREV = "bc9618c0b6e6585ada3efcab4ce5ba155507d777"

PV = "git${SRCPV}"

inherit python3native

DEPENDS_append = " python3-pycryptodome-native"
DEPENDS_remove = " python3-pycrypto-native"

OPTEEMACHINE = "vexpress"
OPTEEFLAVOR = "qemu_armv8a"

EXTRA_OEMAKE += " \
    PLATFORM_FLAVOR=${OPTEEFLAVOR} \
    CFG_VIRTUALIZATION=y \
    CFG_SYSTEM_PTA=y \
    CFG_ASN1_PARSER=y \
    CFG_CORE_MBEDTLS_MPI=y \
"

FILES_${PN} = " \
    ${nonarch_base_libdir} \
"

do_deploy[noexec] = "1"

do_compile() {
    unset LDFLAGS
    oe_runmake all
}

do_install() {
    install -d ${D}${nonarch_base_libdir}/optee_armtz/

    # Install PKCS11 TA
    install -m 0644 ${B}/out/arm-plat-${OPTEEMACHINE}/ta/pkcs11/*.ta ${D}${nonarch_base_libdir}/optee_armtz/
}
