FILESEXTRAPATHS_prepend := "${THISDIR}/optee-client:"

SRC_URI += " \
    file://0001-libckteec-Add-RSA-support-for-C_GenerateKeyPair.patch \
    file://0002-libckteec-Add-PKCS-1-v1.5-RSA-signing-support.patch \
    file://0003-libckteec-Add-PKCS-1-RSA-PSS-signing-support.patch \
    file://0004-libckteec-Add-PKCS-1-RSA-OAEP-encryption-support.patch \
    file://0005-libckteec-Add-64-bit-sign-extension-support-for-dese.patch \
    file://0006-libckteec-Remove-pre-sanitization-for-mechanism-list.patch \
    file://0007-libckteec-fix-deserialization-for-CKA_ALLOWED_MECHAN.patch \
    file://0008-wip-rsa-pss-param-size-check.patch \
    file://0009-wip-rsa-oaep-size-check.patch \
"

SRCREV = "06e1b32f6a7028e039c625b07cfc25fda0c17d53"
PV = "git${SRCPV}"

EXTRA_OEMAKE = " \
    RPMB_EMU=0 \
    CFG_TEE_FS_PARENT_PATH=/var/aos/crypt/optee \
"

do_install_append() {
    install -D -p -m 0644 ${S}/out/export/usr/lib/libckteec.so.0.1 ${D}${libdir}/libckteec.so.0.1
    lnr ${D}${libdir}/libckteec.so.0.1 ${D}${libdir}/libckteec.so
    lnr ${D}${libdir}/libckteec.so.0.1 ${D}${libdir}/libckteec.so.0
}
