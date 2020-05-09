#!/bin/sh

# Buildout Pop!_OS, and Ubuntu derivative.

. common/common
. common/setup_ssh
. common/immutabledesktop

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
    echo "rory-mac" | sudo tee /etc/hostname || exit_error "Cannot write to /etc/hostname"
    sudo sed -i 's/127.0.1.1.*/127.0.1.1  rory-mac.localdomain  rory-mac/' /etc/hosts || exit_error "Could not update /etc/hosts"
    echo "Hostname set!"
    echo ""
    echo "PLEASE REBOOT, THEN CONTINUE!"
  fi
}

os_update() {
  sudo apt-get -y update
  sudo apt-get -y dist-upgrade
}


### MAIN CODE Here

popos_check || error_exit "PopOS Not detected.  Script only tested on Pop!_OS 20.04"
is_root && error_exit "Please run this script as your regular user"

h1 "Check/Set Hostname"
set_hostname || error_exit "Unable to set hostname"
h1 "Setup SSH"
setup_ssh
h1 "Update OS"
os_update || error_exit "Issue updating OS"
h1 "Install ansible"
install_ansible || error_exit "Error installing ansible"
h1 "Clone immutabledesktop repo"
immutable_repo || error_exit "Could not clone the immutable desktop repo"
