#!/usr/bin/env bats

@test "4.4 Ensure logrotate assigns appropriate permissions (Automated)" {
    run bash -c "grep -Es \"^\s*create\s+\S+\" /etc/logrotate.conf /etc/logrotate.d/* | grep -E -v \"\s(0)?[0-6][04]0\s\""
    [ "$status" -eq 1 ]
    [[ "$output" == "" ]]
}
