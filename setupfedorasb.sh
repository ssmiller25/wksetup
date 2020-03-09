#!/bin/sh
#
# Setup for Fedora Silverblue
#

#set -x

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
manual_step() {
  title=${1:?"Must pass step title"}
  inst=${2:?"Must pass instructions for manual step"}

  echo ""
  echo "### ${title}"
  echo ""
  echo ${inst}"
  echo ""
}

flatpak_install() {
  package=${1:?"Must pass flatpak install package"}
  if flatpak info ${package} > /dev/null 2>&1; then
    echo "${package} already installed"
  else
    flatpac -y install ${package}
  fi
}
manual_step "Sign Into Firefox Central" "Open up firefox and log into firefox account"

# For flathub, eventually migration to `flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo` command
manual_step "Setup Flathub" "Go to https://flatpak.org/setup/Fedora/"

# Set hostname
h1 "Setting hostname"
wkhostname=rory-mac.r15cookie.lan
if [ "${HOSTNAME} -ne ${wkhostname} ]
  sudo hostnamectl set-hostname ${wkhostname}
else
  echo "Hostname already set"
fi

h1 "Checking for Update"
if rpm-ostree upgrade --check | grep -q AvailableUpdate; then
  manual_step "UPGRADE AVAILABLE!!!" "An upgrade is available.  Please apply with `rpm-ostree upgrade` then continue"
else
  echo "OS Updated"
fi

h1 "Setup ssh-key"
if dir_exists "${HOME}/.ssh"; then
  echo "SSH config directory exists, assuming all is setup"
else
  echo "Generating security key for this system"
  ssh-keygen -b 4096
fi

h3 "Allow scaling to incremental values (versus 100/200/300%)
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

# TODO: detect if in toolbox (has to run from root)
# TODO: Detect I'm actually on Fedora silverblue
# TODO: In toolbox, run `dnf install @development-tools` to install developer tools
# TODO: In toolbox, run `dnf install bc`
# TODO: Enabled "third party software repository" in GUI, but not sure how that
maps.  Assuming something in flatpak, but it's not a new remote...
# TODO: civo toolbox: (or really, use buildah to build container...or somehow
#   integrat into toolbox framework
#  sudo dnf install redhat-rpm-config
#  dnf install @development-tools ruby ruby-devel
#  sudo gem install civo_cli
# TODO: Install GNOME Calculator Pak (GUI App)

