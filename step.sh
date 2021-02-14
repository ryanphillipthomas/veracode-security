#!/bin/bash
set -ex

#!/usr/bin/env bash
echo "Uploading File: ${file_upload_path} for App ID: ${veracode_app_id}"
java -jar $BITRISE_STEP_SOURCE_DIR/VeracodeJavaAPI.jar -vid ${veracode_api_id} -vkey ${veracode_api_secret} -action uploadfile -appid ${veracode_app_id} -filepath ${file_upload_path}

echo "Running Prescan for App ID: ${veracode_app_id} with Auto Scan: ${auto_scan}"
java -jar $BITRISE_STEP_SOURCE_DIR/VeracodeJavaAPI.jar -vid ${veracode_api_id} -vkey ${veracode_api_secret} -action beginprescan -appid ${veracode_app_id} -autoscan ${auto_scan}
