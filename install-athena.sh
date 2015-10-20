#!/bin/bash

#run with wget -O - <url> | bash

set +e

exclude="README.md .git .gitignore LICENSE install.sh install-athena.sh .bashrc"
dir="/mit/benkraft/.dotfiles"

cd "$dir"
git pull
cd "$HOME"
# A little bit fragile, but it works.
files=$(ls -A "$dir" | grep -v "^$(echo $exclude | sed 's/ /\$\\|\^/g')$")

for i in $files ; do
  if [ ! -L "$i" ] ; then
    rm -rf "$i"
    ln -s "$dir/$i"
  fi
done
if [ ! -L ".bashrc" ] ; then
  rm -rf ".bashrc.github"
  ln -s "$dir/.bashrc" ".bashrc.github"
fi
