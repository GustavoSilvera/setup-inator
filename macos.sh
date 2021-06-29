#!/bin/bash

# get all library functions
source ./helpers.sh

HOME="/User/$USER"

mkdir -p setup_macos
cd setup_macos

brew update || (echo -e "${RED}Failed to update brew ${NC}" && exit 1)
APT_PKGS=(
    "git"
    "tree"
    "tmux"
    "neofetch"
    "htop"
    "gawk"
    "emacs"
    "iterm2"
    "google-chrome"
    "visual-studio-code"
    "karabiner-elements"
)

run_install "brew install" ${APT_PKGS}

# install packaged through git
ZSH_REPOS=( # insert username/reponame
    "ohmyzsh/ohmyzsh"
    "zsh-users/zsh-autosuggestions"
    "zdharma/fast-syntax-highlighting"
)

run_git_cloner ${ZSH_REPOS}

install_zsh ${HOME}

cd .. # back to main dir