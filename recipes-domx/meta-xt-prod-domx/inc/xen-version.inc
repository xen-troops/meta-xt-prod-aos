
################################################################################
# Following inc file defines XEN version and needed glue info to get it
# built with the current yocto version
################################################################################
#require recipes-extended/xen/xen-4.13-thud.inc
require recipes-extended/xen/xen-4.12-rocko.inc
SRC_URI = "git://github.com/xen-troops/xen.git;protocol=https;branch=master"

#SRC_URI = "git://github.com/xen-troops/xen.git;protocol=https;branch=xen-4.13rc-migration"
