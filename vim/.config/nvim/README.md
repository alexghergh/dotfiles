# (Neo)vim setup

The file structure of the Neovim setup:

```
.
├── after
│   ├── ftplugin
│   │   ├── cpp.vim
│   │   ├── c.vim
│   │   ├── markdown.vim
│   │   └── ...
│   └── plugin
│       ├── lspconfig.lua
│       ├── nvim-tmux-navigation.lua
│       ├── signify.lua
│       ├── treesitter.lua
│       ├── undotree.lua
│       ├── vimade.lua
│       ├── colorscheme.lua
│       └── ...
├── autoload
│   ├── search.vim
│   └── ...
├── init.lua
├── lua
│   ├── autocommands.lua
│   ├── keymappings.lua
│   ├── plugins.lua
│   ├── settings.lua
│   └── statusline.lua
└── README.md
```

Explanation for each of the above directories and files (as needed):
- `README.md`: This file. Contains the explanation of the Neovim setup.
- `after/ftplugin/`: Contains **f**ile**t**ype-specific settings and options
  which should be applied on particular files. Such examples include textwidth,
  wrapping, spell-checking etc. The name of the file specifies the particular
  filetype.
- `after/plugin/`: Contains all the plugin-specific settings, which should be
  applied _after_ entering buffers.
- `autoload/`: Functions that don't need to be loaded on startup, but rather
  on-demand.
- `init.lua`: The starting point of the configuration. Contains links to load
  all the files in the `lua/` directory.
- `lua/`: Lua config files. The files represent:
    - `autocommands.lua`: Contains auto-commands.
    - `keymappings.lua`: Contains keymappings and other key settings.
    - `plugins.lua`: Contains all the plugin installations. Doesn't however
      contain the plugin settings as well (see `after/plugin/` for that).
    - `settings.lua`: Contains the general editor settings which are applied for
      all filetypes (nothing plugin-related; only basic vim settings and
      options).
    - `statusline.lua`: Contains scripts to define a custom status line. The
      style of the status line is designed to be the same as that of the Tmux
      environment. See also `after/plugin/colorscheme.lua`, which defines the
      actual colors to be used.

For more information on what each of these files should contain, see [this
gist](https://gist.github.com/nelstrom/1056049/784e252c3de653e204e9e128653010e19fbd493f).
