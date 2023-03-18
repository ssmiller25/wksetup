#!/bin/sh

# setupmac.sh: Updated 2023 for my persoanl workstation.  Some goals
#  - OUT OF BOX - Run from a pure Mac install.  Note use of plain Bourne shell (versus zsh)
#  - MINIMAL - should run everything from cloud or local k8s cluster that spins up 
#    immutable docker images
#  - IDEPOTENT - should be able to run this script as many times as needed, and have no side-effects

# For Debugging
#set -x

if [ -z "$MYHOSTNAME" ]; then
  MYHOSTNAME="rory-mac-2023"
fi

if [ -z "$MYDOMAIN" ]; then
  MYDOMAIN="r15cookie.lan"
fi

dir_exists() {
  DIRTOSEARCH=${1:?"Must pass command to cmd_exist"}
  test -d "${DIRTOSEARCH}"
}
cmd_exists() {
  CMDTOSEARCH=${1:?"Must pass command to cmd_exist"}
  command -v "${CMDTOSEARCH}" > /dev/null 2>&1
}
h1() {
  HEADER=${1:?"Must pass header"}
  echo ""
  echo "==================================="
  echo "   ${HEADER}"
  echo "==================================="
  echo ""
}

# MAIN

h1 "Verifing hostname"

if sudo scutil --get HostName >/dev/null 2>&1; then
  echo "Current Hostnames:"
  sudo scutil --get HostName 
  sudo scutil --get LocalHostName 
  sudo scutil --get ComputerName 
else
  echo "Setting hostname to ${MYHOSTNAME}"
  sudo scutil --set HostName ${MYHOSTNAME}.${MYDOMAIN}
  sudo scutil --set LocalHostName ${MYHOSTNAME}
  sudo scutil --set ComputerName ${MYHOSTNAME}
  dscacheutil -flushcache
  echo "Hostname change.  Reboot the machine, then run this script to continue"
  echo "Press enter to continue"
  read -r _
  exit 0
fi

h1 "Change shell to zsh"

if [ "$SHELL" = "/bin/zsh" ]; then
  echo "Already set to zshell, great!"
else
  chsh -s /bin/zsh
fi

h1 "Setup ssh-key"
if dir_exists "${HOME}/.ssh"; then
  echo "SSH config directory exists, assuming all is setup"
else
  echo "Generating security key for this system"
  ssh-keygen -b 4096
fi

h1 "Setup inital environment"
if ! dir_exists "${HOME}/tmp"; then
  echo "Making temp directory in home"
  mkdir "${HOME}"/tmp
fi

h1 "Install brew"
if cmd_exists brew; then
  echo "Brew already installed"
else
  echo "Installing brew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ${HOME}/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi



h1 "Install iTerm"
if dir_exists "/Applications/iTerm.app"; then
  echo "iTerm already installed"
else
  brew install --cask iterm2
fi

h1 "Install Brave"
if dir_exists "/Applications/Brave Browser.app"; then
  echo "Brave already installed"
else
  brew install cask brave-browser
fi

h1 "Installing jq"
if cmd_exists jq; then
  echo "jq exists"
else
  brew install jq
fi

h1 "Installing bitwarding"
if cmd_exists bw; then
  echo "Bitwarden exists"
else
  brew install bitwarden-cli
fi

h1 "Installing nmap"
if cmd_exists nmap; then
  echo "nmap exists"
else
  brew install nmap
fi

h1 "Install balenaEtcher for USB creation"
if dir_exists "/Applications/balenaEtcher.app"; then
  echo "Etcher already installed"
else
  brew install --cask balenaetcher
fi

h1 "Install Colima"
if cmd_exists colima; then
  echo "Colima exists"
else
  brew install colima
fi