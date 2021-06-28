#!/bin/bash

function get_uid_min() {
    # check for custom UID_MIN
    # if it's not equal to 1000 it has to be used for the audit and remediation
    UID_MIN_FROM_CONFIG=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)

    UID_MIN=1000
    if [ "${UID_MIN_FROM_CONFIG}" -ne 1000 ]; then
      UID_MIN=UID_MIN_FROM_CONFIG
    fi
    echo "${UID_MIN}"
}