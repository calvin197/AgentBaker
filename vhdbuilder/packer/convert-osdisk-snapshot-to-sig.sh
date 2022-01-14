#!/bin/bash -e

required_env_vars=(
    "SUBSCRIPTION_ID"
    "AZURE_RESOURCE_GROUP_NAME"
    "CREATE_TIME"
    "AZURE_LOCATION"
    "SIG_IMAGE_NAME"
    "ARM64_OS_DISK_SNAPSHOT_NAME"
)

for v in "${required_env_vars[@]}"
do
    if [ -z "${!v}" ]; then
        echo "$v was not set!"
        exit 1
    fi
done

disk_snapshot_id="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${AZURE_RESOURCE_GROUP_NAME}/providers/Microsoft.Compute/snapshots/${ARM64_OS_DISK_SNAPSHOT_NAME}"

az sig image-version create --location $AZURE_LOCATION --resource-group ${AZURE_RESOURCE_GROUP_NAME} --gallery-name PackerSigGalleryEastUS \
     --gallery-image-definition ${SIG_IMAGE_NAME} --gallery-image-version 1.0.${CREATE_TIME} \
     --os-snapshot ${disk_snapshot_id}