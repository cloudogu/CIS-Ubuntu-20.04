#!/usr/bin/env bats

@test "4.2.1.1 Ensure rsyslog is installed (Automated)" {
    run bash -c "dpkg -s rsyslog"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Status: install ok installed"* ]]
}

@test "4.2.1.2 Ensure rsyslog Service is enabled (Automated)" {
    run bash -c "systemctl is-enabled rsyslog"
    [ "$status" -eq 0 ]
    [[ "$output" == "enabled" ]]
}

@test "4.2.1.3 Ensure logging is configured (Manual)" {
    skip "This audit has to be done manually"
}

@test "4.2.1.4 Ensure rsyslog default file permissions configured (Automated)" {
    run bash -c "grep ^\$FileCreateMode /etc/rsyslog.conf /etc/rsyslog.d/*.conf"
    [ "$status" -eq 0 ]
    [[ "$output" == *"0640"* ]] || [[ "$output" == *"0600"* ]] || [[ "$output" == *"0440"* ]] || [[ "$output" == *"0400"* ]]
}

@test "4.2.1.5 Ensure rsyslog is configured to send logs to a remote log host (Automated)" {
    skip "This audit has to be done manually"
}

@test "4.2.1.6 Ensure remote rsyslog messages are only accepted on designated log hosts. (Manual)" {
    skip "This audit has to be done manually"
}

@test "4.2.2.1 Ensure journald is configured to send logs to rsyslog (Automated)" {
    run bash -c "grep -e \"^\s*ForwardToSyslog\" /etc/systemd/journald.conf"
    [ "$status" -eq 0 ]
    [[ "$output" == *"ForwardToSyslog=yes"* ]]
    [[ "$output" != *"#ForwardToSyslog=yes"* ]]
}

@test "4.2.2.2 Ensure journald is configured to compress large log files (Automated)" {
    run bash -c "grep -e \"^\s*Compress\" /etc/systemd/journald.conf"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Compress=yes"* ]]
    [[ "$output" != *"#Compress=yes"* ]]
}

@test "4.2.2.3 Ensure journald is configured to write logfiles to persistent disk (Automated)" {
    run bash -c "grep -e \"^\s*Storage\" /etc/systemd/journald.conf"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Storage=persistent"* ]]
    [[ "$output" != *"#Storage=persistent"* ]]
}

@test "4.2.3 Ensure permissions on all logfiles are configured (Automated)" {
    skip "This audit has to be done manually"
}
