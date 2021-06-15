#!/usr/bin/env bats

@test "5.3.1 Ensure permissions on /etc/ssh/sshd_config are configured (Automated)" {
    run bash -c "stat /etc/ssh/sshd_config"
    [ "$status" -eq 0 ]
    [[ "$output" = *"Uid:"*"("*"0/"*"root"* ]]
    [[ "$output" = *"Gid:"*"("*"0/"*"root"* ]]
    [[ "$output" = *"Access:"*"(0"[0-6]"00"* ]]
}

@test "5.3.2 Ensure permissions on SSH private host key files are configured (Automated)" {
    local SSH_CONFIG=$(find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec stat {} \; | grep "Access" | grep "Uid")
    while IFS= read -r line; do
        [[ "$line" = *"Uid:"*"("*"0/"*"root"* ]]
        [[ "$line" = *"Gid:"*"("*"0/"*"root"* ]]
        [[ "$line" = "Access:"*"(0"[0-6]"00"* ]]
    done <<< "$SSH_CONFIG"
}

@test "5.3.3 Ensure permissions on SSH public host key files are configured (Automated)" {
    local SSH_CONFIG=$(find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec stat {} \; | grep "Access" | grep "Uid")
    while IFS= read -r line; do
        [[ "$line" = "Access:"*"(0"[0-7][0\|4][0\|4]* ]]
    done <<< "$SSH_CONFIG"
}

@test "5.3.4 Ensure SSH access is limited (Automated)" {
    run bash -c "sshd -T -C user=root -C host=\"$(hostname)\" -C addr=\"$(grep $(hostname) /etc/hosts | awk '{print $1}')\" | grep -Ei '^\s*(allow|deny)(users|groups)\s+\S+'"

    captured_output="$output"

    run bash -c "echo \"$captured_output\" | grep allowusers"
    ALLOWUSERS=$status
    run bash -c "echo \"$captured_output\" | grep allowgroups"
    ALLOWGROUPS=$status
    run bash -c "echo \"$captured_output\" | grep denyusers"
    DENYUSERS=$status
    run bash -c "echo \"$captured_output\" | grep denygroups"
    DENYGROUPS=$status
    
    [ "$ALLOWUSERS" -eq 0 ] || [ "$ALLOWGROUPS" -eq 0 ] || [ "$DENYUSERS" -eq 0 ] || [ "$DENYGROUPS" -eq 0 ]
}

@test "5.3.5 Ensure SSH LogLevel is appropriate (Automated)" {
    run bash -c "sshd -T -C user=root -C host=\"$(hostname)\" -C addr=\"$(grep $(hostname) /etc/hosts | awk '{print $1}')\" | grep loglevel"
    [ "$status" -eq 0 ]
    [[ "$output" == "LogLevel VERBOSE" ]] || [[ "$output" == "loglevel INFO" ]]

    run bash -c "grep -is 'loglevel' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf | grep -Evi '(VERBOSE|INFO)'"
    [ "$status" -ne 0 ]
    [[ "$output" == "" ]]
}

@test "5.3.6 Ensure SSH X11 forwarding is disabled (Automated)" {
    run bash -c "sshd -T -C user=root -C host=\"$(hostname)\" -C addr=\"$(grep $(hostname) /etc/hosts | awk '{print $1}')\" | grep -i x11forwarding"
    [ "$status" -eq 0 ]
    [[ "$output" == "x11forwarding no" ]]
    run bash -c "grep -Eis '^\s*x11forwarding\s+yes' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    [ "$status" -ne 0 ]
    [[ "$output" == "" ]]
}

@test "5.3.7 Ensure SSH MaxAuthTries is set to 4 or less (Automated)" {
    run bash -c "sshd -T -C user=root -C host=\"$(hostname)\" -C addr=\"$(grep $(hostname) /etc/hosts | awk '{print $1}')\" | grep maxauthtries"
    [ "$status" -eq 0 ]
    [[ "$output" == "maxauthtries "[1-4] ]]
    run bash -c "grep -Eis '^\s*maxauthtries\s+([5-9]|[1-9][0-9]+)' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    [ "$status" -ne 0 ]
    [[ "$output" == "" ]]
}

@test "5.3.8 Ensure SSH IgnoreRhosts is enabled (Automated)" {
    run bash -c "sshd -T -C user=root -C host=\"$(hostname)\" -C addr=\"$(grep $(hostname) /etc/hosts | awk '{print $1}')\" | grep ignorerhosts"
    [ "$status" -eq 0 ]
    [[ "$output" == "ignorerhosts yes" ]]
    run bash -c "grep -Eis '^\s*ignorerhosts\s+no\b' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    [ "$status" -ne 0 ]
    [[ "$output" == "" ]]
}

@test "5.3.9 Ensure SSH HostbasedAuthentication is disabled (Automated)" {
    run bash -c "sshd -T -C user=root -C host=\"$(hostname)\" -C addr=\"$(grep $(hostname) /etc/hosts | awk '{print $1}')\" | grep hostbasedauthentication"
    [ "$status" -eq 0 ]
    [[ "$output" == "hostbasedauthentication no" ]]
    run bash -c "grep -Eis '^\s*HostbasedAuthentication\s+yes' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    [ "$status" -ne 0 ]
    [[ "$output" == "" ]]
}

@test "5.3.10 Ensure SSH root login is disabled (Automated)" {
    run bash -c "sshd -T -C user=root -C host=\"$(hostname)\" -C addr=\"$(grep $(hostname) /etc/hosts | awk '{print $1}')\" | grep permitrootlogin"
    [ "$status" -eq 0 ]
    [[ "$output" == "permitrootlogin no" ]]
    run bash -c "grep -Eis '^\s*PermitRootLogin\s+yes' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    [ "$status" -ne 0 ]
    [[ "$output" == "" ]]
}

@test "5.3.11 Ensure SSH PermitEmptyPasswords is disabled (Automated)" {
    run bash -c "sshd -T -C user=root -C host=\"$(hostname)\" -C addr=\"$(grep $(hostname) /etc/hosts | awk '{print $1}')\" | grep permitemptypasswords"
    [ "$status" -eq 0 ]
    [[ "$output" == "permitemptypasswords no" ]]
    run bash -c "grep -Eis '^\s*PermitEmptyPasswords\s+yes' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    [ "$status" -ne 0 ]
    [[ "$output" == "" ]]
}

@test "5.3.12 Ensure SSH PermitUserEnvironment is disabled (Automated)" {
    run bash -c "sshd -T -C user=root -C host=\"$(hostname)\" -C addr=\"$(grep $(hostname) /etc/hosts | awk '{print $1}')\" | grep permituserenvironment"
    [ "$status" -eq 0 ]
    [[ "$output" == "permituserenvironment no" ]]
    run bash -c "grep -Eis '^\s*PermitUserEnvironment\s+yes' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    [ "$status" -ne 0 ]
    [[ "$output" == "" ]]
}

@test "5.3.13 Ensure only strong Ciphers are used (Automated)" {
    run bash -c "sshd -T -C user=root -C host=\"$(hostname)\" -C addr=\"$(grep $(hostname) /etc/hosts | awk '{print $1}')\" | grep -Ei '^\s*ciphers\s+([^#]+,)?(3descbc|aes128-cbc|aes192-cbc|aes256-cbc|arcfour|arcfour128|arcfour256|blowfishcbc|cast128-cbc|rijndael-cbc@lysator.liu.se)\b'"
    [ "$status" -ne 0 ]
    [[ "$output" == "" ]]
    run bash -c "grep -Eis '^\s*ciphers\s+([^#]+,)?(3des-cbc|aes128-cbc|aes192-cbc|aes256-cbc|arcfour|arcfour128|arcfour256|blowfish-cbc|cast128-cbc|rijndaelcbc@lysator.liu.se)\b' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    [ "$status" -ne 0 ]
    [[ "$output" == "" ]]
}

@test "5.3.14 Ensure only strong MAC algorithms are used (Automated)" {
    run bash -c "sshd -T -C user=root -C host=\"$(hostname)\" -C addr=\"$(grep $(hostname) /etc/hosts | awk '{print $1}')\" | grep -Ei '^\s*macs\s+([^#]+,)?(hmacmd5|hmac-md5-96|hmac-ripemd160|hmac-sha1|hmac-sha1-96|umac64@openssh\.com|hmac-md5-etm@openssh\.com|hmac-md5-96-etm@openssh\.com|hmacripemd160-etm@openssh\.com|hmac-sha1-etm@openssh\.com|hmac-sha1-96-etm@openssh\.com|umac-64-etm@openssh\.com|umac-128-etm@openssh\.com)\b'"
    [ "$status" -ne 0 ]
    [[ "$output" == "" ]]
    run bash -c "grep -Eis '^\s*macs\s+([^#]+,)?(hmac-md5|hmac-md5-96|hmac-ripemd160|hmacsha1|hmac-sha1-96|umac-64@openssh\.com|hmac-md5-etm@openssh\.com|hmac-md5-96-etm@openssh\.com|hmac-ripemd160-etm@openssh\.com|hmac-sha1-etm@openssh\.com|hmac-sha1-96-etm@openssh\.com|umac-64-etm@openssh\.com|umac128-etm@openssh\.com)\b' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    [ "$status" -ne 0 ]
    [[ "$output" == "" ]]
}

@test "5.3.15 Ensure only strong Key Exchange algorithms are used (Automated)" {
    run bash -c "sshd -T -C user=root -C host=\"$(hostname)\" -C addr=\"$(grep $(hostname) /etc/hosts | awk '{print $1}')\" | grep -Ei '^\s*kexalgorithms\s+([^#]+,)?(diffie-hellman-group1-sha1|diffie-hellmangroup14-sha1|diffie-hellman-group-exchange-sha1)\b'"
    [ "$status" -ne 0 ]
    [[ "$output" == "" ]]

    run bash -c "grep -Ei '^\s*kexalgorithms\s+([^#]+,)?(diffie-hellman-group1-sha1|diffiehellman-group14-sha1|diffie-hellman-group-exchange-sha1)\b' /etc/ssh/sshd_config"
    [ "$status" -ne 0 ]
    [[ "$output" == "" ]]
}

@test "5.3.16 Ensure SSH Idle Timeout Interval is configured (Automated)" {
    local INTERVAL=$(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep clientaliveinterval)
    INTERVAL=(${INTERVAL// / }) # get number from string
    [[ "${INTERVAL[1]}" -gt 1 ]]
    [[ "${INTERVAL[1]}" -lt 301 ]]
    local MAX=$(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep clientalivecountmax)
    MAX=(${MAX// / })
    [[ "${MAX[1]}" -gt 0 ]]
    [[ "${MAX[1]}" -lt 4 ]]

    run bash -c "grep -Eis '^\s*clientaliveinterval\s+(0|3[0-9][1-9]|[4-9][0-9][0-9]|[1-9][0-9][0-9][0-9]+|[6-9]m|[1-9][0-9]+m)\b' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    [ "$status" -ne 0 ]
    [[ "$output" == "" ]]
    run bash -c "grep -Eis '^\s*ClientAliveCountMax\s+(0|[4-9]|[1-9][0-9]+)\b' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    [ "$status" -ne 0 ]
    [[ "$output" == "" ]]
}

@test "5.3.17 Ensure SSH LoginGraceTime is set to one minute or less (Automated)" {
    local LOGINGRACETIME=$(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep logingracetime)
    LOGINGRACETIME=(${LOGINGRACETIME// / }) # get number from string
    [[ "${LOGINGRACETIME[1]}" -gt 0 ]]
    [[ "${LOGINGRACETIME[1]}" -lt 61 ]]
    run bash -c "grep -Eis '^\s*LoginGraceTime\s+(0|6[1-9]|[7-9][0-9]|[1-9][0-9][0-9]+|[^1]m)' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    [ "$status" -ne 0 ]
    [[ "$output" == "" ]]
}

@test "5.3.18 Ensure SSH warning banner is configured (Automated)" {
    run bash -c "sshd -T -C user=root -C host=\"$(hostname)\" -C addr=\"$(grep $(hostname) /etc/hosts | awk '{print $1}')\" | grep banner"
    [ "$status" -eq 0 ]
    [[ "$output" == "banner /etc/issue.net" ]]
    run bash -c "grep -Eis '^\s*Banner\s+\"?none\b' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    [ "$status" -ne 0 ]
    [[ "$output" == "" ]]
}

@test "5.3.19 Ensure SSH PAM is enabled (Automated)" {
    run bash -c "sshd -T -C user=root -C host=\"$(hostname)\" -C addr=\"$(grep $(hostname) /etc/hosts | awk '{print $1}')\" | grep -i usepam"
    [ "$status" -eq 0 ]
    [[ "$output" == "usepam yes" ]]
    run bash -c "grep -Eis '^\s*UsePAM\s+no' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    [ "$status" -ne 0 ]
    [[ "$output" == "" ]]
}

@test "5.3.20 Ensure SSH AllowTcpForwarding is disabled (Automated)" {
    run bash -c "sshd -T -C user=root -C host=\"$(hostname)\" -C addr=\"$(grep $(hostname) /etc/hosts | awk '{print $1}')\" | grep -i allowtcpforwarding"
    [ "$status" -eq 0 ]
    [[ "$output" == "allowtcpforwarding no" ]]
    run bash -c "grep -Eis '^\s*AllowTcpForwarding\s+yes\b' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    [ "$status" -ne 0 ]
    [[ "$output" == "" ]]
}

@test "5.3.21 Ensure SSH MaxStartups is configured (Automated)" {
    run bash -c "sshd -T -C user=root -C host=\"$(hostname)\" -C addr=\"$(grep $(hostname) /etc/hosts | awk '{print $1}')\" | grep -i maxstartups"
    [ "$status" -eq 0 ]
    [[ "$output" == "maxstartups 10:30:60" ]]
    run bash -c "grep -Eis '^\s*maxstartups\s+(((1[1-9]|[1-9][0-9][0-9]+):([0-9]+):([0-9]+))|(([0-9]+):(3[1-9]|[4-9][0-9]|[1-9][0-9][0-9]+):([0-9]+))|(([0-9]+):([0-9]+):(6[1-9]|[7-9][0-9]|[1-9][0-9][0-9]+)))' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    [ "$status" -ne 0 ]
    [[ "$output" == "" ]]
}

@test "5.3.22 Ensure SSH MaxSessions is limited (Automated)" {
    local MAXSESSIONS=$(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep -i maxsessions)
    MAXSESSIONS=(${MAXSESSIONS// / }) # get number from string
    [[ "${MAXSESSIONS[1]}" -lt 11 ]]
    run bash -c "grep -Eis '^\s*MaxSessions\s+(1[1-9]|[2-9][0-9]|[1-9][0-9][0-9]+)' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    [ "$status" -ne 0 ]
    [[ "$output" == "" ]]
}
