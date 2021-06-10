#!/usr/bin/env bats

@test "5.2.1 Ensure sudo is installed (Automated)" {
    run bash -c "dpkg -s sudo"
    if [ "$status" -ne 0 ]; then
        run bash -c "dpkg -s sudo-ldap"
        [ "$status" -eq 0 ]
    fi
}

@test "5.2.2 Ensure sudo commands use pty (Automated)" {
    run bash -c "grep -Ei '^\s*Defaults\s+([^#]+,\s*)?use_pty(,\s+\S+\s*)*(\s+#.*)?$' /etc/sudoers /etc/sudoers.d/*"
    [ "$status" -eq 0 ]
}

@test "5.2.3 Ensure sudo log file exists (Automated)" {
    run bash -c "grep -Ei '^\s*Defaults\s+logfile=\S+' /etc/sudoers /etc/sudoers.d/*"
    [ "$status" -eq 0 ]
}
