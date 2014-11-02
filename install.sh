#!/bin/bash

#run with wget -O - <url> | bash

set +e

exclude="README.md .git LICENSE"
dir="${1:-.dotfiles}"

cd "$HOME"
git clone https://github.com/benjaminjkraft/dotfiles.git "$dir"
# A little bit fragile, but it works.
files=$(ls -A "$dir" | grep -v "^$(echo $exclude | sed 's/ /\$\\|\^/g')$")

for i in files ; do
  ln -s "$dir/$i"
done
