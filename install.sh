#!/bin/bash

#run with wget -O - <url> | bash

set +e

exclude="README.md .git LICENSE install.sh"
dir="${1:-.dotfiles}"

cd "$HOME"
rm -rf "$dir"
git clone https://github.com/benjaminjkraft/dotfiles.git "$dir"
# A little bit fragile, but it works.
files=$(ls -A "$dir" | grep -v "^$(echo $exclude | sed 's/ /\$\\|\^/g')$")

for i in $files ; do
  rm -rf "$i"
  ln -s "$dir/$i"
done
