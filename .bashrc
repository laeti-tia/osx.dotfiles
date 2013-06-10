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

# We use promptvars
shopt -s promptvars

# Git or SVN prompts
prompt_git() {
    git branch &>/dev/null || return 1
    HEAD="$(git symbolic-ref HEAD 2>/dev/null)"
    BRANCH="${HEAD##*/}"
    [[ -n "$(git status 2>/dev/null | \
        grep -F 'working directory clean')" ]] || STATUS="!"
    printf ' (git:\033[32m%s\033[1;31m%s\033[0m) ' "${BRANCH:-unknown}" "${STATUS}"
}
prompt_svn() {
    svn info &>/dev/null || return 1
    URL="$(svn info 2>/dev/null | \
        awk -F': ' '$1 == "URL" {print $2}')"
    ROOT="$(svn info 2>/dev/null | \
        awk -F': ' '$1 == "Repository Root" {print $2}')"
    BRANCH=${URL/$ROOT}
    BRANCH=${BRANCH#/}
    BRANCH=${BRANCH#branches/}
    BRANCH=${BRANCH%%/*}
    [[ -n "$(svn status 2>/dev/null)" ]] && STATUS="!"
    printf ' (svn:\033[32m%s\033[1;31m%s\033[0m) ' "${BRANCH:-unknown}" "${STATUS}"
}
prompt_vcs() {
    prompt_git || prompt_svn
}

# Add number of background jobs, if any
prompt_jobs() {
    [[ -n "$(jobs)" ]] && printf '\033[1;31m{%d}\033[0m' $(jobs | sed -n '$=')
}

# We want a colored prompt, if the terminal has the capability
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48 (ISO/IEC-6429).
	MY_PROMPT='\[\033[1;32m\]\u\[\033[1;31m\]@\[\033[1;33m\]\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]'
	export CLICOLOR=1
	LSCOLORS=ExGxFxDxCxDaDaabagecec
	export LSCOLORS
else
    MY_PROMPT='\u@\h:\w\'
fi

# If this is an xterm set the titlebar to user@host:dir
case "$TERM" in
screen*|xterm*|rxvt*)
    MY_PROMPT="\[\e]0;\u@\h: \w\a\]$MY_PROMPT"
    ;;
*)
    ;;
esac

# Switch the prompt on or off
prompt_on() {
	PS1=$MY_PROMPT'$(prompt_jobs)$(prompt_vcs)'
	if [[ $EUID -eq 0 ]]; then
		PS1=$PS1'\[\033[1;31m\]#\[\033[0m\] '
	elif [[ -n $SUDO_USER ]]; then
		PS1=$PS1'\[\033[1;33m\]±\[\033[0m\] '
	else
		PS1=$PS1'\$ '
	fi
}
prompt_off() {
	if [[ $EUID -eq 0 ]]; then
		PS1='# '
	else
		PS1='$ '
	fi
}
# We default to the full features prompt
prompt_on

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
alias pstree='pstree -g 3'
alias info='info --vi-keys'
alias git-last-log='git log --summary HEAD^..'
alias git-home='git --work-tree=$HOME --git-dir=$HOME/.files.git'
alias ssh-vnc='ssh -o UserKnownHostsFile=/dev/null -C -L 5900:localhost:5900'
alias ssh-http='ssh -o UserKnownHostsFile=/dev/null -C -L 8080:localhost:80'
alias listen='lsof -n -i4TCP | grep LISTEN'

