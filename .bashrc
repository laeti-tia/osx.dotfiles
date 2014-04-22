# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

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
    chroot=debian_chroot
fi

## Prompt                                                               ----------
# We use promptvars
shopt -s promptvars

# Colorful or not?
color_enabled() {
    local -i colors=$(tput colors 2>/dev/null)
    [[ $? -eq 0 ]] && [[ $colors -gt 2 ]]
}

if [ color_enabled ]; then
    export CLICOLOR=1
    export LSCOLORS=ExGxFxDxCxDaDaabagecec
    alias ls='ls --color=auto'
    export PAGER="less -sRM"
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
fi

# Some useful prompt formats
if [ `uname` == FreeBSD ]; then
    # FreeBSD tput doesn't recognize the terminfo capname but only the old termcap code
    ME="me"
    AF="AF"
    MD="md"
else
    ME="sgr0"
    AF="setaf"
    MD="bold"
fi
P_BOLD="${P_BOLD-$(color_enabled && tput ${MD})}"
P_HOME="${P_HOME-$(color_enabled && tput ${AF} 11)}"
P_OK="${P_OK-$(color_enabled && tput ${AF} 10)}"
P_ERROR="${P_ERROR-$(color_enabled && tput ${AF} 9)}"
P_WARNING="${P_WARNING-$(color_enabled && tput ${AF} 214)}"
P_NORMAL="${P_NORMAL-$(color_enabled && tput ${AF} 15)}"
P_INFO="${P_INFO-$(color_enabled && tput ${AF} 12)}"
P_RESET="${P_RESET-$(color_enabled && tput ${ME})}"

# Exit code
# TODO: it would be nice to print the return code at the end of the line (far right end)
p_result() {
    if [[ $? == 0 ]]; then
        printf "\[$P_NORMAL\]:)\[$P_RESET\]"
    else
        printf "\[$P_ERROR\]:(\[$P_RESET\]"
    fi
}

# PS1 needs to be re-evaluated after each command, because we use colors in the functions
set_bash_prompt() {
    PS1="${MY_PROMPT}$(p_result)${MY_PATH}$(prompt_vcs)\\$ "
}
PROMPT_COMMAND="set_bash_prompt; ${PROMPT_COMMAND}"
MY_PROMPT=""
MY_PATH=""

# UID
if [[ $EUID -eq 0 ]]; then
    MY_PROMPT="$MY_PROMPT"'\[$P_ERROR\]\u'
elif [[ -n "${SUDO_USER:-}" ]]; then
    MY_PROMPT="$MY_PROMPT"'\[$P_WARNING\]\u'
else
    MY_PROMPT="$MY_PROMPT"'\[$P_OK\]\u'
fi

# Shell level
if [[ ${SHLVL-0} -ne 1 ]]; then
    MY_PROMPT="$MY_PROMPT^$SHLVL"'\[$P_RESET\]'
fi

# @
if [[ $EUID -eq 0 ]]; then
    MY_PROMPT="${MY_PROMPT}"'\[$P_OK\]'"@"'\[$P_RESET\]'
else
    MY_PROMPT="${MY_PROMPT}"'\[$P_ERROR\]'"@"'\[$P_RESET\]'
fi

# SSH session
if [[ -n "${SSH_CONNECTION:-}" ]]; then
    MY_PROMPT="$MY_PROMPT"'\[$P_WARNING\]\h\[$P_RESET\]'
else
    MY_PROMPT="$MY_PROMPT"'\[$P_HOME\]\h\[$P_RESET\]'
fi

# Chroot jail path
if [[ -n "$chroot" ]]; then
    MY_PATH="$MY_PATH"'\[$P_WARNING\]'"$chroot"'\[$P_RESET\]'
fi

# Working directory, absolute path if we're in a chroot jail
MY_PATH="$MY_PATH"'\[$P_INFO\]'
if [[ -z "$chroot" ]]; then
    MY_PATH="$MY_PATH"'\w'
else
    MY_PATH="$MY_PATH"'$PWD'
fi
MY_PATH="$MY_PATH"'\[$P_RESET\]'

# Title bar
case "$TERM" in
    xterm*|rxvt*|Eterm|aterm|kterm|gnome*)
        MY_PATH="$MY_PATH"'\[\033]0;\u@\h:'"${chroot}"'${PWD}\007\]'
        ;;
    screen)
        MY_PATH="$MY_PATH"'\[\033_\u@\h:'"${chroot}"'${PWD}\033\\\'
        ;;
esac
unset chroot

# Running jobs, if any
prompt_jobs() {
    [ -n "$(jobs)" ] && printf '{%d}' $(jobs | sed -n '$=')
}
MY_PATH="$MY_PATH"'\[$P_WARNING\]'"\$(prompt_jobs)"'\[$P_RESET\]'

### Versionning Control Systems                                                 ----------
# We look for GIT then SVN -- called at runtime
prompt_vcs() {
    prompt_git || prompt_svn;
}
# Git prompt
prompt_git() {
    # Are we in a git repository?
    git branch &>/dev/null || return 1
    HEAD="$(git symbolic-ref HEAD 2>/dev/null)"
    BRANCH="${HEAD##*/}"
    GITSTATUS="$(git status 2>/dev/null)"
    [[ "$GITSTATUS" =~ "working directory clean" ]] || STATUS="❗ "
    # How many local commits do we have ahead of origin?
    NUM=$(echo $GITSTATUS | awk '/Your branch is ahead of/ {print "+"$11;}') || ""
    printf "(git:\[$P_OK\]%s\[$P_RESET\]%s\[$P_WARNING\]%s\[$P_RESET\])" "${BRANCH:-unknown}" "\[$P_ERROR\]${STATUS}\[$P_RESET\]" "${NUM}"
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
    REVNO="$(svnversion --no-newline)"
    [[ -n "$(svn status 2>/dev/null)" ]] && STATUS="❗ "
    printf "(svn:\[$P_OK\]%s\[$P_RESET\]%s\[$P_WARNING\]%s\[$P_RESET\])" "${BRANCH:-unknown}" "\[$P_ERROR\]${STATUS}\[$P_RESET\]" "${REVNO}"
}

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
[ -x /usr/local/bin/lesspipe.sh ] && eval "$(SHELL=/bin/sh lesspipe.sh)"        # OSX Brew variant

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
alias less='less -RM'
alias pstree='pstree -Ga'
alias info='info --vi-keys'
alias git-last-log='git log --summary HEAD^..'
alias git-home='git --work-tree=$HOME --git-dir=$HOME/.files.git'
alias ssh-vnc='ssh -o UserKnownHostsFile=/dev/null -C -L 5900:localhost:5900'
alias ssh-http='ssh -o UserKnownHostsFile=/dev/null -C -L 8080:localhost:80'
alias listen='lsof -n -i4TCP | grep LISTEN'
alias screen='screen -R -D'

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

# svn-color from JM Lacroix: https://github.com/jmlacroix/svn-color
source ~/.subversion/svn-color.sh

# get a successful return code no matter what
return 0

