# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

export PATH=/usr/local/bin:/usr/local/sbin:$PATH

## History
# ignoredups and ignorespace
export HISTCONTROL=ignoreboth
export HISTSIZE=999
export HISTFILESIZE=9999
# append to the history file, don't overwrite it
shopt -s histappend
# keep multi-seesion history fine
PROMPT_COMMAND='history -a'

# check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize

## Editor related
# vi mode
set -o vi
export EDITOR=vim

## Debian chroot, if any
# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

## Prompt
# We use promptvars
shopt -s promptvars
# Git prompt
prompt_git() {
    # Are we in a git repository?
    git branch &>/dev/null || return 1
    HEAD="$(git symbolic-ref HEAD 2>/dev/null)"
    BRANCH="${HEAD##*/}"
    [[ -n "$(git status 2>/dev/null | grep -F 'working directory clean')" ]] || STATUS="❗ "
        printf "(git:%s%s)" "${BRANCH:-unknown}" "${STATUS}"
}
# SVN prompt
prompt_svn() {
    # Are we in a svn repository?
    svn info &>/dev/null || return 1
    URL="$(svn info 2>/dev/null | awk -F': ' '$1 == "URL" {print $2}')"
    ROOT="$(svn info 2>/dev/null | awk -F': ' '$1 == "Repository Root" {print $2}')"
    BRANCH=${URL/$ROOT}
    BRANCH=${BRANCH#/}
    BRANCH=${BRANCH#branches/}
    BRANCH=${BRANCH%%/*}
    [[ -n "$(svn status 2>/dev/null)" ]] && STATUS="❗ "
        printf "(svn:%s%s)" "${BRANCH:-unknown}" "${STATUS}"
}
# We look for GIT then SVN
prompt_vcs() {
    prompt_git || prompt_svn;
}
# Add number of background jobs, if any
prompt_jobs() {
    [[ -n "$(jobs)" ]] && printf '{%d}' $(jobs | sed -n '$=')
}

# TODO: add Debian chroot info, if any
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# We want a colored prompt, if the terminal has the capability
if [ -x /usr/bin/tput ] && tput colors >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48 (ISO/IEC-6429).
    MY_PROMPT='\[\e[1;32m\]\u\[\e[31m\]@\[\e[33m\]\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]'
    export CLICOLOR=1
    export LSCOLORS=ExGxFxDxCxDaDaabagecec
else
    MY_PROMPT='\u@\h:\w'
fi

# If this is an xterm set the titlebar to user@host:dir
case "$TERM" in
screen*|xterm*|rxvt*)
    MY_PROMPT="\[\e]0;\u@\h: \w\a\]$MY_PROMPT"
# TODO: Debian chroot
#    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Switch the prompt on or off
prompt_on() {
    PS1=$MY_PROMPT'\[\e[1;31m\]$(prompt_jobs)\[\e[0;32m\]$(prompt_vcs)\[\e[0m\]'
    if [[ $EUID -eq 0 ]]; then
        PS1=$PS1'\[\e[1;31m\]#\[\e[0m\] '
    elif [[ -n $SUDO_USER ]]; then
        PS1=$PS1'\[\e[1;33m\]±\[\e[0m\] '
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

# Bash completion, if installed (should be default on Debian)
if [ -f /usr/local/bin/brew ] && [ -f `brew --prefix`/etc/bash_completion ]; then
    # on OSX with brew
    . `brew --prefix`/etc/bash_completion
elif [ -f /usr/local/etc/bash_completion ]; then
    # on FreeBSD if installed ("pkg install bash-completion")
    . /usr/local/etc/bash_completion
fi

# Java related settings
export MAVEN_OPTS="-XX:MaxPermSize=256m"

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support for some commands
[ -x /usr/bin/dircolors ] && eval "`dircolors -b`"

# Alias definitions, linux defaults
alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias ll='ls -lh'
alias df='df -h'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias vi='vim'
alias psa='ps aux'
alias cwdcmd='echo -n "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
alias who='who -HTu'
alias diffpatch='diff -Naur'
alias idiff='~/.idiff.sh'
alias less='less -r'
alias pstree='pstree -G'
alias info='info --vi-keys'
alias git-last-log='git log --summary HEAD^..'
alias git-home='git --work-tree=$HOME --git-dir=$HOME/.files.git'
alias ssh-vnc='ssh -o UserKnownHostsFile=/dev/null -C -L 5900:localhost:5900'
alias ssh-http='ssh -o UserKnownHostsFile=/dev/null -C -L 8080:localhost:80'
alias listen='lsof -n -i4TCP | grep LISTEN'

# OSX only aliases
if [[ `uname` =~ (Darwin|FreeBSD) ]]; then
    alias top='/usr/bin/top -u -s 2 -S'
    alias pstree='/usr/local/bin/pstree -g 3'
    alias ls='ls -G'
    alias ll='ls -lh'
    if [[ `uname` = FreeBSD ]]; then
        alias top='top -z'
    fi
fi

# svn-color from JM Lacroix: https://github.com/jmlacroix/svn-color (only if svn is installed)
svn info &>/dev/null && source ~/.svn-color/svn-color.sh

