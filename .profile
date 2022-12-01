# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022
# if running bash

GOPATH=$HOME/.go
export GOPATH
PYENV_ROOT="$HOME/src/pyenv"

# set PATH so it includes user's private bins if they exist
for p in "$HOME/.scripts" "$HOME/.bin" "$HOME/.cabal/bin" "$HOME/.go/bin" "$PYENV_ROOT/bin" "$HOME/src/tfenv/bin" "$HOME/.yarn/bin" "$HOME/.gem/bin" "$HOME/.local/share/node_modules/bin" "$HOME/khan/devtools/google-cloud-sdk/bin" "/Applications/MacVim.app/Contents/bin"
do
	if [ -d "$p" ] ; then
		PATH="$PATH:$p"
	fi
done

# need precedence for reasons.
# .local/bin: so npm install -g npm wins over nix
# bin: so I can override things
# pyenv shims: ???
# TODO: more principled.
for p in "$HOME/.local/bin" "$PYENV_ROOT/shims" "$HOME/bin"
do
	if [ -d "$p" ] ; then
		PATH="$p:$PATH"
	fi
done

export PATH
