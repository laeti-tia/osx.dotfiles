My dotfiles for ~
=================

My useful ~ dot files to be replicated on each of my OSX, FreeBSD or Linux machines.  At the beginning, this used to be a placeholder for OSX dot files only.  But as I'm working with different types of UNIX hosts, I try to keep as much compatibility as possible.  Currently, the files are tested with recent versions of:
- OSX (10.6 - 10.10)
- FreeBSD (9)
- Debian (6 - 7)
- CentOS (5 - 6)

I'm making use of this repo as suggested and described by [Kyle Fuller][kf].

To use this repo on a new machine, do:

    git --work-tree=$HOME --git-dir=$HOME/.files.git init
    git --work-tree=$HOME --git-dir=$HOME/.files.git remote add origin https://github.com/tonin/osx.dotfiles.git
    mv .bashrc bashrc.bkp
    git --work-tree=$HOME --git-dir=$HOME/.files.git pull origin master
    git --git-dir=$HOME/.files.git submodule update --init

And then later only use the `git-home` command instead of `git` (see the git-home alias in `.bashrc`).

On OSX, if you want to use the included `~/.bashrc` file, you need to source it from the system's global `/etc/bashrc`  You just add a single line to the existing configuration that contains: `. ~/bashrc`

You might want to clone this repository and customise some files to your needs and settings.


Credits
-------

- The bash svn-color function sourced in `.bashrc` is coming from [Jean-Michel Lacroix][jml].
- The VIM fugitive git wrapper and the pathogen autoloader are from [Tim Pope][tp].
- The VIM JSON plugin is from [Eli Parra][ep].
- The VIM XML pretty format plugin is from [Cory][cory].
- The git-scripts are from [jwiegley repo][jwiegley].


Copyright and licence
---------------------

© 2013 - 2014 — Antoine Delvaux — All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice and this
   list of conditions.
2. Redistributions in binary form must reproduce the above copyright notice and
   this list of conditions in the documentation and/or other materials provided
   with the distribution.

[kf]: http://kylefuller.co.uk/posts/organising-dotfiles-in-a-git-repository/ "Organising dotfiles in a git repository"
[jml]: https://github.com/jmlacroix/svn-color
[tp]: http://github.com/tpope/vim-fugitive
[ep]: https://github.com/elzr/vim-json
[cory]: http://vim.wikia.com/wiki/Pretty-formatting_XML
[jwiegley]: https://github.com/jwiegley/git-scripts
