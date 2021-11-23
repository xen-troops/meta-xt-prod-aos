DESCRIPTION = "libxenbe"
SECTION = "libs"
LICENSE = "GPLv2"
PR = "r0"

DEPENDS = "xen"

SRCREV_rcar = "683e65ebc2e4738466cb0437460ba7c61afe2f92"

SRC_URI_append_rcar = " git://github.com/xen-troops/libxenbe.git;protocol=https;branch=master"

LIC_FILES_CHKSUM = "file://LICENSE;md5=a23a74b3f4caf9616230789d94217acb"

S = "${WORKDIR}/git"

# Followig two lines are workaround to fix issue reflected as
# "QA Issue: -dev package contains non-symlink .so:"
# TODO: the proper solution should be analyzed in future
FILES_SOLIBSDEV = ""
FILES_${PN} += "${libdir}/*.so"

inherit pkgconfig cmake
