#!/bin/bash

cat /var/version && echo ""
set -eux

if [ -z "$SOURCE" ]; then
  echo "No source was provided."
  echo "Please provide pivnet, s3, gcs, or azure."
  exit 1
fi

vars_files_args=("")
for vf in ${VARS_FILES}
do
  vars_files_args+=("--vars-file ${vf}")
done

om interpolate \
   --config config/"${CONFIG_FILE}" \
   --path /name="${SOURCE}/params" \
   > ${SOURCE}.yml

om interpolate \
   --config config/"${CONFIG_FILE}" \
   --path /name="${TARGET}/params" \
   > ${TARGET}.yml

# ${vars_files_args[@] needs to be globbed to pass through properly
echo "Downloading product from ${SOURCE}"
# shellcheck disable=SC2068
om download-product \
   --config "${SOURCE}".yml ${vars_files_args[@]} \
   --output-directory downloaded-files \
   --source "$SOURCE"

{ printf "\nReading product details..."; } 2> /dev/null
# shellcheck disable=SC2068
product_slug=$(om interpolate \
  --config "${SOURCE}".yml ${vars_files_args[@]} \
  --path /pivnet-product-slug)

product_file=$(om interpolate \
  --config downloaded-files/download-file.json \
  --path /product_path)

stemcell_file=$(om interpolate \
  --config downloaded-files/download-file.json \
  --path /stemcell_path?)

{ printf "\nChecking if product needs winfs injected..."; } 2> /dev/null
if [ "$product_slug" == "pas-windows" ] && [ "$SOURCE" == "pivnet" ]; then
  TILE_FILENAME="$(basename "$product_file")"

  # The winfs-injector determines the necessary windows image,
  # and uses the CF-foundation dockerhub repo
  # to pull the appropriate Microsoft-hosted foreign layer.
  winfs-injector \
  --input-tile "$product_file" \
  --output-tile "downloaded-product/${TILE_FILENAME}"

  product_file="downloaded-product/${TILE_FILENAME}"  
fi

echo "uploading product to ${TARGET}"
om --env env/"${ENV_FILE}" upload-product \
  --product $product_file

if [ -e "$stemcell_file" ]; then

  export OPTIONAL_CONFIG_FLAG=""
  if [ -e downloaded-files/assign-stemcell.yml ]; then
    export OPTIONAL_CONFIG_FLAG="--config downloaded-files/config.yml"
  fi

  echo "uploading stemcell to ${TARGET}"
  om --env env/"${ENV_FILE}" upload-stemcell \
   --floating="$FLOATING_STEMCELL" \
   --stemcell=$stemcell_file \
   $OPTIONAL_CONFIG_FLAG
fi