
################################################################################
# Following inc file defines XEN version and needed glue info to get it
# built with the current yocto version
################################################################################
require ../meta-xt-images-domx/recipes-extended/xen/xen-4.12-rocko.inc

<<<<<<< HEAD
# N.B. - nobranch: Don't check the SHA validation for branch. set this option
# for the recipe referring to commit which is valid in tag instead of branch.
SRC_URI = "git://github.com/xen-troops/xen.git;protocol=https;nobranch=1"
SRCREV = "RELEASE-4.10.0-xt0.6.final"
=======
SRC_URI = "git://github.com/xen-troops/xen.git;protocol=https;branch=master"
>>>>>>> 31c4ce1... dom0:domd:xen: Unify XEN version for Dom0 and DomD
