osx.dotfiles for ~
==================

My useful OSX $HOME dot files to be replicated on each of my OSX machine.

I'm making use of this repo as suggested and described by [Kyle Fuller][1].

To use this repo on a new machine, do:

    git --work-tree=$HOME --git-dir=$HOME/.files.git init
    git --work-tree=$HOME --git-dir=$HOME/.files.git remote add origin git@github.com:tonin/osx.dotfiles.git
    git --work-tree=$HOME --git-dir=$HOME/.files.git pull origin master
    git --git-dir=$HOME/.files.git submodule update --init

And then later only use the `git-home` command instead of `git` (see the git-home alias in `.bashrc`).

You might want to clone this repository and customise some files to your needs and settings.


Credits
-------

- The bash svn-color function sourced in `.bashrc` is coming from [JM Lacroix][2].
- The bash `idiff.sh` script is coming from [pixelbeat.org][4]
- The VIM fugitive git wrapper and the pathogen autoloader are from [Tim Pope][3].


Licence
------

© 2013 — Antoine Delvaux — All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice and this
   list of conditions.
2. Redistributions in binary form must reproduce the above copyright notice and
   this list of conditions in the documentation and/or other materials provided
   with the distribution.

[1]: http://kylefuller.co.uk/posts/organising-dotfiles-in-a-git-repository/ "Organising dotfiles in a git repository"
[2]: https://github.com/jmlacroix/svn-color
[3]: http://github.com/tpope/vim-fugitive
[4]: http://www.pixelbeat.org/scripts/idiff
