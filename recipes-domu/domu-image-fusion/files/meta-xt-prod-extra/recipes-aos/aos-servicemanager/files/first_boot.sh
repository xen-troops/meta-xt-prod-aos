#!/bin/sh

echo "Start first boot script"

# Enable quotas

echo "Enable disk quotas"

quotacheck -avum && quotaon -avu

<<<<<<< HEAD
# Update certificates

echo "Update certificates"

update-ca-certificates

=======
>>>>>>> 124a3d3... domf: add first boot script into aos-servicemanager
# Disable first boot service
systemctl disable first_boot.service
