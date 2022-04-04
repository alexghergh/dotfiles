# Zsh setup

The file structure of the Zsh setup:

```
.
├── README.md
├── .zprofile
├── .zsh_functions
│   └── ...
├── .zsh_misc_functions
│   └── ...
├── .zsh_other
│   └── ...
├── .zsh_plugins
│   └── ...
├── .zsh_prompts
│   └── ...
└── .zshrc
```

Explanation for each of the above directories and files (as needed):
- `README.md`: This file. Contains the explanation of the Zsh setup.
- `.zprofile`: (TODO)
- `.zsh_functions`: Contains various user-defined (autoloaded) functions. This
  means the functions are loaded on demand, and not when `.zshrc` is first
  sourced. This directory is added to the `fpath` Zsh variable.
- `.zsh_misc_functions`: Contains various user-defined (not autoloaded
  functions). The functions are loaded when `.zshrc` is first sourced. Mostly
  has functionality that is needed _right now_. The files are sourced manually,
  and **not** through `fpath`.
- `.zsh_other`: Contains basic setup for the shell itself. Includes files that
  set aliases, prompt and completion, environment variables, keybinds, shell
  options, zstyle options.
- `.zsh_plugins`: Contains setup for plugins of the shell. Such plugins are
  tools external to the shell (like fzf etc.).
- `.zsh_prompts`: Contains various user-defined prompts for the shell. The
  prompts are of the form `prompt_<name of prompt>_setup`, as dictated by Zsh.
- `.zshrc`: The main configuration file. This defines all other setup necessary
  for the shell.
