#!/bin/bash

function check_ipv6_is_disabled_via_grub_config() {
  local grub_config_check
  grub_config_check=$(grep "^\s*linux" /boot/grub/grub.cfg | grep -v "ipv6.disable=1")
  [ "$grub_config_check" = "" ]
}
