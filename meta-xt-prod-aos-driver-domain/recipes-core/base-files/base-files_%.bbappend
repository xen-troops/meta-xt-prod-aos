
# Append domain name
hostname .= "-domd"

do_install_append () {
	sed -i '/PATH="/a PATH="$PATH:${libdir}/xen/scripts}"' ${D}${sysconfdir}/profile
	echo "if [[ -z \${SSH_CONNECTION} ]] ; then" >> ${D}${sysconfdir}/profile
	echo "	shopt -s checkwinsize" >> ${D}${sysconfdir}/profile
	echo "  resize 1> /dev/null" >> ${D}${sysconfdir}/profile
	echo "fi" >> ${D}${sysconfdir}/profile
}
