#!/usr/bin/env bats

@test "1.4.1 Ensure permissions on bootloader config are not overridden (Automated)" {
    run bash -c 'grep -E '\''^\s*chmod\s+[0-7][0-7][0-7]\s+\$\{grub_cfg\}\.new'\'' -A 1 -B1 /usr/sbin/grub-mkconfig'
    [ "$status" -eq 0 ]
    [[ "$output" == 'if [ "x${grub_cfg}" != "x" ]; then'* ]]
    [[ "$output" == *'  chmod 400 ${grub_cfg}.new || true'* ]]
    [[ "$output" == *"fi" ]]
}

@test "1.4.2 Ensure bootloader password is set (Automated)" {
    run bash -c "grep \"^set superusers\" /boot/grub/grub.cfg"
    [ "$status" -eq 0 ]
    [[ "$output" == "set superusers="* ]]
    run bash -c "grep \"^password\" /boot/grub/grub.cfg"
    [ "$status" -eq 0 ]
    [[ "$output" == "password_pbkdf2 "* ]]
}

@test "1.4.3 Ensure permissions on bootloader config are configured (Automated)" {
    run bash -c "stat /boot/grub/grub.cfg"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Access: (0400"* ]]
    [[ "$output" == *"Uid: (    0/    root)"* ]]
    [[ "$output" == *"Gid: (    0/    root)"* ]]
}

@test "1.4.4 Ensure authentication required for single user mode (Automated)" {
    run bash -c 'grep -Eq '\''^root:\$[0-9]'\'' /etc/shadow || echo "root is locked"'
    [ "$output" = "" ]
}
