#!/usr/bin/env bats

@test "1.3.1 Ensure AIDE is installed (Automated)" {
    run bash -c "dpkg -s aide | grep -E '(Status:|not installed)'"
    [ "$status" -eq 0 ]
    [[ "$output" = "Status: install ok installed" ]]
    run bash -c "dpkg -s aide-common | grep -E '(Status:|not installed)'"
    [ "$status" -eq 0 ]
    [[ "$output" = "Status: install ok installed" ]]
}

@test "1.3.2 Ensure filesystem integrity is regularly checked (Automated)" {
    local check_enabled
    local check_status

    if systemctl is-enabled aidecheck.service; then
        check_enabled=$(systemctl is-enabled aidecheck.service)
        check_status=$(systemctl status aidecheck.service)
    else
        check_enabled=false
        check_status=false
    fi

    local timer_enabled
    local timer_status
    if systemctl is-enabled aidecheck.timer; then
        timer_enabled=$(systemctl is-enabled aidecheck.timer)
        timer_status=$(systemctl status aidecheck.timer)
    else
        timer_enabled=false
        timer_status=false
    fi;

    local aide_in_any_cron
    aide_in_any_cron=$(grep -Ers '^([^#]+\s+)?(\/usr\/s?bin\/|^\s*)aide(\.wrapper)?\s(--check|\$AIDEARGS)\b' /etc/cron.* /etc/crontab /var/spool/cron/)

    [ "$check_enabled" != false ] && [ "$check_status" != false ] &&
     [ "$timer_enabled" != false ] && [ "$timer_status" != false ] \
      || [ "$aide_in_any_cron" ]
}

