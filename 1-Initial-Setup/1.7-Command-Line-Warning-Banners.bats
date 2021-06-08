#!/usr/bin/env bats

@test "1.7.1 Ensure message of the day is configured properly (Automated)" {
    release=$(grep '^ID=' /etc/os-release | cut -d= -f2 | sed -e 's/"//g')
    run bash -c "grep -Eis \"(\\\v|\\\r|\\\m|\\\s|${release})\" /etc/motd"
    [ "$status" -eq 1 ]
}

@test "1.7.2 Ensure local login warning banner is configured properly (Automated)" {
    release=$(grep '^ID=' /etc/os-release | cut -d= -f2 | sed -e 's/"//g')
    run bash -c "grep -Eis \"(\\\v|\\\r|\\\m|\\\s|${release})\" /etc/issue"
    [ "$status" -eq 1 ]
}

@test "1.7.3 Ensure remote login warning banner is configured properly (Automated)" {
    release=$(grep '^ID=' /etc/os-release | cut -d= -f2 | sed -e 's/"//g')
    run bash -c "grep -Eis \"(\\\v|\\\r|\\\m|\\\s|${release})\" /etc/issue.net"
    [ "$status" -eq 1 ]
}

@test "1.7.4 Ensure permissions on /etc/motd are configured (Automated)" {
    (stat -L /etc/motd | grep -E "Uid: \([[:space:]]+0/[[:space:]]+root\)")
    (stat -L /etc/motd | grep -E "Gid: \([[:space:]]+0/[[:space:]]+root\)")
    (stat -L /etc/motd | grep "Access: (0644/")
}

@test "1.7.5 Ensure permissions on /etc/issue are configured (Automated)" {
    (stat /etc/issue | grep -E "Uid: \([[:space:]]+0/[[:space:]]+root\)")
    (stat /etc/issue | grep -E "Gid: \([[:space:]]+0/[[:space:]]+root\)")
    (stat /etc/issue | grep "Access: (0644/")
}

@test "1.7.6 Ensure permissions on /etc/issue.net are configured (Automated)" {
    (stat /etc/issue.net | grep -E "Uid: \([[:space:]]+0/[[:space:]]+root\)")
    (stat /etc/issue.net | grep -E "Gid: \([[:space:]]+0/[[:space:]]+root\)")
    (stat /etc/issue.net | grep "Access: (0644/")
}
