# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

### Default environment                                                 ----------
export PATH=/usr/local/bin:/usr/local/sbin:$PATH
export MAVEN_OPTS="-XX:MaxPermSize=256m"
# We use vi mode and vim as EDITOR
set -o vi
export EDITOR=vim
# check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize
export MANWIDTH="tty"

### History                                                             ----------
# ignoredups and ignorespace, append to the history file, don't overwrite it
export HISTCONTROL=ignoreboth
export HISTSIZE=999
export HISTFILESIZE=9999
shopt -s histappend
# keep multi-seesion history fine
PROMPT_COMMAND='history -a'

### Debian chroot                                                       ---------- 
# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

## Prompt                                                               ----------
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
    [ -n "$(jobs)" ] && printf '{%d}' $(jobs | sed -n '$=')
}
# Look at result code
prompt_result() {
    if [[ $? == 0 ]]; then
        echo -e ${SMILEY}
    else
        echo -e ${FROWNY}
    fi
}

# TODO: add Debian chroot info, if any
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

if [ `uname` == FreeBSD ]; then
    # FreeBSD tput doesn't recognize the terminfo capname but only the old termcap code
    ME="me"
    AF="AF"
else
    ME="sgr0"
    AF="setaf"
fi
if [ `uname` == Darwin ]; then
    SMILEY="$(tput ${AF} 15):)$(tput ${ME})"
    FROWNY="$(tput ${AF} 9):($(tput ${ME})"
else
    SMILEY="\e[38;5;015m:)$(tput ${ME})"
    FROWNY="\e[38;5;009m:($(tput ${ME})"
fi
# We want a colored prompt and utilities, if the terminal has the capability
if [ -x /usr/bin/tput ] && tput colors >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48.
    MY_PROMPT="\[\e[38;5;010m\]\u\[\e[38;5;009m\]@\[\e[38;5;011m\]\h\$(prompt_result)\[\e[38;5;012m\]\w\[$(tput ${ME})\]"
    export CLICOLOR=1
    export LSCOLORS=ExGxFxDxCxDaDaabagecec
    alias ls='ls --color=auto'
    export PAGER="less -sR"
    [ -x /usr/bin/dircolors ] && eval "`dircolors -b`"
    export LESS="--RAW-CONTROL-CHARS"
    export LESS_TERMCAP_mb=$'\e[38;5;009m'
    export LESS_TERMCAP_md=$'\e[38;5;010m'
    export LESS_TERMCAP_me=$'\e[0m'
    export LESS_TERMCAP_se=$'\e[0m'
    export LESS_TERMCAP_so=$'\e[48;5;004m'
    export LESS_TERMCAP_ue=$'\e[0m'
    export LESS_TERMCAP_us=$'\e[38;5;012m'
    export GREP_OPTIONS="--color=auto" GREP_COLOR='38;5;208'
    export TERM="xterm-256color"
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
    PS1=$MY_PROMPT"\[\e[38;5;009m\]\$(prompt_jobs)\[\e[38;5;002m\]\$(prompt_vcs)\[$(tput ${ME})\]"
    if [[ $EUID -eq 0 ]]; then
        PS1=$PS1"\[\e[38;5;009m\]#\[$(tput ${ME})\] "
    elif [[ -n $SUDO_USER ]]; then
        PS1=$PS1"\[\e[38;5;011m\]±\[$(tput ${ME})\] "
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
[ -x /usr/bin/tput ] && prompt_on

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

### Alias definitions                                                           ----------
# Linux defaults
alias ll='ls -lh'
alias df='df -h'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias vi='vim'
alias psa='ps aux'
alias who='who -HTu'
alias diffpatch='diff -Naur'
alias idiff='~/.idiff.sh'
alias less='less -r'
alias pstree='pstree -Ga'
alias info='info --vi-keys'
alias git-last-log='git log --summary HEAD^..'
alias git-home='git --work-tree=$HOME --git-dir=$HOME/.files.git'
alias ssh-vnc='ssh -o UserKnownHostsFile=/dev/null -C -L 5900:localhost:5900'
alias ssh-http='ssh -o UserKnownHostsFile=/dev/null -C -L 8080:localhost:80'
alias listen='lsof -n -i4TCP | grep LISTEN'

# FreeBSD and OSX only
if [[ `uname` =~ (Darwin|FreeBSD) ]]; then
    # Bash completion, if installed (should be default on Debian)
    if [ -f /usr/local/bin/brew ] && [ -f `brew --prefix`/etc/bash_completion ]; then
        # on OSX with brew
        . `brew --prefix`/etc/bash_completion
    elif [ -f /usr/local/etc/bash_completion ]; then
        # on FreeBSD if installed ("pkg install bash-completion")
        . /usr/local/etc/bash_completion
    fi
    alias top='/usr/bin/top -u -s 2 -S'
    alias pstree='/usr/local/bin/pstree -g 3'
    alias ls='ls -G'
    alias ll='ls -lh'
    if [ `uname` == FreeBSD ]; then
        alias top='/usr/bin/top -a -z -s 2 -S'
    fi
fi

# svn-color from JM Lacroix: https://github.com/jmlacroix/svn-color (only if in svn repo)
svn info &>/dev/null && source ~/.svn-color/svn-color.sh

# get a successful return code no matter what
return 0

