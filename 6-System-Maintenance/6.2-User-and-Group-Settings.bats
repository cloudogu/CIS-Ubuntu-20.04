#!/usr/bin/env bats

@test "6.2.1 Ensure accounts in /etc/passwd use shadowed passwords (Automated)" {
  run "$BATS_TEST_DIRNAME"/6.2.1.sh
  [ "$status" -eq 0 ] # returns nothing
  [[ "$output" == "" ]]
}

@test "6.2.2 Ensure password fields are not empty (Automated)" {
  # must be run as root, otherwise files that are not accessible will be erroneously specified as a finding.
  run sudo "$BATS_TEST_DIRNAME"/6.2.2.sh
  [ "$status" -eq 0 ] # returns nothing
  [[ "$output" == "" ]]
}

@test "6.2.3 Ensure all groups in /etc/passwd exist in /etc/group (Automated)" {
  run sudo "$BATS_TEST_DIRNAME"/6.2.3.sh
  [ "$status" -eq 0 ]
  [[ "$output" == "" ]]
}

@test "6.2.4 Ensure all users' home directories exist (Automated)" {
  run "$BATS_TEST_DIRNAME"/6.2.4.sh
  [ "$status" -eq 0 ]
  [[ "$output" == "" ]]
}

@test "6.2.5 Ensure users own their home directories (Automated)" {
  run "$BATS_TEST_DIRNAME"/6.2.5.sh
  [ "$status" -eq 0 ]
  [[ "$output" == "" ]]
}

@test "6.2.6 Ensure users' home directories permissions are 750 or more restrictive (Automated)" {
  run "$BATS_TEST_DIRNAME"/6.2.6.sh
  [ "$status" -eq 0 ]
  [[ "$output" == "" ]]
}

@test "6.2.7 Ensure users' dot files are not group or world writable (Automated)" {
  run "$BATS_TEST_DIRNAME"/6.2.7.sh
  [ "$status" -eq 0 ]
  [[ "$output" == "" ]]
}

@test "6.2.8 Ensure no users have .netrc files (Automated)" {
  run "$BATS_TEST_DIRNAME"/6.2.8.sh
  [ "$status" -eq 0 ]
  [[ "$output" == "" ]]
}

@test "6.2.9 Ensure no users have .forward files (Automated)" {
  run "$BATS_TEST_DIRNAME"/6.2.9.sh
  [ "$status" -eq 0 ]
  [[ "$output" == "" ]]
}

@test "6.2.10 Ensure no users have .rhosts files (Automated)" {
  run "$BATS_TEST_DIRNAME"/6.2.10.sh
  [ "$status" -eq 0 ]
  [[ "$output" == "" ]]
}

@test "6.2.11 Ensure root is the only UID 0 account (Automated)" {
  run bash -c "awk -F: '(\$3 == 0) { print \$1 }' /etc/passwd"
  [[ "$output" == "root" ]]
  [ "$status" -eq 0 ]

  run bash -c "awk -F: '(\$3 == 0) { print \$1 }' /etc/passwd | wc -l"
  [[ "$output" == "1" ]]
  [ "$status" -eq 0 ]
}

@test "6.2.12 Ensure root PATH Integrity (Automated)" {
  run "$BATS_TEST_DIRNAME"/6.2.12.sh
  [ "$status" -eq 0 ]
  [[ "$output" == "" ]]
}

@test "6.2.13 Ensure no duplicate UIDs exist (Automated)" {
  run "$BATS_TEST_DIRNAME"/6.2.13.sh
  [ "$status" -eq 0 ]
  [[ "$output" == "" ]]
}

@test "6.2.14 Ensure no duplicate GIDs exist (Automated)" {
  run "$BATS_TEST_DIRNAME"/6.2.14.sh
  [ "$status" -eq 0 ]
  [[ "$output" == "" ]]
}

@test "6.2.15 Ensure no duplicate user names exist (Automated)" {
  run "$BATS_TEST_DIRNAME"/6.2.15.sh
  [ "$status" -eq 0 ]
  [[ "$output" == "" ]]
}

@test "6.2.16 Ensure no duplicate group names exist (Automated)" {
  run "$BATS_TEST_DIRNAME"/6.2.16.sh
  [ "$status" -eq 0 ]
  [[ "$output" == "" ]]
}

@test "6.2.17 Ensure shadow group is empty (Automated)" {
  run bash -c 'awk -F: '\''($1=="shadow") {print $NF}'\'' /etc/group'
  echo "$output"
  [ "$status" -eq 0 ]
  [[ "$output" == "" ]]

  run "$BATS_TEST_DIRNAME"/6.2.17.sh
  [ "$status" -eq 0 ]
  [[ "$output" == "" ]]
}