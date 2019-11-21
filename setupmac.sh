#!/bin/sh

#set -x

dir_exists() {
  DIRTOSEARCH=${1:?"Must pass command to cmd_exist"}
  test -d ${DIRTOSEARCH}
}
cmd_exists() {
  CMDTOSEARCH=${1:?"Must pass command to cmd_exist"}
  which ${CMDTOSEARCH} > /dev/null 2>&1
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

h1 "Change hostname"

if sudo scutil --get HostName >/dev/null 2>&1; then
  echo "Current Hostnames:"
  sudo scutil --get HostName 
  sudo scutil --get LocalHostName 
  sudo scutil --get ComputerName 
else
  echo "Setting hostname to rory-mac"
  sudo scutil --set HostName rory-mac.r15cookie.lan
  sudo scutil --set LocalHostName rory-mac
  sudo scutil --set ComputerName rory-mac
  dscacheutil -flushcache
  echo "Hostname change.  Reboot the machine, then run this script to continue"
  echo "Press enter to continue"
  read nothing
  exit 0
fi

h1 "Change shell to zsh"

if [ "$SHELL" == "/bin/zsh" ]; then
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

h1 "Setup inital zsh environment"
if ! dir_exists "${HOME}/tmp"; then
  echo "Making temp directory in home"
  mkdir ${HOME}/tmp
fi


  # Create directory to run individual components  
if dir_exists "${HOME}/.zshrc"; then
  mkdir ${HOME}/.zshrc.d
fi
# ALWAYS syncing startup files and directories.  Will leave anything in 
#  There already alone

cp zshrc ${HOME}/.zshrc
chmod 755 ${HOME}/.zshrc
cp zshrc.d/* ${HOME}/.zshrc.d/


h1 "Install iTerm"
if dir_exists "/Applications/iTerm.app"; then
  echo "Good, already installed"
else
  echo "Go to https://www.iterm2.com/downloads.html and download/install"
  echo "  iterm2 (drag/drop into Application)"
fi

h1 "Install brew"
if cmd_exists brew; then
  echo "Brew already installed"
else
  echo "Installing brew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

h1 "Install docker and prereq"
if cmd_exists docker; then
  echo "Docker already installed"
else
  # Process from https://medium.com/@yutafujii_59175/a-complete-one-by-one-guide-to-install-docker-on-your-mac-os-using-homebrew-e818eb4cfc3
  echo "Installing docker and extras"
  brew install docker docker-machine
  brew cask install virtualbox
  echo "========"
  echo "Possibly need to permit virtualbox to run. Check system preference"
  echo "Under Security & Privacy, and General"
  echo "Press enter to continue"
  echo "========"
  read nothing
  # When I last tested, had to redo install after accpeting permission change
  brew cask install virtualbox
  docker-machine create --driver virtualbox default
  docker-machine env default
  eval "$(docker-machine env default)"

  # During first install, had to manually bring up docker-machien with a 
  #  `docker-machine rm default` command, then rerunning the create and env
  #  commands above
fi

h1 "Installing jq"
if cmd_exists jq; then
  echo "jq exists"
else
  echo "Installing jq"
  brew install jq
fi

h1 "Installing bitwarding"
  if cmd_exists bw; then
    echo "Bitwarden exists"
  else
    echo "Installing Bitwarden (cli)"
    brew install bitwarden-cli
fi
