#!/usr/bin/env bats

@test "1.9 Ensure updates, patches, and additional security software are installed (Manual)" {
    (apt -s upgrade | grep "^0 upgraded")
    (apt -s upgrade | grep -E "[[:space:]]0 newly installed")
    (apt -s upgrade | grep -E "[[:space:]]0 to remove")
    (apt -s upgrade | grep -E "[[:space:]]0 not upgraded")
}
