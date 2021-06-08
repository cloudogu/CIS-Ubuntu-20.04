#!/usr/bin/env bats

@test "1.8.1 Ensure GNOME Display Manager is removed (Manual)" {
    run bash -c "dpkg -s gdm3 | grep -E '(Status:|not installed)'"
    [ "$status" -eq 1 ]
}

@test "1.8.2 Ensure GDM login banner is configured (Automated)" {
    if dpkg -s gdm3; then
        run bash -c "cat /etc/gdm3/greeter.dconf-defaults"
        [ "$status" -eq 0 ]
        [[ "$output" = "[org/gnome/login-screen]"* ]]
        [[ "$output" = *"banner-message-enable=true"* ]]
        [[ "$output" = *"banner-message-text="* ]]
    fi
}

@test "1.8.3 Ensure disable-user-list is enabled (Automated)" {
    run bash -c "grep -E '^\s*disable-user-list\s*=\s*true\b' /etc/gdm3/greeter.dconf-defaults"
    [ "$status" -eq 0 ]
}

@test "1.8.4 Ensure XDCMP is not enabled (Automated)" {
    run bash -c "grep -Eis '^\s*Enable\s*=\s*true' /etc/gdm3/custom.conf"
    [ "$status" -ne 0 ]
    [[ "$output" = "" ]]
}