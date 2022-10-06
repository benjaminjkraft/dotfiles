# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

PATH=$PATH:/usr/bin:/usr/local/heroku/bin:/usr/local/go/bin:$HOME/.cargo/bin

#Import various stuff, checking each for existence
for f in "/etc/profile" "$HOME/.profile" "$HOME/.bin/j.sh" "/usr/share/autojump/autojump.bash" "$HOME/.config/autopackage/paths-bash" "$HOME/.bashrc_local" "$HOME/khan/devtools/google-cloud-sdk/completion.bash.inc" "$HOME/google-cloud-sdk/completion.bash.inc" "$HOME/.autojump/etc/profile.d/autojump.sh" "$HOME/.fzf.bash"

do
	if [ -f "$f" ] ; then
		. "$f"
	fi
done

if which pyenv &>/dev/null; then
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=
HISTFILESIZE=

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm)
        read -d '' terminal terminal_args < /proc/$PPID/cmdline
        case "${terminal##*/}" in
            gnome-terminal*|xterm*) TERM="$TERM-256color";;
        esac
        unset terminal terminal_args
        ;;
esac

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|xterm-256color|tmux-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
else
	color_prompt=
fi

if [ -n "$KRB5CCNAME" ] && [ -n "$KRBTKFILE" ] ; then
  # krbroot sets $KRB5CCNAME and $KRBTKFILE.  This wants the format that
  # krbroot uses, but some other things use $KRB5CCNAME, so we check for both.
  krbinst="[${KRB5CCNAME#/tmp/krb5cc_$(id -u).}]"
else
  krbinst=""
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u$krbinst@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u$krbinst@\h:\w\$ '
fi
unset color_prompt force_color_prompt

title () { echo "can't set title here"; }
# If this is an xterm set the title to folder (user@host:dir)
case "$TERM" in
xterm*|rxvt*)
#    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \W\a\]$PS1"
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\W (\u$krbinst@\h: \w)\a\]$PS1"
    ;;
*screen*)
  screen_set_window_title () {
    if [ -z "$TITLE" ]; then
      local HPWD="$PWD"
      case $HPWD in
        $HOME) HPWD="~";;


        ## long name option:
        # $HOME/*) HPWD="~${HPWD#$HOME}";;


        ## short name option:
        *) HPWD=`basename "$HPWD"`;;


      esac
    else
      HPWD="$TITLE"
    fi
    if [ -z "$TMUX" ]; then
        printf '\ek%s\e\\' "$HPWD"
    else  # tmux pretends to be screen in $TERM but sets $TMUX
        tmux rename-window "$HPWD"
    fi
  }
  title () {
    TITLE="$1"
    screen_set_window_title
  }
  PROMPT_COMMAND="screen_set_window_title; $PROMPT_COMMAND"
    ;;
*)
    ;;
esac

# enable color support for ls/grep
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# some more ls aliases
alias ll='ls -ahlF'
alias la='ls -A'
alias l='ls -CF'

#MORE ALIASES THAN YOUR BODY HAS ROOM FOR
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias e='evince'
alias pd='pushd'
alias less='less -iR'
alias s='git s'
alias d='git d'
alias htop='title htop ; htop ; title'
alias gd='go doc'
if which -s gvim && ! which -s mvim; then
    alias gvim=mvim
fi

case "$(hostname)" in
homotopy)
    export GIT_AUTHOR_EMAIL=benkraft@makenotion.com
    export GIT_COMMITTER_EMAIL=benkraft@makenotion.com
    ;;
esac

#some little utility functions
snip () {
  if [ -n "$2" ] ; then
    ln -s "$HOME/.snip/$1" "$2"
  else
    ln -s "$HOME/.snip/$1"
  fi
}

gvimr () {
    if [ -z "$(gvim --serverlist)" ]; then
        gvim "$@"
    else
        f="$(realpath "$1")"
        shift
        gvim --remote-send "<C-\\><C-n>:split $f<CR>" "$@"
    fi
}

EDITOR='/usr/bin/vim'
export EDITOR

export CLOUDSDK_PYTHON=/usr/bin/python3

export GEM_HOME=$HOME/.gem

export BASH_SILENCE_DEPRECATION_WARNING=1

# TODO: I'm not on node 17+, why is this needed?? what does it even mean???
export NODE_OPTIONS=--openssl-legacy-provider

export NOTION_NO_PREPUSH=true

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi
eval "$(notion completion --install)"
