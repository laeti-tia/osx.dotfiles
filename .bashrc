# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# When debugging is needed
#shopt -os xtrace
#shopt -ou xtrace

### Default environment                                                 ----------
export PATH=~/.git-scripts:/usr/local/bin:/usr/local/sbin:$PATH
export MAVEN_OPTS="-XX:MaxPermSize=256m"
# We use vi mode and vim as EDITOR
set -o vi
export EDITOR=vim
# check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize
export MANWIDTH="tty"

### Setting a sane locale
LANGUAGE="fr:es:en"
if locale -a | grep -iq 'fr_BE.UTF'; then
    export LANG=fr_BE.UTF-8
elif locale -a | grep -iq 'en_US.UTF'; then
    export LANG=en_US.UTF-8
elif locale -a | grep -iq 'C.UTF'; then
    export LANG=C.UTF-8
else
    export LANG=C
fi

### History                                                             ----------
# ignoredups and ignorespace, append to the history file, don't overwrite it
export HISTCONTROL=ignoreboth
export HISTSIZE=9999
export HISTFILESIZE=9999
shopt -s histappend
# keep multi-seesion history fine
PROMPT_COMMAND='history -a'

### ssh agent forwarding and screen
# Predictable SSH authentication socket location.
SOCK="/tmp/ssh-agent-$USER-screen"
if test $SSH_AUTH_SOCK && [ $SSH_AUTH_SOCK != $SOCK ]; then
    rm -f /tmp/ssh-agent-$USER-screen
    ln -sf $SSH_AUTH_SOCK $SOCK
    export SSH_AUTH_SOCK=$SOCK
fi

### Debian chroot                                                       ---------- 
# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
    chroot=debian_chroot
fi

### Prompt                                                              ----------
# We use promptvars
shopt -s promptvars

# Some useful prompt formating using tput
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

# How many colors can we print?
if [[ $TERM == 'xterm' || $TERM =~ 'screen' ]]; then
    # Try to set a higher standard
    export TERM="xterm-256color"
    if [ $(tput colors) -lt 9 ]; then
        # revert back to regular xterm
        export TERM="xterm"
    fi
fi
colors=$(tput colors 2>/dev/null)
if [ $? -ne 0 ]; then
    colors=2
fi

if [ $colors -gt 2 ]; then
    # Let's hope for at least 8 colors
    export CLICOLOR=1
    export LSCOLORS=ExGxFxDxCxDaDaabagecec
    alias ls='ls --color=auto'
    export PAGER="less -sRM"
    [ -x /usr/bin/dircolors ] && eval "`dircolors -b`"
    export LESS="--RAW-CONTROL-CHARS"
    alias grep='grep --color=auto'
    export GREP_COLOR='39;33'
    P_HOME="$(tput ${MD} && tput ${AF} 3)"
    P_OK="$(tput ${MD} && tput ${AF} 2)"
    P_ERROR="$(tput ${MD} && tput ${AF} 1)"
    P_WARNING="$(tput ${MD} && tput ${AF} 3)"
    P_NORMAL="$(tput ${MD} && tput ${AF} 7)"
    P_INFO="$(tput ${MD} && tput ${AF} 6)"
fi
if [ $colors -gt 8 ]; then
    # Colorful
    export LESS_TERMCAP_mb=$'\e[38;5;009m'
    export LESS_TERMCAP_md=$'\e[38;5;010m'
    export LESS_TERMCAP_me=$'\e[0m'
    export LESS_TERMCAP_se=$'\e[0m'
    export LESS_TERMCAP_so=$'\e[48;5;004m'
    export LESS_TERMCAP_ue=$'\e[0m'
    export LESS_TERMCAP_us=$'\e[38;5;012m'
    alias grep='grep --color=auto'
    export GREP_COLOR='38;5;208'
    P_HOME="$(tput ${AF} 11)"
    P_OK="$(tput ${AF} 10)"
    P_ERROR="$(tput ${AF} 9)"
    P_WARNING="$(tput ${AF} 214)"
    P_NORMAL="$(tput ${AF} 15)"
    P_INFO="$(tput ${AF} 12)"
fi

# Bold and reset should be supported on all terminals
P_BOLD="$([[ $colors -gt 2 ]] && tput ${MD})"
P_RESET="$([[ $colors -gt 2 ]] && tput ${ME})"

# Exit code
# TODO: it would be nice to print the return code at the far right end of the line
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
PS2="… "

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

# Running in an SSH session or under Docker (or other Hypervisor)
`grep -sqE "^flags[[:space:]]+: .+ hypervisor .+$" /proc/cpuinfo`
if [[ $? -eq 0 || -n "${SSH_CONNECTION:-}" ]]; then
    MY_PROMPT="$MY_PROMPT"'\[$P_WARNING\]'
else
    MY_PROMPT="$MY_PROMPT"'\[$P_HOME\]'
fi

# Get the computer name correct, even if using dhcp with forced hostname
if [ `uname` == Darwin ]; then
    MY_PROMPT="$MY_PROMPT"$(scutil --get ComputerName)'\[$P_RESET\]'
else
    MY_PROMPT="$MY_PROMPT"'\h\[$P_RESET\]'
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
        MY_PATH="$MY_PATH"'\[\033_\u@\h:'"${chroot}"'${PWD}\033\]'
        ;;
esac
unset chroot

# Running jobs, if any
prompt_jobs() {
    [ -n "$(jobs)" ] && printf '{%d}' $(jobs | sed -n '$=')
}
MY_PATH="$MY_PATH"'\[$P_WARNING\]'"\$(prompt_jobs)"'\[$P_RESET\]'

### Versionning Control Systems                                         ----------
# We look for GIT then SVN -- called at runtime
prompt_vcs() {
    prompt_git || prompt_svn;
}
# Git prompt
prompt_git() {
    # Are we in a git repository?
    git branch --no-color &>/dev/null || return 1
    HEAD="$(git symbolic-ref HEAD 2>/dev/null)"
    BRANCH="${HEAD#refs\/heads\/}"
    # TODO: should probably use git status -sb
    GITSTATUS="$(LANG=C git status --show-stash 2>/dev/null)"
    GITSTATUS=${GITSTATUS//\# /}
    [[ $GITSTATUS =~ working\ (directory|tree)\ clean ]] || STATUS="!"
    # How many local commits do we have ahead of origin?
    NUM=$(echo "$GITSTATUS" | awk '/Your branch is ahead of / {print "+"$8;}') || ""
    # And what does the stash contains?
    STASH=$(echo "$GITSTATUS" | awk '/Your stash currently has / {print "•"$5;}') || ""
    printf "(git:\[$P_OK\]%s\[$P_RESET\]%s\[$P_WARNING\]%s\[$P_RESET\])" "${BRANCH:-unknown}" "\[$P_ERROR\]${STATUS}\[$P_RESET\]" "${NUM}${STASH}"
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


### Alias definitions                                                   ----------
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
alias git-home='git --work-tree=$HOME --git-dir=$HOME/.config/dotfiles/.git'
alias ssh-unknown='ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
alias ssh-vnc='ssh -o UserKnownHostsFile=/dev/null -C -L 5900:localhost:5900'
alias ssh-http='ssh -o UserKnownHostsFile=/dev/null -C -L 8080:localhost:80'
alias listen='lsof -n -i4TCP | grep LISTEN'
alias screen='screen -R -D'
alias zfslist='zfs list -o name,used,avail,logicalused,refer,mountpoint,compression,compressratio,creation'
alias VBoxHeadless='VBoxHeadless --vrde off'
alias dquilt="quilt --quiltrc=${HOME}/.quiltrc-dpkg"
alias top="LANG=C top"
alias youtube-dl-mp4="youtube-dl --format mp4"
complete -F _quilt_completion $_quilt_complete_opt dquilt

# A nice ps | grep, see https://serverfault.com/questions/367921/how-to-prevent-ps-reporting-its-own-process
psgrep ()
{
    pattern=[^]]${1};
    case "$(uname -s)" in
        Darwin)
            ps -A -ww -o user,pid,ppid,nice,pri,pcpu,pmem,stat,start,time,wchan,command | grep -e "^[[:space:]]*USER" -e ${pattern}
        ;;
        Linux)
            ps -A -ww -o user,pid,ppid,tid,nice,pri,pcpu,pmem,etime,wchan:20,stat,command | grep -e "^[[:space:]]*PID" -e ${pattern}
        ;;
        *)  # other UNIX flavors get a minimalist version.
            ps -A -ww | grep -i -e ${pattern}
        ;;
    esac
}

# Bash completion, if installed
if [ -f /usr/share/bash-completion/bash_completion ]; then
    # on Debian
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    # on older Debian and other Linux
    . /etc/bash_completion
elif [ -f /usr/local/bin/brew ] && [ -f `brew --prefix`/etc/bash_completion ]; then
    # on OSX with brew
    . `brew --prefix`/etc/bash_completion
elif [ -f /usr/local/etc/bash_completion ]; then
    # on FreeBSD if installed ("pkg install bash-completion")
    . /usr/local/etc/bash_completion
fi

# FreeBSD and OSX only
if [[ `uname` =~ (Darwin|FreeBSD) ]]; then
    alias top='/usr/bin/top -u -s 2 -S'
    alias pstree='/usr/local/bin/pstree -g 3'
    alias ls='ls -G'
    alias ll='ls -lh'
    if [ `uname` == FreeBSD ]; then
        alias top='/usr/bin/top -a -z -s 2 -S'
    fi
    if [[ `uname` == Darwin ]]; then
        ulimit -n 2048
    fi
fi

# svn-color from JM Lacroix: https://github.com/jmlacroix/svn-color
[ -f ~/.subversion/svn-color.sh ] && source ~/.subversion/svn-color.sh

# source any local settings
[ -f ~/.bashrc.local ] && source ~/.bashrc.local

# get a successful return code no matter what
return 0

