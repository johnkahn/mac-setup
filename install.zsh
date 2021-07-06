#!/usr/bin/env zsh

casks=(
  # kap # Screen recorder
  # little-snitch # Internet traffic monitor (ad blocking, privacy, etc)
  1password
  audio-hijack
  authy
  cakebrew
  discord
  docker
  farrago
  fission
  geekbench
  gitify
  google-chrome
  insomnia
  iterm2
  loopback
  natron
  nordvpn
  proxyman
  quicklook-csv
  quicklook-json
  react-native-debugger
  slack
  visual-studio-code
  zoom
)

brews=(
  coreutils
  cloc
  doctl
  gh
  git
  git-gui
  git-town
  kubectl
  mas
  terminal-notifier
  thefuck
  websocat
  youtube-dl
)

npms=(
  artillery
  expo-cli
  prettier
  yarn
)

apps=(
  1502839586 # Hand Mirror                                        (1.5)
  425264550  # Disk Speed Test                                    (3.3)
  409183694  # Keynote                                            (11.1)
  1437138382 # WhatFont                                           (2.1.1)
  1472777122 # Honey                                              (12.8.6)
  441258766  # Magnet                                             (2.6.0)
  1180442868 # SmileAllDay                                        (2.3.9)
  409203825  # Numbers                                            (11.1)
  1558453954 # Keyword Search                                     (1.0.2)
  409201541  # Pages                                              (11.1)
  1440147259 # AdGuard for Safari                                 (1.9.19)
  1444383602 # GoodNotes                                          (5.7.10)
  1518425043 # Boop                                               (1.3.1)
  1514817810 # Poolsuite FM                                       (1.2.0)
  1160374471 # PiPifier                                           (1.2.4)
  1532163541 # SponsorBlock port for YouTube - Skip Sponsorships  (3.1)
  497799835  # Xcode                                              (12.5.1)
)

git_configs=(
  "user.name \"John Kahn\""
  "user.email 7807353+johnkahn@users.noreply.github.com"
  "init.defaultBranch main"
)

fonts=(
  font-victor-mono
  font-inter
)

folders=(
  ~/Development/AmericanAirlines
)

######################################## End of app list ########################################
set +e
set -x

install() {
  cmd=$1
  shift
  for pkg in "$@"; do
    exec="${cmd} ${pkg}"
    #echo "Execute: $exec"
    if eval "${exec}"; then
      echo "Installed $pkg"
    else
      echo "Failed to execute: $exec"
      exit 1
    fi
  done
}

brew_install_or_upgrade() {
  if brew ls --versions "$1" >/dev/null; then
    if (brew outdated | grep "$1" >/dev/null); then
      echo "Upgrading already installed package $1 ..."
      brew upgrade "$1"
    else
      echo "Latest $1 is already installed"
    fi
  else
    brew install "$1"
  fi
}

cask_install_or_upgrade() {
  if brew ls --versions "$1" >/dev/null; then
    if (brew outdated | grep "$1" >/dev/null); then
      echo "Upgrading already installed package $1 ..."
      brew upgrade "$1"
    else
      echo "Latest $1 is already installed"
    fi
  else
    brew install --cask "$1"
  fi
}

sudo -v # Ask for the administrator password upfront
# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

if test ! "$(command -v brew)"; then
  echo "Install Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else
  echo "Update Homebrew"
  brew update
  brew upgrade
  brew doctor
fi
export HOMEBREW_NO_AUTO_UPDATE=1

echo "Install brew packages"
install 'brew_install_or_upgrade' "${brews[@]}"
install 'cask_install_or_upgrade' "${casks[@]}"
brew tap homebrew/cask-fonts
install 'cask_install_or_upgrade' "${fonts[@]}"

echo "Set git defaults"
install 'git config --global' "${git_configs[@]}"

echo "Login to GitHub"
gh auth login --web

echo "Install NVM"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

echo "Setup ZSH Profile"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cp .zshrc ~/.zshrc
cp .p10k.zsh ~/.p10k.zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k | zsh
source ~/.zshrc

echo "Install software"
nvm install --lts
nvm use --lts
install 'npm install --global' "${npms[@]}"

sudo curl -fL https://metriton.datawire.io/downloads/darwin/edgectl -o /usr/local/bin/edgectl
sudo chmod a+x /usr/local/bin/edgectl

echo "Install from App Store"

# Sign in to App Store https://github.com/mas-cli/mas/issues/164#issuecomment-860177723
if ! mas account >/dev/null; then
  echo "Please open App Store and sign in using your Apple ID ...."
  until mas account >/dev/null; do
    sleep 5
  done
fi

install 'mas install' "${apps[@]}"

echo "Create Directories"
install 'mkdir -p' "${folders[@]}"

echo "Cleanup"
brew cleanup

open https://setapp.com/download
open https://github.com/johnkahn/mac-setup/blob/main/POST_SETUP.md
echo "Done!"
