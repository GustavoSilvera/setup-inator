#!/bin/bash

# get all library functions
source ./helpers.sh

HOME="/home/$USER"

ARCH=$(get_arch)
echo -e "${BLUE}Setting up ${ARCH} based Linux system...${NC}"

mkdir -p setup_linux
cd setup_linux

sudo apt update && sudo apt upgrade
sudo apt --fix-broken -y install || (echo -e "${RED}Failed to fix broken install ${NC}" && exit 1)
APT_PKGS=(
    "git"
    "tree"
    "tmux"
    "curl"
    "gawk"
    "neofetch"
    "htop"
    "emacs-nox"
    "terminator"
    "zsh"
    "chromium-browser"
    "timeshift"
    "fonts-firacode"
    "cmake"
    "clang"
    "g++"
)

run_install "sudo apt install -y" ${APT_PKGS[@]}

# update terminator config
echo -e "${CYAN}Updating terminator config${NC}"
mkdir -p $HOME/.config/terminator/ # make if doesn't already exist
cp ../configs/terminator/config $HOME/.config/terminator/

# formatted as (single str) "link,resulting_name"
X86_DOWNLOAD_LINKS=(
    "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64,vscode"
    "https://discord.com/api/download?platform=linux&format=deb,discord"
    "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb,chrome"
)
ARM_DOWNLOAD_LINKS=(
    "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-arm64,vscode"
)
DOWNLOAD_LINKS=() # initially empty
if [[ ${ARCH} == "arm" ]]; then
    DOWNLOAD_LINKS=${ARM_DOWNLOAD_LINKS[@]}
elif [[ ${ARCH} == "x86" ]]; then 
    DOWNLOAD_LINKS=${X86_DOWNLOAD_LINKS[@]}
fi
install_from_deb ${DOWNLOAD_LINKS[@]}

# install packaged through git
ZSH_REPOS=( # insert username/reponame
    "ohmyzsh/ohmyzsh"
    "zsh-users/zsh-autosuggestions"
    "zdharma/fast-syntax-highlighting"
    "spaceship-prompt/spaceship-prompt"
)

run_git_cloner ${ZSH_REPOS[@]}

install_zsh_plugins ${HOME}

# run zsh installer last since it closes the script for me :)
install_zsh_theme ${HOME}

cd .. # back to main dir
