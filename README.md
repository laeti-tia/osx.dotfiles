osx.dotfiles for ~
==================

My useful OSX ~ dot files to be replicated on each of my OSX machines.

I'm making use of this repo as suggested and  described by [Kyle Fuller][1].

To use this repo on a new machine, do:

    git --work-tree=$HOME --git-dir=$HOME/.files.git clone git@github.com:tonin/osx.dotfiles.git

And then later only use the `git-home` command instead of `git` (see the git-home alias in `.bashrc`).


Credits
-------

- The bash svn-color function sourced in `.bashrc` is coming from [Jean-Michel Lacroix][2].
- The bash `idiff.sh` script is coming from [pixelbeat.org][4]
- The VIM fugitive git wrapper and the pathogen autoloader are from [Tim Pope][3].


Copyright and licence
---------------------

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
