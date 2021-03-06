#!/bin/bash

source ../../helpers.sh

# special thanks to this repo: https://github.com/shalva97/kde-configuration-files

# copy to .kde folder
cp -r ./share ~/.kde/

# copy over plasma appletsrc (plasmoids)
cp ./plasma-org.kde.plasma.desktop-appletsrc ~/.config/

# copy over workspace/kwin rules
cp ./kwinrc ~/.config/

# copy over window rules
cp ./kwinrulesrc ~/.config/

# copy over wallpaper
mkdir -p ~/Pictures/Wallpapers/
cp ./icecold2.png ~/Pictures/Wallpapers/

# copy over profile pic
cp ../profile.png ~/Pictures/