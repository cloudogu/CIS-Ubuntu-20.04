#!/usr/bin/env bats

@test "2.1.1.1 Ensure time synchronization is in use (Automated)" {
		# Checks if one of the time synchronization tools is available
		run bash -c "systemctl is-enabled systemd-timesyncd || dpkg -s chrony || dpkg -s ntp"
		[[ "$status" -eq 0 ]]
}

@test "2.1.1.2 Ensure systemd-timesyncd is configured (Automated)" {
		#It is recommended to use only one tool for time synchronization, be it ntp, chrony or the systemd-timesyncd service.
		#If systemd-timesyncd is the chosen tool, this test verifies that systemd-timesyncd is configured correctly

		run bash -c "dpkg -s ntp"
		[[ "${lines[0]}" == "dpkg-query: package 'ntp' is not installed and no information is available" ]]

		run bash -c "dpkg -s chrony"
		[[ "${lines[0]}" == "dpkg-query: package 'chrony' is not installed and no information is available" ]]

		run bash -c "systemctl is-enabled systemd-timesyncd.service"
		[[ "$output" = "enabled" ]]

		run bash -c "timedatectl status"
		[[ "${lines[4]}" == *"System clock synchronized: yes"* ]]
		[[ "${lines[5]}" == *"NTP service: active"* ]]
}

@test "2.1.1.3 Ensure chrony is configured (Automated)" {
		#It is recommended to use only one tool for time synchronization, be it ntp, chrony or the systemd-timesyncd service.
		#If chrony is the chosen tool, this test verifies that chrony is configured correctly

		run bash -c "dpkg -s ntp | grep -E '(Status:|not installed)'"
		[[ "${lines[0]}" == *"dpkg-query: package 'ntp' is not installed and no information is available"* ]]

		run bash -c "systemctl is-enabled systemd-timesyncd"
    [[ "$output" == *"masked"* ]]

		run bash -c "grep -E \"^(server|pool)\" /etc/chrony/chrony.conf"
		[ "$status" -eq 0 ]
		[[ "$output" == "server "* ]] || [[ "$output" == "pool "* ]]

		run bash -c "ps -ef | grep chronyd"
		[ "$status" -eq 0 ]
		[[ "$output" == "_chrony "*" /usr/sbin/chronyd"* ]]
}

@test "2.1.1.4 Ensure ntp is configured (Automated)" {
		#It is recommended to use only one tool for time synchronization, be it ntp, chrony or the systemd-timesyncd service.
		#If ntp is the chosen tool, this test verifies that ntp is configured correctly.

		run bash -c "dpkg -s chrony"
		[[ "${lines[0]}" == "dpkg-query: package 'chrony' is not installed and no information is available" ]]

		run bash -c "systemctl is-enabled systemd-timesyncd.service"
		[[ "$output" = "masked" ]]

		run bash -c "grep \"^restrict\" /etc/ntp.conf"
		[ "$status" -eq 0 ]
		[[ "$output" == *"restrict -4 default "*"kod"* ]]
		[[ "$output" == *"restrict -4 default "*"nomodify"* ]]
		[[ "$output" == *"restrict -4 default "*"notrap"* ]]
		[[ "$output" == *"restrict -4 default "*"nopeer"* ]]
		[[ "$output" == *"restrict -4 default "*"noquery"* ]]
		[[ "$output" == *"restrict -6 default "*"kod"* ]]
		[[ "$output" == *"restrict -6 default "*"nomodify"* ]]
		[[ "$output" == *"restrict -6 default "*"notrap"* ]]
		[[ "$output" == *"restrict -6 default "*"nopeer"* ]]
		[[ "$output" == *"restrict -6 default "*"noquery"* ]]
		# 2.2.1.4 may fail due to "-4" or "-6" not being present in conf file
		run bash -c "grep -E \"^(server|pool)\" /etc/ntp.conf"
		[ "$status" -eq 0 ]
		[[ "$output" == "server "* ]] || [[ "$output" == "pool "* ]]
		run bash -c "grep \"RUNASUSER=ntp\" /etc/init.d/ntp"
		[ "$status" -eq 0 ]
		[[ "$output" == "RUNASUSER=ntp" ]]
}

@test "2.1.2 Ensure X Window System is not installed (Automated)" {
		run bash -c "dpkg -l xserver-xorg*"
		[ "$status" -eq 1 ]
		[[ "$output" == *"no packages found matching xserver-xorg*" ]]
}

@test "2.1.3 Ensure Avahi Server is not installed (Automated)" {
		run bash -c "dpkg -s avahi-daemon | grep -E '(Status:|not installed)'"
    [[ "$output" == *"dpkg-query: package 'avahi-daemon' is not installed and no information is available"* ]]
}

@test "2.1.4 Ensure CUPS is not installed (Automated)" {
    run bash -c "dpkg -s cups | grep -E '(Status:|not installed)'"
    [[ "$output" == *"dpkg-query: package 'cups' is not installed and no information is available"* ]]
}

@test "2.1.5 Ensure DHCP Server is not installed (Automated)" {
    run bash -c "dpkg -s isc-dhcp-server | grep -E '(Status:|not installed)'"
    [[ "$output" == *"dpkg-query: package 'isc-dhcp-server' is not installed and no information is available"* ]]
}

@test "2.1.6 Ensure LDAP server is not installed (Automated)" {
    run bash -c "dpkg -s slapd | grep -E '(Status:|not installed)'"
    [[ "$output" == *"dpkg-query: package 'slapd' is not installed and no information is available"* ]]
}

@test "2.1.7 Ensure NFS is not installed (Automated)" {
    run bash -c "dpkg -s nfs-kernel-server | grep -E '(Status:|not installed)'"
    [[ "$output" == *"dpkg-query: package 'nfs-kernel-server' is not installed and no information is available"* ]]
}

@test "2.1.8 Ensure DNS Server is not installed (Automated)" {
    run bash -c "dpkg -s bind9 | grep -E '(Status:|not installed)'"
    [[ "$output" == *"dpkg-query: package 'bind9' is not installed and no information is available"* ]]
}

@test "2.1.9 Ensure FTP Server is not installed (Automated)" {
    run bash -c "dpkg -s vsftpd | grep -E '(Status:|not installed)'"
    [[ "$output" == *"dpkg-query: package 'vsftpd' is not installed and no information is available"* ]]
}

@test "2.1.10 Ensure HTTP server is not installed (Automated)" {
    run bash -c "dpkg -s apache2 | grep -E '(Status:|not installed)'"
    [[ "$output" == *"dpkg-query: package 'apache2' is not installed and no information is available"* ]]
}

@test "2.1.11 Ensure IMAP and POP3 server are not installed (Automated)" {
    run bash -c "dpkg -s dovecot-imapd dovecot-pop3d | grep -E '(Status:|not installed)'"
    [[ "$output" == *"dpkg-query: package 'dovecot-imapd' is not installed and no information is available"* ]]
    [[ "$output" == *"dpkg-query: package 'dovecot-pop3d' is not installed and no information is available"* ]]
}

@test "2.1.12 Ensure Samba is not installed (Automated)" {
    run bash -c "dpkg -s samba | grep -E '(Status:|not installed)'"
    [[ "$output" == *"dpkg-query: package 'samba' is not installed and no information is available"* ]]
}

@test "2.1.13 Ensure HTTP Proxy Server is not installed (Automated)" {
    run bash -c "dpkg -s squid | grep -E '(Status:|not installed)'"
    [[ "$output" == *"dpkg-query: package 'squid' is not installed and no information is available"* ]]
}

@test "2.1.14 Ensure SNMP Server is not installed (Automated)" {
    run bash -c "dpkg -s snmpd | grep -E '(Status:|not installed)'"
    [[ "$output" == *"dpkg-query: package 'snmpd' is not installed and no information is available"* ]]
}

@test "2.1.15 Ensure mail transfer agent is configured for local-only mode (Automated)" {
    # This test is displayed as passed even if no MTA has been configured (as long as no one else is listening on any
    # non-loopback address (127.0.0.1 or::1).
    run bash -c "ss -lntu | grep -E ':25\s' | grep -E -v '\s(127.0.0.1|::1):25\s'"
    [[ "$status" -eq 1 ]]
    [[ "$output" == "" ]]
}

@test "2.1.16 Ensure rsync service is not installed (Automated)" {
    run bash -c "dpkg -s rsync | grep -E '(Status:|not installed)'"
    [[ "$output" == *"dpkg-query: package 'rsync' is not installed and no information is available"* ]]
}

@test "2.1.17 Ensure NIS Server is not installed (Automated)" {
    run bash -c "dpkg -s nis | grep -E '(Status:|not installed)'"
    [[ "$output" == *"dpkg-query: package 'nis' is not installed and no information is available"* ]]
}