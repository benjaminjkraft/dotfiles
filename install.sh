#!/bin/bash

#run with wget -O - <url> | bash

exclude="README.md .git LICENSE"
dir="${1:-.dotfiles}"

cd "$HOME"
git clone git@github.com:benjaminjkraft/dotfiles.git "$dir"
# A little bit fragile, but it works.
files=$(la "$dir" | grep -v "^$(echo $exclude | sed 's/ /\$\\|\^/g')$")

for i in files ; do
  ln -s "$dir/$i"
