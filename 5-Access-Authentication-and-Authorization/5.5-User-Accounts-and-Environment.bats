#!/usr/bin/env bats

load 5.5.4-helper
load 5.5.5-helper

@test "5.5.1.1 Ensure minimum days between password changes is configured (Automated)" {
    run bash -c "grep PASS_MIN_DAYS /etc/login.defs | grep --invert-match \"\#\""
    [ "$status" -eq 0 ]
    MINDAYS=(${output//PASS_MIN_DAYS/ }) # get the number from the string
    [[ "$MINDAYS" -gt 0 ]]
    run bash -c "awk -F : '(/^[^:]+:[^!*]/ && \$4 < 1){print \$1 \" \" \$4}' /etc/shadow"
    [ "$status" -eq 0 ]
    [[ "$output" == "" ]]
}

@test "5.5.1.2 Ensure password expiration is 365 days or less (Automated)" {
    run bash -c "grep PASS_MAX_DAYS /etc/login.defs | grep --invert-match \"\#\""
    [ "$status" -eq 0 ]
    [[ "$output" != "" ]]
    MAXDAYS=(${output//PASS_MAX_DAYS/ }) # get the number from the string
    [[ "$MAXDAYS" -lt 366 ]]
    run bash -c "awk -F: '(/^[^:]+:[^!*]/ && (\$5>365||\$5~/([0-1]|-1)/)){print \$1 \" \" \$5}' /etc/shadow"
    [ "$status" -eq 0 ]
    [[ "$output" == "" ]]
}

@test "5.5.1.3 Ensure password expiration warning days is 7 or more (Automated)" {
    run bash -c "grep PASS_WARN_AGE /etc/login.defs | grep --invert-match \"\#\""
    [ "$status" -eq 0 ]
    [[ "$output" != "" ]]
    WARNAGE=(${output//PASS_WARN_AGE/ }) # get the number from the string
    [[ "$WARNAGE" -gt 6 ]]
    run bash -c " awk -F: '(/^[^:]+:[^!*]/ && \$6<7){print \$1 \" \" \$6}' /etc/shadow"
    [ "$status" -eq 0 ]
    [[ "$output" = "" ]]
}

@test "5.5.1.4 Ensure inactive password lock is 30 days or less (Automated)" {
    run bash -c "useradd -D | grep INACTIVE"
    [ "$status" -eq 0 ]
    [[ "$output" != "" ]]
    INACTIVE=(${output//INACTIVE=/ }) # get the number from the string
    [[ "$INACTIVE" != -1 ]]
    [[ "$INACTIVE" -lt 31 ]]
    run bash -c " awk -F: '(/^[^:]+:[^!*]/ && (\$7~/(-1)/ || \$7>30)){print \$1 \" \" \$7}' /etc/shadow"
    [ "$status" -eq 0 ]
    [[ "$output" = "" ]]
}

@test "5.5.1.5 Ensure all users last password change date is in the past (Automated)" {
    run bash -c 'awk -F: '\''{print $1}'\'' /etc/shadow | while read -r usr; do [[ $(date --date="$(chage --list "$usr" | grep '\''^Last password change'\'' | cut -d: -f2)" +%s) > $(date +%s) ]] && echo "$usr last password change was: $(chage --list "$usr" | grep '\''^Last password change'\'' | cut -d: -f2)"; done'
    [[ "$output" == "" ]]
}

@test "5.5.2 Ensure system accounts are secured (Automated)" {
    run bash -c "awk -F: '\$1!~/(root|sync|shutdown|halt|^\+)/ && \$3<'\"\$(awk '/^\s*UID_MIN/{print \$2}' /etc/login.defs)\"' && \$7!~/((\/usr)?\/sbin\/nologin)/ && \$7!~/(\/bin)?\/false/ {print}' /etc/passwd"
    [[ "$output" == "" ]]
    run bash -c "awk -F: '(\$1!~/(root|^\+)/ && \$3<'\"\$(awk '/^\s*UID_MIN/{print \$2}' /etc/login.defs)\"') {print \$1}' /etc/passwd | xargs -I '{}' passwd -S '{}' | awk '(\$2!~/LK?/) {print \$1}'"
    [[ "$output" == "" ]]
}

@test "5.5.3 Ensure default group for the root account is GID 0 (Automated)" {
    run bash -c "grep "^root:" /etc/passwd | cut -f4 -d:"
    [ "$status" -eq 0 ]
    [[ "$output" == "0" ]]
}

@test "5.5.4 Ensure default user umask is 027 or more restrictive (Automated)" {
    run check_default_umask
    [[ "$output" == "Default user umask is set" ]]
    run check_for_less_restrictive_umask
    [[ "$output" == "" ]]
}

@test "5.5.5 Ensure default user shell timeout is 900 seconds or less (Automated)" {
    run check_timeout_settings
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASSED"*"TMOUT is configured in: "* ]]
}

@test "5.6 Ensure root login is restricted to system console (Manual)" {
    skip "This audit has to be done manually"
}

@test "5.7 Ensure access to the su command is restricted (Automated)" {
    run bash -c "grep pam_wheel.so /etc/pam.d/su"
    [ "$status" -eq 0 ]
    [[ "$output" == *"auth required pam_wheel.so use_uid group="* ]]
    filtered_output=$(echo "$output" | grep 'auth required pam_wheel.so use_uid group=')
    local GROUP=(${filtered_output//auth required pam_wheel.so use_uid group=/ }) # get the group name from the string
    [[ "$GROUP" != "" ]]
    run bash -c "grep $GROUP /etc/group"
    echo "INFO: op -> $output"
    [ "$status" -eq 0 ]
    [[ "$output" == "$GROUP:"*":"*":" ]]
}