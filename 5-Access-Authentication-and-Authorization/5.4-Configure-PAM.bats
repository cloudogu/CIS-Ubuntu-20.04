#!/usr/bin/env bats

@test "5.4.1 Ensure password creation requirements are configured (Automated)" {
    local MINLENGTH=$(grep '^\s*minlen\s*' /etc/security/pwquality.conf)
    MINLENGTH=(${MINLENGTH//minlen = / }) # get the number from the string
    local PWQUALITY=$(grep '^\s*minclass\s*' /etc/security/pwquality.conf)
    PWQUALITY=(${PWQUALITY//minclass = / }) # get the number from the string
    if [[ "$MINLENGTH" -lt 14 ]] || [[ "$PWQUALITY" -lt 4 ]]; then
        local CREDITPWQUALITY=$(grep -E '^\s*[duol]credit\s*' /etc/security/pwquality.conf)
        [[ "$CREDITPWQUALITY" != "" ]]
        [[ "$CREDITPWQUALITY" == *"dcredit = -1"* ]]
        [[ "$CREDITPWQUALITY" == *"ucredit = -1"* ]]
        [[ "$CREDITPWQUALITY" == *"lcredit = -1"* ]]
        [[ "$CREDITPWQUALITY" == *"ocredit = -1"* ]]
        local RETRIES=$(grep -E '^\s*password\s+(requisite|required)\s+pam_pwquality\.so\s+(\S+\s+)*retry=[1-3]\s*(\s+\S+\s*)*(\s+#.*)?$' /etc/pam.d/common-password)
        [[ "$RETRIES" == "password"*"requisite"*"retry="[0-3] ]]
    fi
}

@test "5.4.2 Ensure lockout for failed password attempts is configured (Automated)" {
    run bash -c "grep \"pam_tally2\" /etc/pam.d/common-auth"
    [ "$status" -eq 0 ]
    [[ "$output" == "auth required pam_tally2.so onerr=fail audit silent deny=5 unlock_time=900" ]]
    run bash -c "grep -E \"pam_(tally2|deny)\.so\" /etc/pam.d/common-account"
    [ "$status" -eq 0 ]
    [[ "$output" == *"account"*"requisite"*"pam_deny.so"* ]]
    [[ "$output" == *"account"*"required"*"pam_tally2.so"* ]]
}

@test "5.4.3 Ensure password reuse is limited (Automated)" {
    local REMEMBER=$(grep -E '^password\s+required\s+pam_pwhistory.so' /etc/pam.d/common-password)
    [[ "$REMEMBER" != "" ]]
    REMEMBER=(${REMEMBER//password required pam_pwhistory.so remember=/ }) # get the number from the string
    [[ "$REMEMBER" -gt 4 ]]
}

@test "5.4.4 Ensure password hashing algorithm is SHA-512 (Automated)" {
    run bash -c "grep -E '^\s*password\s+(\S+\s+)+pam_unix\.so\s+(\S+\s+)*sha512\s*(\S+\s*)*(\s+#.*)?$' /etc/pam.d/common-password"
    [ "$status" -eq 0 ]
    [[ "$output" == "password"*"[success=1 default=ignore]"*"sha512"* ]]
}