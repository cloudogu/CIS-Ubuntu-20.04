#!/usr/bin/env bats

@test "5.3.1 Ensure permissions on /etc/ssh/sshd_config are configured (Automated)" {
    run bash -c "stat /etc/ssh/sshd_config"
    [ "$status" -eq 0 ]
    [[ "$output" = *"Uid:"*"("*"0/"*"root"* ]]
    [[ "$output" = *"Gid:"*"("*"0/"*"root"* ]]
    [[ "$output" = *"Access:"*"(0"[0-7]"00"* ]]
}

@test "5.3.2 Ensure permissions on SSH private host key files are configured (Automated)" {
    local SSH_CONFIG=$(find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec stat {} \; | grep "Access" | grep "Uid")
    while IFS= read -r line; do
        [[ "$line" = *"Uid:"*"("*"0/"*"root"* ]]
        [[ "$line" = *"Gid:"*"("*"0/"*"root"* ]]
        [[ "$line" = "Access:"*"(0"[0-7]"00"* ]]
    done <<< "$SSH_CONFIG"
}

@test "5.3.3 Ensure permissions on SSH public host key files are configured (Automated)" {
    local SSH_CONFIG=$(find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec stat {} \; | grep "Access" | grep "Uid")
    while IFS= read -r line; do
        [[ "$line" = "Access:"*"(0"[0-7][0\|4][0\|4]* ]]
    done <<< "$SSH_CONFIG"
}

@test "5.3.4 Ensure SSH access is limited (Automated)" {
    run bash -c "sshd -T | grep allowusers"
    ALLOWUSERS=$status
    run bash -c "sshd -T | grep allowgroups"
    ALLOWGROUPS=$status
    run bash -c "sshd -T | grep denyusers"
    DENYUSERS=$status
    run bash -c "sshd -T | grep denygroups"
    DENYGROUPS=$status
    [ "$ALLOWUSERS" -eq 0 ] || [ "$ALLOWGROUPS" -eq 0 ] || [ "$DENYUSERS" -eq 0 ] || [ "$DENYGROUPS" -eq 0 ]
}

@test "5.3.5 Ensure SSH LogLevel is appropriate (Automated)" {
    run bash -c "sshd -T | grep loglevel"
    [ "$status" -eq 0 ]
    [[ "$output" == "LogLevel VERBOSE" ]] || [[ "$output" == "loglevel INFO" ]]
}

@test "5.3.6 Ensure SSH X11 forwarding is disabled (Automated)" {
    run bash -c "sshd -T | grep x11forwarding"
    [ "$status" -eq 0 ]
    [[ "$output" == "x11forwarding no" ]]
}

@test "5.3.7 Ensure SSH MaxAuthTries is set to 4 or less (Automated)" {
    run bash -c "sshd -T | grep maxauthtries"
    [ "$status" -eq 0 ]
    [[ "$output" == "maxauthtries "[1-4] ]]
    run bash -c "grep -Eis '^\s*maxauthtries\s+([5-9]|[1-9][0-9]+)' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    [[ "$output" == "" ]]
}

@test "5.3.8 Ensure SSH IgnoreRhosts is enabled (Automated)" {
    run bash -c "sshd -T | grep ignorerhosts"
    [ "$status" -eq 0 ]
    [[ "$output" == "ignorerhosts yes" ]]
    run bash -c "grep -Eis '^\s*ignorerhosts\s+no\b' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    [[ "$output" == "" ]]
}

@test "5.3.9 Ensure SSH HostbasedAuthentication is disabled (Automated)" {
    run bash -c "sshd -T | grep hostbasedauthentication"
    [ "$status" -eq 0 ]
    [[ "$output" == "hostbasedauthentication no" ]]
    run bash -c "grep -Eis '^\s*HostbasedAuthentication\s+yes' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    [[ "$output" == "" ]]
}

@test "5.3.10 Ensure SSH root login is disabled (Automated)" {
    run bash -c "sshd -T | grep permitrootlogin"
    [ "$status" -eq 0 ]
    [[ "$output" == "permitrootlogin no" ]]
    run bash -c "grep -Eis '^\s*PermitRootLogin\s+yes' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    [[ "$output" == "" ]]
}

@test "5.3.11 Ensure SSH PermitEmptyPasswords is disabled (Automated)" {
    run bash -c "sshd -T | grep permitemptypasswords"
    [ "$status" -eq 0 ]
    [[ "$output" == "permitemptypasswords no" ]]
    run bash -c "grep -Eis '^\s*PermitEmptyPasswords\s+yes' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    [[ "$output" == "" ]]
}

@test "5.3.12 Ensure SSH PermitUserEnvironment is disabled (Automated)" {
    run bash -c "sshd -T | grep permituserenvironment"
    [ "$status" -eq 0 ]
    [[ "$output" == "permituserenvironment no" ]]
    run bash -c "grep -Eis '^\s*PermitUserEnvironment\s+yes' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    [[ "$output" == "" ]]
}

@test "5.3.13 Ensure only strong Ciphers are used (Automated)" {
    run bash -c "sshd -T | grep ciphers"
    [ "$status" -eq 0 ]
    [[ "$output" != *"3des-cbc"* ]]
    [[ "$output" != *"aes128-cbc"* ]]
    [[ "$output" != *"aes192-cbc"* ]]
    [[ "$output" != *"aes256-cbc"* ]]
    [[ "$output" != *"arcfour"* ]]
    [[ "$output" != *"arcfour128"* ]]
    [[ "$output" != *"arcfour256"* ]]
    [[ "$output" != *"blowfish-cbc"* ]]
    [[ "$output" != *"cast128-cbc"* ]]
    [[ "$output" != *"rijndael-cbc@lysator.liu.se"* ]]
}

@test "5.3.14 Ensure only strong MAC algorithms are used (Automated)" {
    run bash -c "sshd -T | grep -i "MACs""
    [ "$status" -eq 0 ]
    [[ "$output" != *"hmac-md5"* ]]
    [[ "$output" != *"hmac-md5-96"* ]]
    [[ "$output" != *"hmac-ripemd160"* ]]
    [[ "$output" != *"hmac-sha1"* ]]
    [[ "$output" != *"hmac-sha1-96"* ]]
    [[ "$output" != *"umac-64@openssh.com"* ]]
    [[ "$output" != *"umac-128@openssh.com"* ]]
    [[ "$output" != *"hmac-md5-etm@openssh.com"* ]]
    [[ "$output" != *"hmac-md5-96-etm@openssh.com"* ]]
    [[ "$output" != *"hmac-ripemd160-etm@openssh.com"* ]]
    [[ "$output" != *"hmac-sha1-etm@openssh.com"* ]]
    [[ "$output" != *"hmac-sha1-96-etm@openssh.com"* ]]
    [[ "$output" != *"umac-64-etm@openssh.com"* ]]
    [[ "$output" != *"umac-128-etm@openssh.com"* ]]
}

@test "5.3.15 Ensure only strong Key Exchange algorithms are used (Automated)" {
    run bash -c "sshd -T | grep kexalgorithms"
    [ "$status" -eq 0 ]
    [[ "$output" != *"diffie-hellman-group1-sha1"* ]]
    [[ "$output" != *"diffie-hellman-group14-sha1"* ]]
    [[ "$output" != *"diffie-hellman-group-exchange-sha1"* ]]
}

@test "5.3.16 Ensure SSH Idle Timeout Interval is configured (Automated)" {
    local INTERVAL=$(sshd -T | grep clientaliveinterval)
    INTERVAL=(${INTERVAL// / })
    [[ "${INTERVAL[1]}" -gt 1 ]]
    [[ "${INTERVAL[1]}" -lt 301 ]]
    local MAX=$(sshd -T | grep clientalivecountmax)
    MAX=(${MAX// / })
    [[ "${MAX[1]}" -lt 4 ]]
}

@test "5.3.17 Ensure SSH LoginGraceTime is set to one minute or less (Automated)" {
    local LOGINGRACETIME=$(sshd -T | grep logingracetime)
    LOGINGRACETIME=(${LOGINGRACETIME// / })
    [[ "${LOGINGRACETIME[1]}" -gt 0 ]]
    [[ "${LOGINGRACETIME[1]}" -lt 61 ]]
}

@test "5.3.18 Ensure SSH warning banner is configured (Automated)" {
    run bash -c "sshd -T | grep banner"
    [ "$status" -eq 0 ]
    [[ "$output" == "banner /etc/issue.net" ]]
}

@test "5.3.19 Ensure SSH PAM is enabled (Automated)" {
    run bash -c "sshd -T | grep -i usepam"
    [ "$status" -eq 0 ]
    [[ "$output" == "usepam yes" ]]
}

@test "5.3.20 Ensure SSH AllowTcpForwarding is disabled (Automated)" {
    run bash -c "sshd -T | grep -i allowtcpforwarding"
    [ "$status" -eq 0 ]
    [[ "$output" == "allowtcpforwarding no" ]]
    run bash -c "grep -Eis '^\s*AllowTcpForwarding\s+yes\b' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
}

@test "5.3.21 Ensure SSH MaxStartups is configured (Automated)" {
    run bash -c "sshd -T | grep -i maxstartups"
    [ "$status" -eq 0 ]
    if [[ "$output" != "maxstartups 10:30:60" ]]; then
        skip "This audit has to be done manually"
    fi
}

@test "5.3.22 Ensure SSH MaxSessions is limited (Automated)" {
    local MAXSESSIONS=$(sshd -T | grep -i maxsessions)
    MAXSESSIONS=(${MAXSESSIONS// / })
    if [[ "${MAXSESSIONS[1]}" -gt 10 ]]; then
        skip "This audit has to be done manually"
    fi
}
