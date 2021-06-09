FILESEXTRAPATHS_prepend := "${THISDIR}/optee-os:"

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

do_install() {
    install -d ${D}${nonarch_base_libdir}/optee_armtz/

    # Install PKCS11 TA
    install -m 0644 ${B}/out/arm-plat-${OPTEEMACHINE}/ta/pkcs11/*.ta ${D}${nonarch_base_libdir}/optee_armtz/
}
