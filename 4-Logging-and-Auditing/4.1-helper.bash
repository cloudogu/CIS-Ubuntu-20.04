#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

function get_uid_min() {
    # check for custom UID_MIN
    # the default value is 1000 but in some environments it might be customized
    echo "$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"
}