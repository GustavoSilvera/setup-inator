#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# Exit immediately when failing to install a package
set -e

run_install() {
	INSTALLER=$1
	PKGS=$2
	echo -e "${CYAN}Starting \"${INSTALLER}\" installation process ${NC}"
	for i in ${PKGS[*]} ; do
	    eval ${INSTALLER} $i || (echo -e "${RED}Failed installing $i ${NC}" && exit 1)
		echo -e "${GREEN}Successfully installed $i ${NC}"
	done
}

run_git_cloner() {
	# takes in the repos as a list of ("username"/"reponame", ...)
	mkdir -p git_repos # new folder
	cd git_repos
	GIT_REPOS=$1
	# extract the username and reponame
	for userrepo in ${GIT_REPOS[*]} ; do
		username=$(cut -d'/' -f1 <<<"${userrepo}")
		reponame=$(cut -d'/' -f2 <<<"${userrepo}")
		if [ ! -d $reponame ] # only clone once
		then
			git clone "https://github.com/${username}/${reponame}"
		fi
	done
	cd ..
}

if_exists_dir() {
	dir_in_question=$1
	execute_str=$2
	if [ ! -d ${dir_in_question} ]
	then 
		eval ${execute_str}
	fi
}

install_zsh_plugins() {
	HOME=$1
	echo -e "${CYAN}Installing zsh & plugins${NC}"
	# install zsh
	if [ ! -d "${HOME}/.oh-my-zsh/" ]
	then 
		bash ./git_repos/ohmyzsh/tools/install.sh # only run script once
	fi
	# install zsh plugins
	if [ ! -d "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]
	then
		PLUGINS_DIR="${HOME}/.oh-my-zsh/custom/plugins/"
		cp -r ./git_repos/zsh-autosuggestions ${PLUGINS_DIR}
		cp -r ./git_repos/fast-syntax-highlighting ${PLUGINS_DIR}
		# add plugins to .zshrc under "plugins=(git)"
		sed -ie "s/plugins=(git)/\plugins=(git)\nplugins=(zsh-autosuggestions fast-syntax-highlighting)/" $HOME/.zshrc
	fi
}