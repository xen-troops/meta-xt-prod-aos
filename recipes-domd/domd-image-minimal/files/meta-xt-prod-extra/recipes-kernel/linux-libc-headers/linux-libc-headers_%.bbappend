RENESAS_BSP_URL = "git://github.com/xen-troops/linux.git"

SRC_URI = "${RENESAS_BSP_URL};protocol=https;branch=${BRANCH}"

BRANCH = "master"
SRCREV = "${AUTOREV}"
LINUX_VERSION = "4.14.75"
