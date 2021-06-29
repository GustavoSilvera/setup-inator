#!/bin/bash

# get all library functions
source ./helpers.sh

HOME="/home/$USER"

mkdir -p setup_linux
cd setup_linux

sudo apt update && sudo apt upgrade
sudo apt --fix-broken -y install || (echo -e "${RED}Failed to fix broken install ${NC}" && exit 1)
APT_PKGS=(
    "git"
    "tree"
    "tmux"
    "neofetch"
    "htop"
    "emacs-nox"
	"terminator"
)

run_install "sudo apt install -y" ${APT_PKGS}

# install packaged through git
ZSH_REPOS=( # insert username/reponame
    "ohmyzsh/ohmyzsh"
    "zsh-users/zsh-autosuggestions"
    "zdharma/fast-syntax-highlighting"
)

run_git_cloner ${ZSH_REPOS}

install_zsh ${HOME}

cd .. # back to main dir