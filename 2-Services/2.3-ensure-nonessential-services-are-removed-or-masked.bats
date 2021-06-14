#!/usr/bin/env bats

@test "2.3 Ensure nonessential services are removed or masked (Manual)" {
    skip "This audit has to be done manually"

    # Run the following audit command:
    # lsof -i -P -n | grep -v "(ESTABLISHED)"
    # Review the output to ensure that all services listed are required on the system. If a listed
    # service is not required, remove the package containing the service. If the package
    # containing a non-essential service is required, stop and mask the non-essential service.
}
