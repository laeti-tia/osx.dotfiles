osx.dotfiles
============

My useful OSX $HOME dot files to be replicated on each of my OSX machine.

I'm making use of this repo as described by Kyle Fuller in
http://kylefuller.co.uk/posts/organising-dotfiles-in-a-git-repository/

To use it on a new machine, simply do:

    git --work-tree=$HOME --git-dir=$HOME/.files.git clone git@github.com:tonin/osx.dotfiles.git

And then later only use the `git-home` command instead of `git`.
