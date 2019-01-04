#!/bin/sh

echo "Start first boot script"

# Enable quotas

echo "Enable disk quotas"

quotacheck -avum && quotaon -avu

# Update certificates

echo "Update certificates"

update-ca-certificates

# Disable first boot service
systemctl disable first_boot.service
