#!/usr/bin/env bash
cd $(dirname "$0")
git submodule update --init
/bin/cp .* ~/ 2>/dev/null
/bin/mkdir -p ~/.git-scripts/
/bin/cp .git-scripts/* ~/.git-scripts/
/bin/cp .ssh/authorized_keys ~/.ssh/
/bin/mkdir -p ~/.subversion
/bin/cp .subversion/* ~/.subversion/
/bin/cp -a .vim ~/
/bin/rm -rf ~/.files.git
echo 'Deployed!'
