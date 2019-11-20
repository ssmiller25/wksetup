#!/bin/sh

#set -x

# Setup mac instructions

echo "Step 0: Change shell"

echo "Changing shell to zshell"
if [ "$SHELL" == "/bin/zsh" ]; then
  echo "Already set to zshell, great!"
else
  chsh -s /bin/zsh
fi

echo "Set 0.5: Inital zsh environment"
if [ -d "${HOME}/tmp" ]; then
  echo "Making temp directory in home"
  mkdir ${HOME}/tmp
fi

if [ -d "${HOME}/.zshrc" ]; then
  echo "zshrc already exists"
else
  # Create directory to run individual components  
  mkdir ${HOME}/.zshrc.d
  cp zshrc ${HOME}/.zshrc
  chmod 755 ${HOME}/.zshrc
fi

echo "Step 1: Good terminal"
if [ -d "/Applications/iTerm.app" ]; then
  echo "Good, already installed"
else
  echo "Go to https://www.iterm2.com/downloads.html and download/install"
  echo "  iterm2 (drag/drop into Application)"
fi

echo "Step 2: brew"
if which brew > /dev/null 2>&1; then
  echo "Brew already installed"
else
  echo "Installing brew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "Step 3: docker and extras"
if which docker > /dev/null 2>&1; then
  echo "Docker already installed"
else
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
