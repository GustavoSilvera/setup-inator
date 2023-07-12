#!/bin/bash

ZSH_HOME=$HOME/.zsh
mkdir -p $ZSH_HOME

cp .zshrc $HOME
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_HOME/zsh-autosuggestions
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting $ZSH_HOME/fast-syntax-highlighting
