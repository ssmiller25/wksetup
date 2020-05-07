#!/bin/sh

# Buildout Pop!_OS, and Ubuntu derivative.

. common/common

popos_check() {
  if [ -r /etc/os-release ]; then
    . /etc/os-release
    if [ "${NAME}" = 'Pop!_OS' ] && [ "${VERSION}" = "20.04" ] ;then
      return 0
    fi 
  else
    return 1
  fi
}

set_hostname() {
  echo ""
  if [ "$(hostname)" = "rory-mac" ]; then
    echo "Hostname already setup"
  else
    echo "rory-mac" > /etc/hostname || exit_error "Cannot write to /etc/hostname"
    sed -i 's/127.0.1.1.*/127.0.1.1  rory-mac.localdomain  rory-mac/' /etc/hosts || exit_error "Could not update /etc/hosts"
    echo "Hostname set!"
    echo ""
    echo "PLEASE REBOOT, THEN CONTINUE!"
  fi
}

os_update() {
  apt-get -y update
  apt-get -y dist-upgrade
}

install_ansible() {
  return 0

}

### MAIN CODE Here

popos_check || error_exit "PopOS Not detected.  Script only tested on Pop!_OS 20.04"
is_root || error_exit "Please run this script as root: sudo ${0}"

h1 "Check/Set Hostname"
set_hostname || error_exit "Unable to set hostname"
h1 "Update OS"
os_update || error_exit "Issue updating OS"
h1 "Install ansible"
install_ansible || error_exit "Error installing ansible"
