#!/bin/bash

#run with wget -O - <url> | bash

set +e

exclude="README.md .git LICENSE install.sh install-athena.sh .bashrc"
dir="/mit/benkraft/.dotfiles"

cd /mit/benkraft
# A little bit fragile, but it works.
files=$(ls -A "$dir" | grep -v "^$(echo $exclude | sed 's/ /\$\\|\^/g')$")

for i in $files ; do
  rm -rf "$i"
  ln -s "$dir/$i"
done
rm -rf ".bashrc.github"
ln -s "$dir/.bashrc" ".bashrc.github"
