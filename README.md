osx.dotfiles
============

My useful OSX $HOME dot files to be replicated on each of my OSX machine.

I'm making use of this repo as described by [Kyle Fuller][1].

To use this repo on a new machine, do:

    git --work-tree=$HOME --git-dir=$HOME/.files.git clone git@github.com:tonin/osx.dotfiles.git

And then later only use the `git-home` command instead of `git` (see the git-home alias in `.bashrc`).

[1]: http://kylefuller.co.uk/posts/organising-dotfiles-in-a-git-repository/ "Organising dotfiles in a git repository"
