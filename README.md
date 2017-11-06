My dotfiles for ~
=================

My useful ~ dot files to be replicated on each of my MacOS, FreeBSD or Linux machines.  At the beginning, this used to be a placeholder for OSX dot files only.  But as I'm working with different types of UNIX hosts, I try to keep as much compatibility as possible.  Currently, the files are tested with recent versions of:
- OSX (10.12)
- FreeBSD (10)
- Debian (8,9) (and 7 with an updated git)
- CentOS (6)

I was making use of this repo as suggested and described by [Kyle Fuller][kf].  But I'm now using it following the [DebOps][debops] conventions, using a deploy script.

To use this repo on a new machine, do:

    git clone https://github.com/tonin/osx.dotfiles.git .config/dotfiles
    ./.config/dotfiles/deploy.sh

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

© 2013 - 2017 — Antoine Delvaux — All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice and this
   list of conditions.
2. Redistributions in binary form must reproduce the above copyright notice and
   this list of conditions in the documentation and/or other materials provided
   with the distribution.

[kf]: http://kylefuller.co.uk/posts/organising-dotfiles-in-a-git-repository/ "Organising dotfiles in a git repository"
[debops]: https://docs.debops.org/en/latest/ansible/roles/ansible-users/docs/index.html
[jml]: https://github.com/jmlacroix/svn-color
[tp]: http://github.com/tpope/vim-fugitive
[ep]: https://github.com/elzr/vim-json
[cory]: http://vim.wikia.com/wiki/Pretty-formatting_XML
[jwiegley]: https://github.com/jwiegley/git-scripts
