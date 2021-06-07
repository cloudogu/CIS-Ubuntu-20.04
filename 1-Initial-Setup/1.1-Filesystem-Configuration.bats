#!/usr/bin/env bats

@test "1.1.1.1 Ensure mounting of cramfs filesystems is disabled (Automated)" {
    run bash -c "modprobe -n -v cramfs | grep -E '(cramfs|install)'"
    [ "$status" -eq 0 ]
    [ "$output" = "install /bin/true " ]
    run bash -c "lsmod | grep cramfs"
    [ "$status" -eq 1 ]
    [ "$output" = "" ]
}

@test "1.1.1.2 Ensure mounting of freevxfs filesystems is disabled (Automated)" {
    run bash -c "modprobe -n -v freevxfs | grep -E '(freevxfs|install)'"
    [ "$status" -eq 0 ]
    [ "$output" = "install /bin/true " ]
    run bash -c "lsmod | grep freevxfs"
    [ "$status" -eq 1 ]
    [ "$output" = "" ]
}

@test "1.1.1.3 Ensure mounting of jffs2 filesystems is disabled (Automated)" {
    run bash -c "modprobe -n -v jffs2 | grep -E '(jffs2|install)'"
    [ "$status" -eq 0 ]
    [ "$output" = "install /bin/true " ]
    run bash -c "lsmod | grep jffs2"
    [ "$status" -eq 1 ]
    [ "$output" = "" ]
}

@test "1.1.1.4 Ensure mounting of hfs filesystems is disabled (Automated)" {
    run bash -c "modprobe -n -v hfs| grep -E '(hfs|install)'"
    [ "$status" -eq 0 ]
    [ "$output" = "install /bin/true " ]
    run bash -c "lsmod | grep hfs"
    [ "$status" -eq 1 ]
    [ "$output" = "" ]
}

@test "1.1.1.5 Ensure mounting of hfsplus filesystems is disabled (Automated)" {
    run bash -c "modprobe -n -v hfsplus| grep -E '(hfsplus|install)'"
    [ "$status" -eq 0 ]
    [ "$output" = "install /bin/true " ]
    run bash -c "lsmod | grep hfsplus"
    [ "$status" -eq 1 ]
    [ "$output" = "" ]
}

@test "1.1.1.6 Ensure mounting of squashfs filesystems is disabled (Manual)" {
    run bash -c "modprobe -n -v squashfs | grep -E '(squashfs|install)'"
    [ "$status" -eq 0 ]
    [ "$output" = "install /bin/true" ]
    run bash -c "lsmod | grep squashfs"
    [ "$status" -eq 1 ]
    [ "$output" = "" ]
}

@test "1.1.1.7 Ensure mounting of udf filesystems is disabled (Automated)" {
    run bash -c "modprobe -n -v udf | grep -E '(udf|install)'"
    [ "$status" -eq 0 ]
    [ "$output" = "install /bin/true " ]
    run bash -c "lsmod | grep udf"
    [ "$status" -eq 1 ]
    [ "$output" = "" ]
}

@test "1.1.2 Ensure /tmp is configured (Automated)" {
    run bash -c "findmnt -n /tmp"
    [ "$status" -eq 0 ]
    [[ "$output" = *" on /tmp "* ]]
    local FSTAB=$(grep -E '\s/tmp\s' /etc/fstab | grep -E -v '^\s*#')
    local TMPMOUNT=$(systemctl is-enabled tmp.mount)
    [[ "$FSTAB" != "" ]] || [ "$TMPMOUNT" = "enabled" ]
}

@test "1.1.3 Ensure nodev option set on /tmp partition (Automated)" {
    run bash -c "findmnt -n /tmp | grep -v nodev"
    [ "$status" -eq 1 ]
    [ "$output" = "" ]
}

@test "1.1.4 Ensure nosuid option set on /tmp partition (Automated)" {
    run bash -c "findmnt -n /tmp | grep -v nosuid"
    [ "$status" -eq 1 ]
    [ "$output" = "" ]
}

@test "1.1.5 Ensure noexec option set on /tmp partition (Automated)" {
    run bash -c "findmnt -n /tmp | grep -v noexec"
    [ "$status" -eq 1 ]
    [ "$output" = "" ]
}

@test "1.1.6 Ensure /dev/shm is configured (Automated)" {
    run bash -c "findmnt -n /dev/shm"
    [ "$status" -eq 0 ]
    [[ "$output" = "/dev/shm "* ]]
}

@test "1.1.7 Ensure nodev option set on /dev/shm partition (Automated)" {
    run bash -c "findmnt -n /dev/shm | grep -v nodev"
    [ "$status" -eq 1 ]
    [ "$output" = "" ]
}

@test "1.1.8 Ensure nosuid option set on /dev/shm partition (Automated)" {
    run bash -c "findmnt -n /dev/shm | grep -v nosuid"
    [ "$status" -eq 1 ]
    [ "$output" = "" ]
}

@test "1.1.9 Ensure noexec option set on /dev/shm partition (Automated)" {
    run bash -c "findmnt -n /dev/shm | grep -v noexec"
    [ "$status" -eq 1 ]
    [ "$output" = "" ]
}

@test "1.1.10 Ensure separate partition exists for /var (Automated)" {
    run bash -c "findmnt /var"
    [ "$status" -eq 0 ]
    [[ "$output" = " /var "* ]]
}

@test "1.1.11 Ensure separate partition exists for /var/tmp (Automated)" {
    run bash -c "findmnt /var/tmp"
    [ "$status" -eq 0 ]
    [[ "$output" = "/var/tmp "* ]]
}

@test "1.1.12 Ensure /var/tmp partition includes the nodev option (Automated)" {
    run bash -c "findmnt -n /var/tmp | grep -v nodev"
    [ "$status" -eq 1 ]
    [ "$output" = "" ]
}

@test "1.1.13 Ensure /var/tmp partition includes the nosuid option (Automated)" {
    run bash -c "findmnt -n /var/tmp | grep -v nosuid"
    [ "$status" -eq 1 ]
    [ "$output" = "" ]
}

@test "1.1.14 Ensure /var/tmp partition includes the noexec option (Automated)" {
    run bash -c "findmnt -n /var/tmp | grep -v noexec"
    [ "$status" -eq 1 ]
    [ "$output" = "" ]
}

@test "1.1.15 Ensure separate partition exists for /var/log (Automated)" {
    run bash -c "findmnt /var/log"
    [ "$status" -eq 0 ]
    [[ "$output" = "/var/log "* ]]
}

@test "1.1.16 Ensure separate partition exists for /var/log/audit (Automated)" {
    run bash -c "findmnt /var/log/audit"
    [ "$status" -eq 0 ]
    [[ "$output" = "/var/log/audit "* ]]
}

@test "1.1.17 Ensure separate partition exists for /home (Automated)" {
    run bash -c "findmnt /home"
    [ "$status" -eq 0 ]
    [[ "$output" = "/home "* ]]
}

@test "1.1.18 Ensure /home partition includes the nodev option (Automated)" {
    run bash -c "findmnt -n /home | grep -v nodev"
    [ "$status" -eq 1 ]
    [ "$output" = "" ]
}

@test "1.1.19 Ensure nodev option set on removable media partitions (Manual)" {
    skip "This audit has to be done manually"
}

@test "1.1.20 Ensure nosuid option set on removable media partitions (Manual)" {
    skip "This audit has to be done manually"
}

@test "1.1.21 Ensure noexec option set on removable media partitions (Manual)" {
    skip "This audit has to be done manually"
}

@test "1.1.22 Ensure sticky bit is set on all world-writable directories (Automated)" {
    run bash -c "df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "1.1.23 Disable Automounting (Automated)" {
    run bash -c "systemctl is-enabled autofs"
    if [ "$status" -eq 0 ]; then
        [ "$output" != "enabled" ]
    fi
}

@test "1.1.24 Disable USB Storage (Automated)" {
    run bash -c "modprobe -n -v usb-storage"
    [ "$status" -eq 0 ]
    [ "$output" = "install /bin/true " ]
    run bash -c "lsmod | grep usb-storage"
    [ "$status" -eq 1 ]
    [ "$output" = "" ]
}
