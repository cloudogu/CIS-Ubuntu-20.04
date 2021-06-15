#!/usr/bin/env bats

load 3.1-helper
load 3.1.2

@test "3.1.1 Disable IPv6 (Manual)" {
    run check_ipv6_is_disabled_via_grub_config
    if [ "$status" -eq 1 ]; then
        run bash -c "sysctl net.ipv6.conf.all.disable_ipv6"
        [ "$output" = "net.ipv6.conf.all.disable_ipv6 = 1" ]

        run bash -c "sysctl net.ipv6.conf.default.disable_ipv6"
        [ "$output" = "net.ipv6.conf.default.disable_ipv6 = 1" ]

        run bash -c "grep -E '^\s*net\.ipv6\.conf\.(all|default)\.disable_ipv6\s*=\s*1\b(\s+#.*)?$' /etc/sysctl.conf /etc/sysctl.d/*.conf | cut -d: -f2"
        [ "$output" = *"net.ipv6.conf.all.disable_ipv6 = 1"* ]
        [ "$output" = *"net.ipv6.conf.default.disable_ipv6 = 1"* ]
    fi
}

@test "3.1.2 Ensure wireless interfaces are disabled (Automated)" {
    run test_3_1_2
    [ "$output" = "Wireless is not enabled" ]
}
