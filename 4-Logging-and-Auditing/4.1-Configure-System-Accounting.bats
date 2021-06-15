#!/usr/bin/env bats

@test "4.1.1.1 Ensure auditd is installed (Automated)" {
    run bash -c "dpkg -s auditd audispd-plugins"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Status: install ok installed"* ]]
}

@test "4.1.1.2 Ensure auditd service is enabled (Automated)" {
    run bash -c "systemctl is-enabled auditd"
    [ "$status" -eq 0 ]
    [ "$output" = "enabled" ]
}

@test "4.1.1.3 Ensure auditing for processes that start prior to auditd is enabled (Automated)" {
    run bash -c "grep \"^\s*linux\" /boot/grub/grub.cfg | grep -v \"audit=1\""
    [ "$status" -ne 0 ]
    [ "$output" = "" ]
}

@test "4.1.1.4 Ensure audit_backlog_limit is sufficient (Automated)" {
    skip "This audit has to be done manually"
}

@test "4.1.2.1 Ensure audit log storage size is configured (Automated)" {
    skip "This audit has to be done manually"
}

@test "4.1.2.2 Ensure audit logs are not automatically deleted (Automated)" {
    run bash -c "grep max_log_file_action /etc/audit/auditd.conf"
    [ "$status" -eq 0 ]
    [ "$output" = "max_log_file_action = keep_logs" ]
}

@test "4.1.2.3 Ensure system is disabled when audit logs are full (Automated)" {
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

@test "4.1.3 Ensure events that modify date and time information are collected (Automated)" {
    run bash -c "grep time-change /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change"* ]] || 
        [[ "$current_line" == *"-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b64 -S clock_settime -k time-change"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b32 -S clock_settime -k time-change"* ]] ||
        [[ "$current_line" == *"-w /etc/localtime -p wa -k time-change"* ]]
    done
    
    run bash -c "auditctl -l | grep time-change"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-a always,exit -F arch=b64 -S adjtimex,settimeofday -F key=time-change"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b32 -S stime,settimeofday,adjtimex -F key=time-change"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b64 -S clock_settime -F key=time-change"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b32 -S clock_settime -F key=time-change"* ]] ||
        [[ "$current_line" == *"-w /etc/localtime -p wa -k time-change"* ]]
    done
}

@test "4.1.4 Ensure events that modify user/group information are collected (Automated)" {
    run bash -c "grep identity /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-w /etc/group -p wa -k identity"* ]] ||
        [[ "$current_line" == *"-w /etc/passwd -p wa -k identity"* ]] ||
        [[ "$current_line" == *"-w /etc/gshadow -p wa -k identity"* ]] ||
        [[ "$current_line" == *"-w /etc/shadow -p wa -k identity"* ]] ||
        [[ "$current_line" == *"-w /etc/security/opasswd -p wa -k identity"* ]]
    done
    run bash -c "auditctl -l | grep identity"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-w /etc/group -p wa -k identity"* ]] ||
        [[ "$current_line" == *"-w /etc/passwd -p wa -k identity"* ]] ||
        [[ "$current_line" == *"-w /etc/gshadow -p wa -k identity"* ]] ||
        [[ "$current_line" == *"-w /etc/shadow -p wa -k identity"* ]] ||
        [[ "$current_line" == *"-w /etc/security/opasswd -p wa -k identity"* ]]
    done
}

@test "4.1.5 Ensure events that modify the system's network environment are collected (Automated)" {
    run bash -c "grep system-locale /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale"* ]] ||
        [[ "$current_line" == *"-w /etc/issue -p wa -k system-locale"* ]] ||
        [[ "$current_line" == *"-w /etc/issue.net -p wa -k system-locale"* ]] ||
        [[ "$current_line" == *"-w /etc/hosts -p wa -k system-locale"* ]] ||
        [[ "$current_line" == *"-w /etc/network -p wa -k system-locale"* ]]
    done
    run bash -c "auditctl -l | grep system-locale"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-a always,exit -F arch=b64 -S sethostname,setdomainname -F key=system-locale"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b32 -S sethostname,setdomainname -F key=system-locale"* ]] ||
        [[ "$current_line" == *"-w /etc/issue -p wa -k system-locale"* ]] ||
        [[ "$current_line" == *"-w /etc/issue.net -p wa -k system-locale"* ]] ||
        [[ "$current_line" == *"-w /etc/hosts -p wa -k system-locale"* ]] ||
        [[ "$current_line" == *"-w /etc/network -p wa -k system-locale"* ]]
    done
}

@test "4.1.6 Ensure events that modify the system's Mandatory Access Controls are collected (Automated)" {
    run bash -c "grep MAC-policy /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-w /etc/apparmor/ -p wa -k MAC-policy"* ]] ||
        [[ "$current_line" == *"-w /etc/apparmor.d/ -p wa -k MAC-policy"* ]]
    done
    run bash -c "auditctl -l | grep MAC-policy"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-w /etc/apparmor -p wa -k MAC-policy"* ]] ||
        [[ "$current_line" == *"-w /etc/apparmor.d -p wa -k MAC-policy"* ]]
    done
}

@test "4.1.7 Ensure login and logout events are collected (Automated)" {
    run bash -c "grep logins /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-w /var/log/faillog -p wa -k logins"* ]] ||
        [[ "$current_line" == *"-w /var/log/lastlog -p wa -k logins"* ]] ||
        [[ "$current_line" == *"-w /var/log/tallylog -p wa -k logins"* ]]
    done
    run bash -c "auditctl -l | grep logins"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-w /var/log/faillog -p wa -k logins"* ]] ||
        [[ "$current_line" == *"-w /var/log/lastlog -p wa -k logins"* ]] ||
        [[ "$current_line" == *"-w /var/log/tallylog -p wa -k logins"* ]]
    done
}

@test "4.1.8 Ensure session initiation information is collected (Automated)" {
    run bash -c "grep -E '(session|logins)' /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-w /var/run/utmp -p wa -k session"* ]] ||
        [[ "$current_line" == *"-w /var/log/wtmp -p wa -k logins"* ]] ||
        [[ "$current_line" == *"-w /var/log/btmp -p wa -k logins"* ]]
    done
    run bash -c "auditctl -l | grep -E '(session|logins)'"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-w /var/run/utmp -p wa -k session"* ]] ||
        [[ "$current_line" == *"-w /var/log/wtmp -p wa -k logins"* ]] ||
        [[ "$current_line" == *"-w /var/log/btmp -p wa -k logins"* ]]
    done
}

@test "4.1.9 Ensure discretionary access control permission modification events are collected (Automated)" {
    run bash -c "grep perm_mod /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod"* ]]
    done
    run bash -c "auditctl -l | grep perm_mod"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-a always,exit -F arch=b64 -S chmod,fchmod,fchmodat -F auid>=1000 -F auid!=-1"* ]] ||
        [[ "$current_line" == *"-F key=perm_mod"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b32 -S chmod,fchmod,fchmodat -F auid>=1000 -F auid!=-1"* ]] ||
        [[ "$current_line" == *"-F key=perm_mod"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b64 -S chown,fchown,lchown,fchownat -F auid>=1000 -F auid!=-1 -F key=perm_mod"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b32 -S lchown,fchown,chown,fchownat -F auid>=1000 -F auid!=-1 -F key=perm_mod"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b64 -S setxattr,lsetxattr,fsetxattr,removexattr,lremovexattr,fremovexattr -F auid>=1000 -F auid!=-1 -F key=perm_mod"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b32 -S setxattr,lsetxattr,fsetxattr,removexattr,lremovexattr,fremovexattr -F auid>=1000 -F auid!=-1 -F key=perm_mod"* ]]
    done
}

@test "4.1.10 Ensure unsuccessful unauthorized file access attempts are collected (Automated)" {
    run bash -c "grep access /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access"* ]]
    done
    run bash -c "auditctl -l | grep access"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-a always,exit -F arch=b64 -S open,truncate,ftruncate,creat,openat -F exit=-EACCES -F auid>=1000 -F auid!=-1 -F key=access"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b32 -S open,creat,truncate,ftruncate,openat -F exit=-EACCES -F auid>=1000 -F auid!=-1 -F key=access"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b64 -S open,truncate,ftruncate,creat,openat -F exit=-EPERM -F auid>=1000 -F auid!=-1 -F key=access"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b32 -S open,creat,truncate,ftruncate,openat -F exit=-EPERM -F auid>=1000 -F auid!=-1 -F key=access"* ]]
    done
}

@test "4.1.11 Ensure use of privileged commands is collected (Automated)" {
    skip "This audit has to be done manually"
}

@test "4.1.12 Ensure successful file system mounts are collected (Automated)" {
    run bash -c "grep mounts /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts"* ]]
    done
    run bash -c "auditctl -l | grep mounts"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=-1 -F key=mounts"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=-1 -F key=mounts"* ]]
    done
}

@test "4.1.13 Ensure file deletion events by users are collected (Automated)" {
    run bash -c "grep delete /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete"* ]]
    done
    run bash -c "auditctl -l | grep delete"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-a always,exit -F arch=b64 -S rename,unlink,unlinkat,renameat -F auid>=1000 -F auid!=-1 -F key=delete"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b32 -S unlink,rename,unlinkat,renameat -F auid>=1000 -F auid!=-1 -F key=delete"* ]]
    done
}

@test "4.1.14 Ensure changes to system administration scope (sudoers) is collected (Automated)" {
    run bash -c "grep scope /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-w /etc/sudoers -p wa -k scope"* ]] ||
        [[ "$current_line" == *"-w /etc/sudoers.d/ -p wa -k scope"* ]]
    done
    run bash -c "auditctl -l | grep scope"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-w /etc/sudoers -p wa -k scope"* ]] ||
        [[ "$current_line" == *"-w /etc/sudoers.d -p wa -k scope"* ]]
    done
}

@test "4.1.15 Ensure system administrator command executions (sudo) are collected (Automated)" {
    run bash -c "grep actions /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-a always,exit -F arch=b64 -C euid!=uid -F euid=0 -Fauid>=1000 -F auid!=4294967295 -S execve -k actions"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b32 -C euid!=uid -F euid=0 -Fauid>=1000 -F auid!=4294967295 -S execve -k actions"* ]]
    done
    run bash -c "auditctl -l | grep actions"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -F auid>=1000 -F auid!=-1 -F key=actions"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b32 -S execve -C uid!=euid -F euid=0 -F auid>=1000 -F auid!=-1 -F key=actions"* ]]
    done
}

@test "4.1.16 Ensure kernel module loading and unloading is collected (Automated)" {
    run bash -c "grep modules /etc/audit/rules.d/*.rules"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-w /sbin/insmod -p x -k modules"* ]] ||
        [[ "$current_line" == *"-w /sbin/rmmod -p x -k modules"* ]] ||
        [[ "$current_line" == *"-w /sbin/modprobe -p x -k modules"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b64 -S init_module -S delete_module -k modules"* ]]
    done
    run bash -c "auditctl -l | grep modules"
    [ "$status" -eq 0 ]
    for current_line in "${lines[*]}"
    do
        [[ "$current_line" == *"-w /sbin/insmod -p x -k modules"* ]] ||
        [[ "$current_line" == *"-w /sbin/rmmod -p x -k modules"* ]] ||
        [[ "$current_line" == *"-w /sbin/modprobe -p x -k modules"* ]] ||
        [[ "$current_line" == *"-a always,exit -F arch=b64 -S init_module,delete_module -F key=modules"* ]]
    done
}

@test "4.1.17 Ensure the audit configuration is immutable (Automated)" {
    run bash -c "grep \"^\s*[^#]\" /etc/audit/audit.rules | tail -1"
    [ "$status" -eq 0 ]
    [ "$output" = "-e 2" ]
}