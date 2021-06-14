#!/usr/bin/env bats

@test "4.1.1.1 Ensure auditd is installed (Scored)" {
    run bash -c "dpkg -s auditd audispd-plugins"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Status: install ok installed"* ]]
}

@test "4.1.1.2 Ensure auditd service is enabled (Scored)" {
    run bash -c "systemctl is-enabled auditd"
    [ "$status" -eq 0 ]
    [ "$output" = "enabled" ]
}

@test "4.1.1.3 Ensure auditing for processes that start prior to auditd is enabled (Scored)" {
    run bash -c "grep \"^\s*linux\" /boot/grub/grub.cfg | grep -v \"audit=1\" | grep -v '/boot/memtest86+.bin'"
    [ "$status" -ne 0 ]
    [ "$output" = "" ]
}

@test "4.1.1.4 Ensure audit_backlog_limit is sufficient (Scored)" {
    skip "This audit has to be done manually"
}

@test "4.1.2.1 Ensure audit log storage size is configured (Scored)" {
    skip "This audit has to be done manually"
}

@test "4.1.2.2 Ensure audit logs are not automatically deleted (Scored)" {
    run bash -c "grep max_log_file_action /etc/audit/auditd.conf"
    [ "$status" -eq 0 ]
    [ "$output" = "max_log_file_action = keep_logs" ]
}

@test "4.1.2.3 Ensure system is disabled when audit logs are full (Scored)" {
    run bash -c "grep space_left_action /etc/audit/auditd.conf"
    [ "$status" -eq 0 ]
    [[ "$output" = "space_left_action = email"* ]]
    run bash -c "grep action_mail_acct /etc/audit/auditd.conf"
    [ "$status" -eq 0 ]
    [ "$output" = "action_mail_acct = root" ]
    run bash -c "grep admin_space_left_action /etc/audit/auditd.conf"
    [ "$status" -eq 0 ]
    [ "$output" = "admin_space_left_action = halt" ]
}

@test "4.1.3 Ensure events that modify date and time information are collected (Scored)" {
    run bash -c "grep time-change /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change"* ]]
    [[ "$output" == *"-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change"* ]]
    [[ "$output" == *"-a always,exit -F arch=b64 -S clock_settime -k time-change"* ]]
    [[ "$output" == *"-a always,exit -F arch=b32 -S clock_settime -k time-change"* ]]
    [[ "$output" == *"-w /etc/localtime -p wa -k time-change"* ]]
    run bash -c "auditctl -l | grep time-change"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-a always,exit -F arch=b64 -S adjtimex,settimeofday -F key=time-change"* ]]
    [[ "$output" == *"-a always,exit -F arch=b32 -S stime,settimeofday,adjtimex -F key=time-change"* ]]
    [[ "$output" == *"-a always,exit -F arch=b64 -S clock_settime -F key=time-change"* ]]
    [[ "$output" == *"-a always,exit -F arch=b32 -S clock_settime -F key=time-change"* ]]
    [[ "$output" == *"-w /etc/localtime -p wa -k time-change"* ]]
}

@test "4.1.4 Ensure events that modify user/group information are collected (Scored)" {
    run bash -c "grep identity /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-w /etc/group -p wa -k identity"* ]]
    [[ "$output" == *"-w /etc/passwd -p wa -k identity"* ]]
    [[ "$output" == *"-w /etc/gshadow -p wa -k identity"* ]]
    [[ "$output" == *"-w /etc/shadow -p wa -k identity"* ]]
    [[ "$output" == *"-w /etc/security/opasswd -p wa -k identity"* ]]
    run bash -c "auditctl -l | grep identity"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-w /etc/group -p wa -k identity"* ]]
    [[ "$output" == *"-w /etc/passwd -p wa -k identity"* ]]
    [[ "$output" == *"-w /etc/gshadow -p wa -k identity"* ]]
    [[ "$output" == *"-w /etc/shadow -p wa -k identity"* ]]
    [[ "$output" == *"-w /etc/security/opasswd -p wa -k identity"* ]]
}

@test "4.1.5 Ensure events that modify the system's network environment are collected (Scored)" {
    run bash -c "grep system-locale /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale"* ]]
    [[ "$output" == *"-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale"* ]]
    [[ "$output" == *"-w /etc/issue -p wa -k system-locale"* ]]
    [[ "$output" == *"-w /etc/issue.net -p wa -k system-locale"* ]]
    [[ "$output" == *"-w /etc/hosts -p wa -k system-locale"* ]]
    [[ "$output" == *"-w /etc/network -p wa -k system-locale"* ]]
    run bash -c "auditctl -l | grep system-locale"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-a always,exit -F arch=b64 -S sethostname,setdomainname -F key=system-locale"* ]]
    [[ "$output" == *"-a always,exit -F arch=b32 -S sethostname,setdomainname -F key=system-locale"* ]]
    [[ "$output" == *"-w /etc/issue -p wa -k system-locale"* ]]
    [[ "$output" == *"-w /etc/issue.net -p wa -k system-locale"* ]]
    [[ "$output" == *"-w /etc/hosts -p wa -k system-locale"* ]]
    [[ "$output" == *"-w /etc/network -p wa -k system-locale"* ]]
}

@test "4.1.6 Ensure events that modify the system's Mandatory Access Controls are collected (Scored)" {
    run bash -c "grep MAC-policy /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-w /etc/apparmor/ -p wa -k MAC-policy"* ]]
    [[ "$output" == *"-w /etc/apparmor.d/ -p wa -k MAC-policy"* ]]
    run bash -c "auditctl -l | grep MAC-policy"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-w /etc/apparmor -p wa -k MAC-policy"* ]]
    [[ "$output" == *"-w /etc/apparmor.d -p wa -k MAC-policy"* ]]
}

@test "4.1.7 Ensure login and logout events are collected (Scored)" {
    run bash -c "grep logins /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-w /var/log/faillog -p wa -k logins"* ]]
    [[ "$output" == *"-w /var/log/lastlog -p wa -k logins"* ]]
    [[ "$output" == *"-w /var/log/tallylog -p wa -k logins"* ]]
    run bash -c "auditctl -l | grep logins"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-w /var/log/faillog -p wa -k logins"* ]]
    [[ "$output" == *"-w /var/log/lastlog -p wa -k logins"* ]]
    [[ "$output" == *"-w /var/log/tallylog -p wa -k logins"* ]]
}

@test "4.1.8 Ensure session initiation information is collected (Scored)" {
    run bash -c "grep -E '(session|logins)' /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-w /var/run/utmp -p wa -k session"* ]]
    [[ "$output" == *"-w /var/log/wtmp -p wa -k logins"* ]]
    [[ "$output" == *"-w /var/log/btmp -p wa -k logins"* ]]
    run bash -c "auditctl -l | grep -E '(session|logins)'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-w /var/run/utmp -p wa -k session"* ]]
    [[ "$output" == *"-w /var/log/wtmp -p wa -k logins"* ]]
    [[ "$output" == *"-w /var/log/btmp -p wa -k logins"* ]]
}

@test "4.1.9 Ensure discretionary access control permission modification events are collected (Scored)" {
    run bash -c "grep perm_mod /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod"* ]]
    [[ "$output" == *"-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod"* ]]
    [[ "$output" == *"-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod"* ]]
    [[ "$output" == *"-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod"* ]]
    [[ "$output" == *"-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod"* ]]
    [[ "$output" == *"-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod"* ]]
    run bash -c "auditctl -l | grep perm_mod"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-a always,exit -F arch=b64 -S chmod,fchmod,fchmodat -F auid>=1000 -F auid!=-1"* ]]
    [[ "$output" == *"-F key=perm_mod"* ]]
    [[ "$output" == *"-a always,exit -F arch=b32 -S chmod,fchmod,fchmodat -F auid>=1000 -F auid!=-1"* ]]
    [[ "$output" == *"-F key=perm_mod"* ]]
    [[ "$output" == *"-a always,exit -F arch=b64 -S chown,fchown,lchown,fchownat -F auid>=1000 -F auid!=-1 -F key=perm_mod"* ]]
    [[ "$output" == *"-a always,exit -F arch=b32 -S lchown,fchown,chown,fchownat -F auid>=1000 -F auid!=-1 -F key=perm_mod"* ]]
    [[ "$output" == *"-a always,exit -F arch=b64 -S setxattr,lsetxattr,fsetxattr,removexattr,lremovexattr,fremovexattr -F auid>=1000 -F auid!=-1 -F key=perm_mod"* ]]
    [[ "$output" == *"-a always,exit -F arch=b32 -S setxattr,lsetxattr,fsetxattr,removexattr,lremovexattr,fremovexattr -F auid>=1000 -F auid!=-1 -F key=perm_mod"* ]]
}

@test "4.1.10 Ensure unsuccessful unauthorized file access attempts are collected (Scored)" {
    run bash -c "grep access /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access"* ]]
    [[ "$output" == *"-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access"* ]]
    [[ "$output" == *"-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access"* ]]
    [[ "$output" == *"-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access"* ]]
    run bash -c "auditctl -l | grep access"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-a always,exit -F arch=b64 -S open,truncate,ftruncate,creat,openat -F exit=-EACCES -F auid>=1000 -F auid!=-1 -F key=access"* ]]
    [[ "$output" == *"-a always,exit -F arch=b32 -S open,creat,truncate,ftruncate,openat -F exit=-EACCES -F auid>=1000 -F auid!=-1 -F key=access"* ]]
    [[ "$output" == *"-a always,exit -F arch=b64 -S open,truncate,ftruncate,creat,openat -F exit=-EPERM -F auid>=1000 -F auid!=-1 -F key=access"* ]]
    [[ "$output" == *"-a always,exit -F arch=b32 -S open,creat,truncate,ftruncate,openat -F exit=-EPERM -F auid>=1000 -F auid!=-1 -F key=access"* ]]
}

@test "4.1.11 Ensure use of privileged commands is collected (Scored)" {
    skip "This audit has to be done manually"
}

@test "4.1.12 Ensure successful file system mounts are collected (Scored)" {
    run bash -c "grep mounts /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts"* ]]
    [[ "$output" == *"-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts"* ]]
    run bash -c "auditctl -l | grep mounts"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=-1 -F key=mounts"* ]]
    [[ "$output" == *"-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=-1 -F key=mounts"* ]]
}

@test "4.1.13 Ensure file deletion events by users are collected (Scored)" {
    run bash -c "grep delete /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete"* ]]
    [[ "$output" == *"-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete"* ]]
    run bash -c "auditctl -l | grep delete"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-a always,exit -F arch=b64 -S rename,unlink,unlinkat,renameat -F auid>=1000 -F auid!=-1 -F key=delete"* ]]
    [[ "$output" == *"-a always,exit -F arch=b32 -S unlink,rename,unlinkat,renameat -F auid>=1000 -F auid!=-1 -F key=delete"* ]]
}

@test "4.1.14 Ensure changes to system administration scope (sudoers) is collected (Scored)" {
    run bash -c "grep scope /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-w /etc/sudoers -p wa -k scope"* ]]
    [[ "$output" == *"-w /etc/sudoers.d/ -p wa -k scope"* ]]
    run bash -c "auditctl -l | grep scope"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-w /etc/sudoers -p wa -k scope"* ]]
    [[ "$output" == *"-w /etc/sudoers.d -p wa -k scope"* ]]
}

@test "4.1.15 Ensure system administrator actions (sudolog) are collected (Scored)" {
    # grep -> take line with logfile entry
    # sed1 -> filter path
    # sed2 -> remove quotes from file path
    local COMPOUND_CONFIG_VALUE=$(echo "-w $(grep -r logfile /etc/sudoers* | sed -e 's/.*logfile=//;s/,? .*//' | sed -re 's/"(.*)"/\1/') -p wa -k actions")

    # regex to validate that the string contains a path after the '-w' flag with or without surrounding quotes
    local VALIDATION_REGEX='^-w\s+"?\/([A-z0-9-_+]+\/)*([A-z0-9-_+]+\.([A-z0-9]+))"?\s+-p\s+wa\s+-k\s+actions$'

    # check for valid log file configured in /etc/sudoers
    [[ $(grep -oP $VALIDATION_REGEX <<< $COMPOUND_CONFIG_VALUE) ]]

    # rules file for audit service has to contain previously found log file
    local RULES_REGEX="^\s*$COMPOUND_CONFIG_VALUE$"
    [[ $(grep -oP "$RULES_REGEX" /etc/audit/rules.d/*.rules) ]]

    # log file setting has to be successfully configured for
    run bash -c "auditctl -l | grep actions"
    [ "$status" -eq 0 ]
    [[ "$output" == "$COMPOUND_CONFIG_VALUE" ]]
}

@test "4.1.16 Ensure kernel module loading and unloading is collected (Scored)" {
    run bash -c "grep modules /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-w /sbin/insmod -p x -k modules"* ]]
    [[ "$output" == *"-w /sbin/rmmod -p x -k modules"* ]]
    [[ "$output" == *"-w /sbin/modprobe -p x -k modules"* ]]
    [[ "$output" == *"-a always,exit -F arch=b64 -S init_module -S delete_module -k modules"* ]]
    run bash -c "auditctl -l | grep modules"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-w /sbin/insmod -p x -k modules"* ]]
    [[ "$output" == *"-w /sbin/rmmod -p x -k modules"* ]]
    [[ "$output" == *"-w /sbin/modprobe -p x -k modules"* ]]
    [[ "$output" == *"-a always,exit -F arch=b64 -S init_module,delete_module -F key=modules"* ]]
}

@test "4.1.17 Ensure the audit configuration is immutable (Scored)" {
    run bash -c "grep \"^\s*[^#]\" /etc/audit/audit.rules | tail -1"
    [ "$status" -eq 0 ]
    [ "$output" = "-e 2" ]
}