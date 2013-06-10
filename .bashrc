# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

export PATH=/usr/local/bin:/usr/local/sbin:$PATH
# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
# ... or force ignoredups and ignorespace
export HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# vi mode
set -o vi

# Common editor
EDITOR=vi
export EDITOR

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# We want a colored prompt, if the terminal has the capability
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='\[\033[01;32m\]\u\[\033[01;31m\]@\[\033[01;33m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
screen*|xterm*|rxvt*)
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Common ssh-agent for all terms
if [ ! $?SSH_CLIENT ]; then
	if [ ! -e /tmp/ssh-agent-${USER} ]; then
		ssh-agent -s > /tmp/ssh-agent-${USER}
		chmod 600 /tmp/ssh-agent-${USER}
	fi
	source /tmp/ssh-agent-${USER}
fi

# Bash completion (if installed with brew)
if [ -f `brew --prefix`/etc/bash_completion ]; then
	. `brew --prefix`/etc/bash_completion
fi

# Colorized output
export CLICOLOR=1
LSCOLORS=ExGxFxDxCxDaDaabagecec
export LSCOLORS

# Java related settings
MAVEN_OPTS="-XX:MaxPermSize=256m"
export MAVEN_OPTS

# Alias definitions.
alias grep='grep --color=auto'
alias ls='ls -G'
alias ll='ls -lh'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias psa='ps aux'
alias cwdcmd='echo -n "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
alias who='who -HTu'
alias top='top -u -s 2 -S'
alias diffpatch='diff -Naur'
alias idiff='~/.idiff.sh'
alias git-last-log='git log --summary HEAD^..'
alias git-home='git --work-tree=$HOME --git-dir=$HOME/.files.git'

