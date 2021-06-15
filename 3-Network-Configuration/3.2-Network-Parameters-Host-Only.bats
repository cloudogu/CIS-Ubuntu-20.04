#!/usr/bin/env bats

load IPv6-helper

@test "3.2.1 Ensure packet redirect sending is disabled (Automated)" {
    run bash -c "sysctl net.ipv4.conf.all.send_redirects"
    [ "$status" -eq 0 ]
    [ "$output" = "net.ipv4.conf.all.send_redirects = 0" ]
    run bash -c "sysctl net.ipv4.conf.default.send_redirects"
    [ "$status" -eq 0 ]
    [ "$output" = "net.ipv4.conf.default.send_redirects = 0" ]
    run bash -c "grep \"net\.ipv4\.conf\.all\.send_redirects\" /etc/sysctl.conf /etc/sysctl.d/*"
    [ "$status" -eq 0 ]
    # Check if the desired output line is active in any of the conf files
    local CONF_FILE_CORRECT=0
    while IFS= read -r line; do
        if [[ "$line" == *":net.ipv4.conf.all.send_redirects = 0" ]]; then
            CONF_FILE_CORRECT=1
        fi
    done <<< "$output"
    [ $CONF_FILE_CORRECT -eq 1 ]
    run bash -c "grep \"net\.ipv4\.conf\.default\.send_redirects\" /etc/sysctl.conf /etc/sysctl.d/*"
    [ "$status" -eq 0 ]
    # Check if the desired output line is active in any of the conf files
    local CONF_FILE_CORRECT=0
    while IFS= read -r line; do
        if [[ "$line" == *":net.ipv4.conf.default.send_redirects = 0" ]]; then
            CONF_FILE_CORRECT=1
        fi
    done <<< "$output"
    [ $CONF_FILE_CORRECT -eq 1 ]
}

@test "3.2.2 Ensure IP forwarding is disabled (Automated)" {
    # IPv4
    run bash -c "sysctl net.ipv4.ip_forward"
    [ "$status" -eq 0 ]
    [ "$output" = "net.ipv4.ip_forward = 0" ]
    run bash -c "grep -E -s \"^\s*net\.ipv4\.ip_forward\s*=\s*1\" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf"
    [ "$status" -ne 0 ]
    [ "$output" = "" ]
    # IPv6
    run check_ip_v6
    [ "$status" -eq 0 ]
    if [[ "$output" == *"*** IPv6 is enabled on the system ***"* ]]; then
        run bash -c "sysctl net.ipv6.conf.all.forwarding"
        [ "$status" -eq 0 ]
        [ "$output" = "net.ipv6.conf.all.forwarding = 0" ]
        run bash -c "grep -E -s \"^\s*net\.ipv6\.conf\.all\.forwarding\s*=\s*1\" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf"
        [ "$status" -ne 0 ]
        [ "$output" = "" ]
    fi
}
