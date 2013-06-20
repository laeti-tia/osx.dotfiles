osx.dotfiles
============

My useful OSX $HOME dot files to be replicated on each of my OSX machine.

I'm making use of this repo as suggested and  described by [Kyle Fuller][1].

To use this repo on a new machine, do:

    git --work-tree=$HOME --git-dir=$HOME/.files.git clone git@github.com:tonin/osx.dotfiles.git

And then later only use the `git-home` command instead of `git` (see the git-home alias in `.bashrc`).

Credits
-------

The bash svn-color function sourced in `.bashrc` is coming from [JM Lacroix][2]

The VIM fugitive git wrapper and the pathogen autoloader are from [Tim Pope][3].

© 2013 - Antoine Delvaux

[1]: http://kylefuller.co.uk/posts/organising-dotfiles-in-a-git-repository/ "Organising dotfiles in a git repository"
[2]: https://github.com/jmlacroix/svn-color
[3]: http://github.com/tpope/vim-fugitive
