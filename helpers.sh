#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# signal catching 
trap ctrl_c INT
ctrl_c() {
	echo
	echo -e "${RED}Caught interrupt. Goodbye.${NC}"
	exit 1
}

get_arch() {
	ARCH=
	ARCH_FULL=`uname -s`-`uname -p`
	if [[ ${ARCH_FULL} =~ "arm" ]]; then
		ARCH="arm"
	elif [[ ${ARCH_FULL} =~ "x86" ]]; then 
		ARCH="x86"
	fi
	echo ${ARCH}
}

run_install() {
	# NOTE: default behaviour is to do batch installation (faster)
	# expects arg 1 to be the installer cmd as a string
	# expects arg 2 to be all the packages to install
	INSTALLER=$1
	shift # shift all arguments to the left
	PKGS=("$@")
	echo -e "${CYAN}Starting \"${INSTALLER}\" installation process ${NC}" 
	PKGS_TO_INSTALL=()
	for PKG_NAME in ${PKGS[@]} ; do
		read -p "$(echo -e ${YELLOW}"Do you want to install ${PKG_NAME}?(y/n) "${NC})" -n 1 -r CONFIRM
		echo # move cursor to a new line
		if [[ ${CONFIRM} =~ ^[Yy]$ ]]; then
			PKGS_TO_INSTALL+=($PKG_NAME)
		else
			echo -e "${BLUE}Skipping installation of ${PKG_NAME}${NC}"
		fi
	done
	# run a batch installation. Ex. works great with "sudo apt install X Y Z"
	eval ${INSTALLER} ${PKGS_TO_INSTALL[@]} || (echo -e "${RED}Failed installation ${NC}" && exit 1)
}

run_install_individual() {
	# expects arg 1 to be the installer cmd as a string
	# expects arg 2 to be all the packages to install
	INSTALLER=$1
	shift # shift all arguments to the left
	PKGS=("$@")
	echo -e "${CYAN}Starting \"${INSTALLER}\" installation process ${NC}" 
	for i in ${PKGS[@]} ; do
		read -p "$(echo -e ${YELLOW}"Do you want to install ${i}?(y/n) "${NC})" -n 1 -r CONFIRM
		echo # move cursor to a new line
		if [[ ${CONFIRM} =~ ^[Yy]$ ]]; then
			eval ${INSTALLER} $i || (echo -e "${RED}Failed installing $i ${NC}" && exit 1)
			echo -e "${GREEN}Successfully installed $i ${NC}"
		else
			echo -e "${BLUE}Skipping installation of ${i}${NC}"
		fi
	done
}

run_git_cloner() {
	# takes in the repos as a list of ("username"/"reponame", ...)
	mkdir -p git_repos # new folder
	cd git_repos
	GIT_REPOS=("$@")
	# extract the username and reponame
	for userrepo in ${GIT_REPOS[@]} ; do
		username=$(cut -d'/' -f1 <<<"${userrepo}")
		reponame=$(cut -d'/' -f2 <<<"${userrepo}")
		if [ ! -d $reponame ] # only clone once
		then
			git clone "https://github.com/${username}/${reponame}"
		else
			echo -e "${GREEN}Skipping git download of ${reponame}. Already installed.${NC}"
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
	echo -e "${CYAN}Installing zsh and zsh plugins (autosuggestions & syntax highlighting)${NC}"
	# install zsh
	if [ ! -d "${HOME}/.oh-my-zsh/" ]
	then
	    echo -e "Running zsh installer"
	    bash ./git_repos/ohmyzsh/tools/install.sh # only run script once
	else
		echo -e "${GREEN}Skipping installing zsh. Already installed.${NC}"
	fi
	# install zsh plugins
	PLUGINS_DIR="${HOME}/.oh-my-zsh/custom/plugins"
	if [ ! -d "${PLUGINS_DIR}/zsh-autosuggestions" ]
	then
		cp -r ./git_repos/zsh-autosuggestions ${PLUGINS_DIR}/
		cp -r ./git_repos/fast-syntax-highlighting ${PLUGINS_DIR}/
		# add plugins to .zshrc under "plugins=(git)"
		sed -ie "s/plugins=(git)/\plugins=(git)\nplugins=(zsh-autosuggestions fast-syntax-highlighting)/" $HOME/.zshrc
		echo -e "Installed zsh plugins"
	else
		echo -e "${GREEN}Skipping installing zsh plugins. Already installed.${NC}"
	fi
}

install_zsh_theme() {
	HOME=$1
	echo -e "${CYAN}Installing zsh theme (spaceship prompt)${NC}"
	# install zsh spaceship theme
	THEMES_DIR="${HOME}/.oh-my-zsh/custom/themes"
	if [ ! -d "${THEMES_DIR}/spaceship-prompt" ]
	then
		cp -r ./git_repos/spaceship-prompt ${THEMES_DIR}/
		ln -sf ${THEMES_DIR}/spaceship-prompt/spaceship.zsh-theme ${THEMES_DIR}/spaceship.zsh-theme
		# set ZSH_THEME="spaceship" in .zshrc
		sed -i $HOME/.zshrc -e '11s!ZSH_THEME="robbyrussell"!ZSH_THEME="spaceship"!'
		echo -e "Installed zsh spaceship theme"
	fi
}

download_files() {
	OUT_DIR=$1
	shift # skip 1st arg (directory)
    mkdir -p ${OUT_DIR}
    cd ${OUT_DIR}
    DOWNLOAD_TUPLES=($@)
    for link_name_tuple in ${DOWNLOAD_TUPLES[@]} ; do
		LINK=$(cut -d',' -f1 <<<"${link_name_tuple}")
		NAME=$(cut -d',' -f2 <<<"${link_name_tuple}") 
		if [ ! -f "./${NAME}.deb" ]
		then
			read -p "$(echo -e ${YELLOW}"Do you want to download ${NAME} deb from ${LINK}?(y/n) "${NC})" -n 1 -r CONFIRM
			echo    # (optional) move to a new line
			if [[ ${CONFIRM} =~ ^[Yy]$ ]]; then
				echo -e "${CYAN}Downloading to \"${NAME}.deb\"${NC}"
				wget ${LINK} -O ${NAME}.deb
			else
				echo -e "${BLUE}Skipping debfile installation of ${i}${NC}"
			fi
		else
			echo -e "${GREEN}Skipping download of \"${NAME}\". Already downloaded.${NC}"
		fi
    done
    cd ..
}

install_from_deb() {
	DEB_DIR=deb_files
	download_files ${DEB_DIR} "$@" # download all files
	if [ -z "$(ls -A ./${DEB_DIR})" ]; then # check if no deb files were downloaded
		return 0 # cleanly exit, nothing more to do. 
	fi
	all_debs=`ls ./${DEB_DIR}/*.deb` # get all downloaded files
	run_install "sudo apt -y install" ${all_debs[@]}
}