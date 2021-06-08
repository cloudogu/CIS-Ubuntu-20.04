#!/usr/bin/env bats

@test "2.3 Ensure nonessential services are removed or masked (Manual)" {
    skip "This audit has to be done manually"

    # Run the following command and review ports/network-configuration:
    # lsof -i -P -n | grep -v "(ESTABLISHED)"
}
