# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022
# if running bash

# set PATH so it includes user's private bins if they exist
for p in "$HOME/.scripts" "$HOME/bin" "$HOME/.bin" "$HOME/.cabal/bin"
do
	if [ -d "$p" ] ; then
		PATH="$PATH:$p"
	fi
done

export ATHENA_USER=benkraft
