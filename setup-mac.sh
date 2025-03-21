#!/bin/sh

# setupmac.sh: Updated 2023 for my persoanl workstation.  Some goals
#  - OUT OF BOX - Run from a pure Mac install.  Note use of plain Bourne shell (versus zsh)
#  - MINIMAL - should run everything from cloud or local k8s cluster that spins up 
#    immutable docker images
#  - IDEPOTENT - should be able to run this script as many times as needed, and have no side-effects

# For Debugging
#set -x

if [ -z "$MYHOSTNAME" ]; then
  MYHOSTNAME="rory-mac-2025"
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

h1 "Always show display preferences in icon bar"
defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.displays" -bool true && killall SystemUIServer

h1 "Install brew"
if cmd_exists brew; then
  echo "Brew already installed"
else
  echo "Installing brew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # shellcheck disable=SC2016,SC2086
  (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ${HOME}/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi



h1 "Install iTerm"
if dir_exists "/Applications/iTerm.app"; then
  echo "iTerm already installed"
else
  brew install --cask iterm2
fi

h1 "Installing jq"
if cmd_exists jq; then
  echo "jq exists"
else
  brew install jq
fi

h1 "Installing bitwarden"
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

h1 "Installing ipcalc"
if cmd_exists ipcalc; then
  echo "ipcalc exists"
else
  brew install ipcalc
fi

h1 "Install balenaEtcher for USB creation"
if dir_exists "/Applications/balenaEtcher.app"; then
  echo "Etcher already installed"
else
  brew install --cask balenaetcher
fi

h1 "Install Kubernetes Utilties"
if cmd_exists kubectl; then
  echo "Kubernetes Utilities exists"
else
  brew install kubectl helm
fi


# h1 "Install Docker for Desktop"
# # Far more efficient than co-lima
# if dir_exists "/Applications/Docker.app"; then
#   echo "Docekr Desktop already installed"
# else
#   brew install --cask docker
# fi

h1 "Install Slack"
if dir_exists "/Applications/Slack.app"; then
  echo "Slack already installed"
else
  brew install --cask slack
fi

h1 "Install Discord"
if dir_exists "/Applications/Discord.app"; then
  echo "Discord already installed"
else
  brew install --cask discord
fi

h1 "Install Rectangle"
if dir_exists "/Applications/Rectangle.app"; then
  echo "Rectangle already installed"
else
  brew install --cask rectangle
fi

h1 "Install Visual Studio Code"
if dir_exists "/Applications/Visual Studio Code.app"; then
  echo "VSCode already installed"
else
  brew install --cask visual-studio-code
fi

h1 "Install DBeaver"
if dir_exists "/Applications/DBeaver.app"; then
  echo "DBeaver already installed"
else
  brew install --cask dbeaver-community
fi

h1 "Install gh cli"
if cmd_exists gh; then
  echo "Github CLI exists"
else
  brew install gh
fi

h1 "Install wireguard"
if cmd_exists wg-quick; then
  echo "Wireguard exists"
else
  brew install wireguard-tools
fi


h1 "Install Obsidian"
if dir_exists "/Applications/Obsidian.app"; then
  echo "Obsidian exists"
else
  brew install --cask obsidian
fi

h1 "Install Zoom"
if dir_exists "/Applications/zoom.us.app"; then
  echo "Zoom exists"
else
  brew install --cask zoom
fi

h1 "Install Ungoogled Chromium"
if dir_exists "/Applications/Chromium.app"; then
  echo "Chromium exists"
else
  brew install --cask eloston-chromium
fi

h1 "Install civo"
if cmd_exists civo; then
  echo "Civo CLI exists"
else
  brew tap civo/tools
  brew install civo
fi

h1 "Install DevPod"
if cmd_exists devpod; then
  echo "Devpod exists"
else
  brew install --cask devpod
fi

h1 "Install Podman Desktop"
if cmd_exists podman; then
  echo "Podman exists"
else
  brew install podman
  brew install --cask podman-desktop
fi

h1 "Setup VSCode Desktop"
echo "Follow https://geekingoutpodcast.substack.com/p/running-dev-containers-locally-with"
# Fro docker-in-docker setups, make sure the following is in the devcontainer.json

# "remoteEnv": {
#     "PODMAN_USERNS": "keep-id"
# },
# "containerUser": "vscode"


