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
│       ├── signify.lua
│       └── undotree.lua
├── autoload
│   ├── functions.vim
│   └── search.vim
├── init.lua
├── lua
│   ├── autocommands.lua
│   ├── colorscheme.lua
│   ├── commands.lua
│   ├── diagnostics.lua
│   ├── init_plugins.lua
│   ├── keymaps.lua
│   ├── lsp.lua
│   ├── plugins.lua
│   ├── settings.lua
│   ├── statusline.lua
│   └── utils
│       ├── cmp.lua
│       ├── indentline.lua
│       ├── lspconfig.lua
│       ├── lsp.lua
│       ├── neodev.lua
│       ├── nvim-tmux-navigation.lua
│       └── treesitter.lua
└── README.md
```

Explanation for each of the above directories and files (as needed):
- `README.md`: This file. Contains the explanation of the Neovim setup.
- `after/ftplugin/`: Contains **f**ile**t**ype-specific settings and options
  which should be applied on particular file types.
- `after/plugin/`: Contains plugin-specific settings. Most of the plugins are
  set through `lua/init_plugins.lua`. Here are only plugins written in
  vimscript, which cannot otherwise be manually sourced by the user.
- `autoload/`: Functions that are loaded on demand.
- `init.lua`: The starting point of the configuration. Sources manually
  everything in `lua/`, since that doesn't get sourced automatically.
- `lua/`: Lua config files. The files are:
    - `autocommands.lua`: Contains auto-commands.
    - `colorscheme.lua`: Contains colorscheme related highlight groups.
    - `commands.lua`: Contains user-defined commands.
    - `diagnostics.lua`: Contains diagnostics related settings.
    - `init_plugins.lua`: Contains plugin initialization. All lua plugins that
      need to be manually sourced are found here. Vimscript plugins are found in
      `after/plugin/`.
    - `keymaps.lua`: Contains keymaps.
    - `lsp.lua`: Contains lsp settings for the built-in lsp. This also
      initializes plugin-related lsp settings.
    - `plugins.lua`: Contains all the plugin installations. Doesn't, however,
      contain the plugin settings as well (see `after/plugin/` for that).
    - `settings.lua`: Contains the general editor settings which are applied for
      all filetypes (nothing plugin-related; only basic vim settings and
      options).
    - `statusline.lua`: Contains scripts to define a custom status line. The
      style of the status line is designed to be the same as that of the Tmux
      environment. See also `lua/colorscheme.lua`, which defines the actual
      colors to be used.
    - `utils/`: Contains most of the plugin-related configurations and setups.

For more information on what each of these files should contain, see [this
gist](https://gist.github.com/nelstrom/1056049/784e252c3de653e204e9e128653010e19fbd493f).
