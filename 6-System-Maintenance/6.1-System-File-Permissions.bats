#!/usr/bin/env bats

@test "6.1.1 Audit system file permissions (Manual)" {
    skip "This audit has to be done manually"

    #verify packages via dpkg --verify <package name> until output is clean
}

@test "6.1.2 Ensure permissions on /etc/passwd are configured (Automated)" {
  run bash -c "stat /etc/passwd"
  [[ "$output" == *"Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)"* ]]
}

@test "6.1.3 Ensure permissions on /etc/passwd- are configured (Automated)" {
  run bash -c "stat /etc/passwd-"
  [[ "$output" == *"Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)"* ]]
}

@test "6.1.4 Ensure permissions on /etc/group are configured (Automated)" {
  run bash -c "stat /etc/group"
  [[ "$output" == *"Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)"* ]]
}

@test "6.1.5 Ensure permissions on /etc/group- are configured (Automated)" {
  run bash -c "stat /etc/group-"
  [[ "$output" == *"Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)"* ]]
}

@test "6.1.6 Ensure permissions on /etc/shadow are configured (Automated)" {
  run bash -c "stat /etc/shadow"
  [[ "$output" == *"Access: (0640/-rw-r-----)"* ]]
  [[ "$output" == *"Uid: (    0/    root) "* ]]
  # both root and shadow are regarded as safe
  [[ "$output" == *"Gid: (   42/  shadow)"* || "$output" == *"Gid: (    0/    root)"* ]]
}

@test "6.1.7 Ensure permissions on /etc/shadow- are configured (Automated)" {
  run bash -c "stat /etc/shadow-"
  [[ "$output" == *"Access: (0640/-rw-r-----)"* ]]
  [[ "$output" == *"Uid: (    0/    root) "* ]]
  # both root and shadow are regarded as safe
  [[ "$output" == *"Gid: (   42/  shadow)"* || "$output" == *"Gid: (    0/    root)"* ]]
}

@test "6.1.8 Ensure permissions on /etc/gshadow are configured (Automated)" {
  run bash -c "stat /etc/gshadow"
  [[ "$output" == *"Access: (0640/-rw-r-----)"* ]]
  [[ "$output" == *"Uid: (    0/    root) "* ]]
  # both root and shadow are regarded as safe
  [[ "$output" == *"Gid: (   42/  shadow)"* || "$output" == *"Gid: (    0/    root)"* ]]
}

@test "6.1.9 Ensure permissions on /etc/gshadow- are configured (Automated)" {
  run bash -c "stat /etc/gshadow-"
  [[ "$output" == *"Access: (0640/-rw-r-----)"* ]]
  [[ "$output" == *"Uid: (    0/    root) "* ]]
  # both root and shadow are regarded as safe
  [[ "$output" == *"Gid: (   42/  shadow)"* || "$output" == *"Gid: (   0/  root)"* ]]
}

@test "6.1.10 Ensure no world writable files exist (Automated)" {
  # must be run as root, otherwise files that are not accessible will be erroneously specified as a finding.
  run sudo bash -c " df --local -P | awk '{if (NR!=1) print \$6}' | xargs -I '{}' find '{}' -xdev -type f -perm -0002"
  [ "$status" -eq 0 ]
  [[ "$output" == "" ]]
}

@test "6.1.11 Ensure no unowned files or directories exist (Automated)" {
  # must be run as root, otherwise files that are not accessible will be erroneously specified as a finding.
  run sudo bash -c "df --local -P | awk {'if (NR!=1) print \$6'} | xargs -I '{}' find '{}' -xdev -nouser"
  [ "$status" -eq 0 ]
  [[ "$output" == "" ]]
}

@test "6.1.12 Ensure no ungrouped files or directories exist (Automated)" {
  # must be run as root, otherwise files that are not accessible will be erroneously specified as a finding.
  run sudo bash -c "df --local -P | awk '{if (NR!=1) print \$6}' | xargs -I '{}' find '{}' -xdev -nogroup"
  [ "$status" -eq 0 ]
  [[ "$output" == "" ]]
}

@test "6.1.13 Audit SUID executables (Manual)" {
  skip "This audit has to be done manually"
}

@test "6.1.14 Audit SGID executables (Manual)" {
  skip "This audit has to be done manually"
}