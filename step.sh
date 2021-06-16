#!/bin/bash

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#=======================================
# Functions
#=======================================

RESTORE='\033[0m'
RED='\033[00;31m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
GREEN='\033[00;32m'

function color_echo {
    color=$1
    msg=$2
    echo -e "${color}${msg}${RESTORE}"
}

function echo_fail {
    msg=$1
    echo
    color_echo "${RED}" "${msg}"
    exit 1
}

function echo_warn {
    msg=$1
    color_echo "${YELLOW}" "${msg}"
}

function echo_info {
    msg=$1
    echo
    color_echo "${BLUE}" "${msg}"
}

function echo_details {
    msg=$1
    echo "  ${msg}"
}

function echo_done {
    msg=$1
    color_echo "${GREEN}" "  ${msg}"
}

function validate_required_input {
    key=$1
    value=$2
    if [ -z "${value}" ] ; then
        echo_fail "Missing required input: ${key}"
    fi
}

function validate_required_input_with_options {
    key=$1
    value=$2
    options=$3

    validate_required_input "${key}" "${value}"

    found="0"
    for option in "${options[@]}" ; do
        if [ "${option}" == "${value}" ] ; then
            found="1"
        fi
    done

    if [ "${found}" == "0" ] ; then
        echo_fail "Invalid input: (${key}) value: (${value}), valid options: ($( IFS=$", "; echo "${options[*]}" ))"
    fi
}


#=======================================
# Main
#=======================================

sandbox_cmd=""
#
# Validate parameters
echo_info "Configs:"
echo_details "* veracode_api_id: ***"
echo_details "* veracode_api_secret: ***"
echo_details "* veracode_app_name: $veracode_app_name"
echo_details "* version: $veracode_app_version"

if [ "${veracode_sandbox}" ] ; then
    echo_details "* veracode_sandbox: $veracode_sandbox"
fi

if [ "${ios_archive}" ] ; then
    echo_details "* ios_archive: $ios_archive"
fi

echo_details "* file_upload_path: $file_upload_path"
echo_details "* auto_scan: $auto_scan"

if [ ! -z "${file_upload_path}" ] ; then

    if [ "${ios_archive}" ] ; then
        if [ ! -d "${ios_archive}" ] ; then
            echo_fail "Archive path defined but the directory does not exist at path: ${ios_archive}"
        fi

        echo echo_info "Preparing iOS Archive..."
        zip -r $file_upload_path $ios_archive/
    fi

    validate_required_input "veracode_api_id" $veracode_api_id
    validate_required_input "veracode_api_secret" $veracode_api_secret
    validate_required_input "veracode_app_name" $veracode_app_name

    if [ "${veracode_sandbox}" ] ; then
        validate_required_input "veracode_sandbox" $veracode_sandbox
        sandbox_cmd="-createsandbox true -sandboxname ${veracode_sandbox}"
    fi
    
    validate_required_input "auto_scan" $auto_scan

    if [ ! -f "${file_upload_path}" ] ; then
        echo_fail "File path defined but the file does not exist at path: ${file_upload_path}"
    fi
fi

if [ ! -z "${file_upload_path}" ] ; then
# - Submit File
    echo echo_info "Uploading File To Veracode..."
    echo
    java -jar $BITRISE_STEP_SOURCE_DIR/Veracode/API.jar -vid ${veracode_api_id} -vkey ${veracode_api_secret} -createprofile false -action uploadandscan -appname ${veracode_app_name} -version ${veracode_app_version} ${sandbox_cmd} -autoscan ${auto_scan} -filepath ${file_upload_path}

    [ $? -eq 0 ] && echo_done "Success" || echo_fail "Failed"
fi
