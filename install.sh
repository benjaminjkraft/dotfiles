#!/bin/bash

#run with wget -O - <url> | bash

set +e

exclude="README.md .git LICENSE install.sh install-athena.sh"
dir="${1:-.dotfiles}"

if [ -d "$dir" ] ; then
  cd "$dir"
  git pull
  cd "$HOME"
else
  cd "$HOME"
  git clone https://github.com/benjaminjkraft/dotfiles.git "$dir"
fi
# A little bit fragile, but it works.
files=$(ls -A "$dir" | grep -v "^$(echo $exclude | sed 's/ /\$\\|\^/g')$")

for i in $files ; do
  if [ ! -L "$i" ] ; then
    rm -rf "$i"
    ln -s "$dir/$i"
  fi
done
