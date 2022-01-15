#!/bin/bash -e

required_env_vars=(
    "SUBSCRIPTION_ID"
    "AZURE_RESOURCE_GROUP_NAME"
    "AZURE_LOCATION"
)

for v in "${required_env_vars[@]}"
do
    if [ -z "${!v}" ]; then
        echo "$v was not set!"
        exit 1
    fi
done

pwd
cat ./vhdbuilder/packer/settings.json
ARM64_OS_DISK_SNAPSHOT_NAME="$(cat ./vhdbuilder/packer/settings.json | grep "arm64_os_disk_snapshot_name" | awk -F':' '{print $2}' | awk -F'"' '{print $2}')"
CREATE_TIME="$(cat ./vhdbuilder/packer/settings.json | grep "create_time" | awk -F':' '{print $2}' | awk -F'"' '{print $2}')"
SIG_IMAGE_NAME="$(cat vhdbuilder/packer/settings.json | grep "sig_image_name" | awk -F':' '{print $2}' | awk -F'"' '{print $2}')" && \
echo CREATE_TIME=${CREATE_TIME}
echo ARM64_OS_DISK_SNAPSHOT_NAME=${ARM64_OS_DISK_SNAPSHOT_NAME}
echo SIG_IMAGE_NAME=${SIG_IMAGE_NAME}

disk_snapshot_id="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${AZURE_RESOURCE_GROUP_NAME}/providers/Microsoft.Compute/snapshots/${ARM64_OS_DISK_SNAPSHOT_NAME}"

az sig image-version create --location $AZURE_LOCATION --resource-group ${AZURE_RESOURCE_GROUP_NAME} --gallery-name PackerSigGalleryEastUS \
     --gallery-image-definition ${SIG_IMAGE_NAME} --gallery-image-version 1.0.${CREATE_TIME} \
     --os-snapshot ${disk_snapshot_id}
