#!/usr/bin/env bats

load IPv6-helper

# 3.5.1 Configure UncomplicatedFirewall

@test "3.5.1.1 Ensure ufw is installed (Automated)" {
    [[ $(dpkg -s ufw | grep 'Status: install') == "Status: install ok installed" ]]
}

@test "3.5.1.2 Ensure iptables-persistent is not installed with ufw (Automated)" {
    run bash -c "dpkg-query -s iptables-persistent"
    [ $status -eq 1 ]
    [[ "$output" == *"package 'iptables-persistent' is not installed and no information is available"* ]]
}

@test "3.5.1.3 Ensure ufw service is enabled (Automated)" {
    [[ $(systemctl is-enabled ufw) == "enabled" ]]
    [[ $(ufw status | grep Status) == "Status: active" ]]
}

@test "3.5.1.4 Ensure ufw loopback traffic is configured (Automated)" {
    run bash -c "ufw status verbose"
    [ "$status" -eq 0 ]
    local check1=0 check2=0 check3=0 check4=0 check5=0 check6=0
    for index in ${!lines[*]}
    do
        current_line="${lines[$index]}"
        case "$current_line" in
            "Anywhere on lo"*"ALLOW IN"*"Anywhere"*) check1=1 ;;
            "Anywhere"*"DENY IN"*"127.0.0.0/8"*) check2=1 ;;
            "Anywhere (v6) on lo"*"ALLOW IN"*"Anywhere (v6)"*) check3=1 ;;
            "Anywhere (v6)"*"DENY IN"*"::1"*) check4=1 ;;
            "Anywhere"*"ALLOW OUT"*"Anywhere on lo"*) check5=1 ;;
            "Anywhere (v6)"*"ALLOW OUT"*"Anywhere (v6) on lo"*) check6=1 ;;
            *) ;;
        esac
    done
    [ $check1 -eq 1 ]
    [ $check2 -eq 1 ]
    [ $check3 -eq 1 ]
    [ $check4 -eq 1 ]
    [ $check5 -eq 1 ]
    [ $check6 -eq 1 ]
}

@test "3.5.1.5 Ensure ufw outbound connections are configured (Manual)" {
    skip "This audit has to be done manually"
}

@test "3.5.1.6 Ensure ufw firewall rules exist for all open ports (Manual)" {
    skip "This audit has to be done manually"
}

@test "3.5.1.7 Ensure ufw default deny firewall policy (Automated)" {
    run bash -c "ufw status verbose | grep -i default"
    [ "$status" -eq 0 ]
    [[ "$output" == *"deny (incoming)"* || "$output" == *"reject (incoming)"* ]]
    [[ "$output" == *"deny (outgoing)"* || "$output" == *"reject (outgoing)"* ]]
    [[ "$output" == *"deny (routed)"* \
     || "$output" == *"reject (routed)"* ]]
}

# 3.5.2 Configure nftables

@test "3.5.2.1 Ensure nftables is installed (Automated)" {
    run bash -c "dpkg-query -s nftables | grep 'Status: install ok installed'"
    [[ "$output" == "Status: install ok installed" ]]
}

@test "3.5.2.2 Ensure ufw is uninstalled or disabled with nftables (Automated)" {
    run bash -c "dpkg-query -s ufw | grep 'Status: install ok installed'"
    if [[ ! "$output" == *"package 'ufw' is not installed and no information is available"* ]]; then
        [[ $(ufw status | grep 'Status') == "Status: inactive" ]]
    fi
}

@test "3.5.2.3 Ensure iptables are flushed with nftables (Manual)" {
    run bash -c "iptables -L"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
    run bash -c "ip6tables -L"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "3.5.2.4 Ensure a nftables table exists (Automated)" {
    run bash -c "nft list tables"
    [ "$status" -eq 0 ]
}

@test "3.5.2.5 Ensure nftables base chains exist (Automated)" {
    run bash -c "nft list ruleset | grep 'hook input'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"type filter hook input priority filter;"* ]]
    run bash -c "nft list ruleset | grep 'hook forward'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"type filter hook forward priority filter;"* ]]
    run bash -c "nft list ruleset | grep 'hook output'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"type filter hook output priority filter;"* ]]
}

@test "3.5.2.6 Ensure nftables loopback traffic is configured (Automated)" {
    run bash -c "nft list ruleset | awk '/hook input/,/}/' | grep 'iif \"lo\" accept'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"iif \"lo\" accept"* ]]
    run bash -c "nft list ruleset | awk '/hook input/,/}/' | grep 'ip saddr'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"ip saddr 127.0.0.0/8 counter packets 0 bytes 0 drop"* ]]
    
    run check_ip_v6
    [ $status -eq 0 ]
    if [[ "$output" == *"*** IPv6 is enabled on the system ***"* ]]; then
        run bash -c "nft list ruleset | awk '/hook input/,/}/' | grep 'ip6 saddr'"
        [ "$status" -eq 0 ]
        [[ "$output" == *"ip6 saddr ::1 counter packets 0 bytes 0 drop"* ]]
    fi
}

@test "3.5.2.7 Ensure nftables outbound and established connections are configured (Manual)" {
    run bash -c "nft list ruleset | awk '/hook input/,/}/' | grep -E 'ip protocol (tcp|udp|icmp) ct state'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"ip protocol tcp ct state established accept"* ]]
    [[ "$output" == *"ip protocol udp ct state established accept"* ]]
    [[ "$output" == *"ip protocol icmp ct state established accept"* ]]

    run bash -c "nft list ruleset | awk '/hook output/,/}/' | grep -E 'ip protocol (tcp|udp|icmp) ct state'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"ip protocol tcp ct state established,related,new accept"* ]]
    [[ "$output" == *"ip protocol udp ct state established,related,new accept"* ]]
    [[ "$output" == *"ip protocol icmp ct state established,related,new accept"* ]]
}

@test "3.5.2.8 Ensure nftables default deny firewall policy (Automated)" {
    run bash -c "nft list ruleset | grep 'hook input'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"type filter hook input priority filter; policy drop;"* ]]
    run bash -c "nft list ruleset | grep 'hook forward'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"type filter hook forward priority filter; policy drop;"* ]]
    run bash -c "nft list ruleset | grep 'hook output'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"type filter hook output priority filter; policy drop;"* ]]
}

@test "3.5.2.9 Ensure nftables service is enabled (Automated)" {
    run bash -c "systemctl is-enabled nftables"
    [[ "$output" == "enabled" ]]
}

@test "3.5.2.10 Ensure nftables rules are permanent (Automated)" {
    skip "This audit has to be done manually"
}

# 3.5.3 Configure iptables

## 3.5.3.1 Configure iptables software

@test "3.5.3.1.1 Ensure iptables packages are installed (Automated)" {
    run bash -c "apt list iptables iptables-persistent | grep installed"
    [ $status -eq 0 ]
    echo "INFO: output -> $output"
    [[ "$output" =~ iptables[^-].*\[(installed(,automatic)*)\] ]]
    [[ "$output" =~ iptables-persistent.*\[(installed(,automatic)*)\] ]]
}

@test "3.5.3.1.2 Ensure nftables is not installed with iptables (Automated)" {
    run bash -c "dpkg -s nftables | grep 'dpkg-query'"
    [ $status -eq 1 ]
    [[ "$output" == *"dpkg-query: package 'nftables' is not installed"* ]]
}

@test "3.5.3.1.3 Ensure ufw is uninstalled or disabled with iptables (Automated)" {
    run bash -c "dpkg -s ufw | grep 'dpkg-query'"
    if [[ ! "$output" == *"dpkg-query: package 'ufw' is not installed and no information is available"* ]]; then
        [[ $(ufw status | grep 'Status') == "Status: inactive" ]]
    fi
}

## 3.5.3.2 Configure IPv4 iptables

@test "3.5.3.2.1 Ensure iptables loopback traffic is configured (Automated)" {
    run bash -c "iptables -L INPUT -v -n"
    [ "$status" -eq 0 ]
    [[ "$output" = *"ACCEPT"*"all"*"--"*"lo"*"*"*"0.0.0.0/0"*"0.0.0.0/0"* ]]
    [[ "$output" = *"DROP"*"all"*"--"*"*"*"*"*"127.0.0.0/8"*"0.0.0.0/0"* ]]
    run bash -c "iptables -L OUTPUT -v -n"
    [ "$status" -eq 0 ]
    [[ "$output" = *"ACCEPT"*"all"*"--"*"*"*"lo"*"0.0.0.0/0"*"0.0.0.0/0"* ]]
}

@test "3.5.3.2.2 Ensure iptables outbound and established connections are configured (Manual)" {
    skip "This audit has to be done manually"
}

@test "3.5.3.2.3 Ensure iptables default deny firewall policy (Automated)" {
    run bash -c "iptables -L"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Chain INPUT (policy DROP)"* || "$output" == *"Chain INPUT (policy REJECT)"* ]]
    [[ "$output" == *"Chain FORWARD (policy DROP)"* || "$output" == *"Chain FORWARD (policy REJECT)"* ]]
    [[ "$output" == *"Chain OUTPUT (policy DROP)"* || "$output" == *"Chain OUTPUT (policy REJECT)"* ]]
}

@test "3.5.3.2.4 Ensure iptables firewall rules exist for all open ports (Automated)" {
    skip "This audit has to be done manually"
}

## 3.5.3.3 Configure IPv6 ip6tables

@test "3.5.3.3.1 Ensure ip6tables loopback traffic is configured (Automated)" {
    run check_ip_v6
    [ "$status" -eq 0 ]
    if [[ "$output" != *"*** IPv6 is enabled on the system ***"* ]]; then
        skip "*** IPv6 is not enabled on the system ***"
    fi

    run bash -c "ip6tables -L INPUT -v -n"
    [ "$status" -eq 0 ]
    [[ "$output" = *"ACCEPT"*"all"*"lo"*"*"*"::/0"*"::/0"* ]]
    [[ "$output" = *"DROP"*"all"*"*"*"*"*"::1"*"::/0"* ]]
    run bash -c "ip6tables -L OUTPUT -v -n"
    [ "$status" -eq 0 ]
    [[ "$output" = *"ACCEPT"*"all"*"*"*"lo"*"::/0"*"::/0"* ]]
}

@test "3.5.3.3.2 Ensure ip6tables outbound and established connections are configured (Manual)" {
    run check_ip_v6
    [ "$status" -eq 0 ]
    if [[ "$output" != *"*** IPv6 is enabled on the system ***"* ]]; then
        skip "*** IPv6 is not enabled on the system ***"
    fi
    skip "This audit has to be done manually"
}

@test "3.5.3.3.3 Ensure ip6tables default deny firewall policy (Automated)" {
    run check_ip_v6
    [ "$status" -eq 0 ]
    if [[ "$output" != *"*** IPv6 is enabled on the system ***"* ]]; then
        skip "*** IPv6 is not enabled on the system ***"
    fi

    run bash -c "ip6tables -L"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Chain INPUT (policy DROP)"* || "$output" == *"Chain INPUT (policy REJECT)"* ]]
    [[ "$output" == *"Chain FORWARD (policy DROP)"* || "$output" == *"Chain FORWARD (policy REJECT)"* ]]
    [[ "$output" == *"Chain OUTPUT (policy DROP)"* || "$output" == *"Chain OUTPUT (policy REJECT)"* ]]
}

@test "3.5.3.3.4 Ensure ip6tables firewall rules exist for all open ports (Manual)" {
    run check_ip_v6
    [ "$status" -eq 0 ]
    if [[ "$output" != *"*** IPv6 is enabled on the system ***"* ]]; then
        skip "*** IPv6 is not enabled on the system ***"
    fi
    skip "This audit has to be done manually"
}
