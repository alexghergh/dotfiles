# Fish setup

The file structure of the fish setup:

```
.
├── completions/
├── conf.d/
│   ├── abbr.fish
│   └── env_vars.fish
├── config.fish
├── fish_variables
├── functions/
│   ├── fish_prompt.fish
│   ├── fish_right_prompt.fish
│   └── ...
├── README.md
└── colors/
    └── Pastel night.fish
```

Meaning for each of the above directories and files
- `completions`: Contains user-generated completions for commands. Most commands
  already have completion defined by the fish shell. This folder only contains
  custom ones.
- `conf.d`: Fish scripts sourced **before** `config.fish`, on every new shell.
  - `abbr.fish`: Abbreviations (strings that get expanded as necessary;
    loosely akin to aliases in other shells, however more powerful)
  - `env_vars.fish`: Environment variables setup.
- `config.fish`: The main configuration script that gets executed upon opening a
  fish shell, both in interactive/non-interactive and login/non-login shells.
- `fish_variables`: Universally defined variables. Visible to any fish shell.
- `functions`: Auto-loaded user functions, as well as other shell-configuration
  functions.
  - `fish_prompt.fish` and `fish_right_prompt.fish`: Configuration function to
    set the shell's left and right prompts.
- `README.md`: This file.
- `colors`: Shell colors for specific themes, used to set up the colors.
  **Note:** while fish has its own thing about setting themes (see
  [fish_config](https://fishshell.com/docs/current/cmds/fish_config.html)),
  which enables users to drop their theme files in `~/.config/fish/themes`,
  these theme files only support the built-in `fish_color...` variables.
  Therefore, this directory (i.e. `colors/`) enables the shell to be more
  versatile, by allowing custom variables as colors (in the end, all those end
  up in `fish_variables` as universal variables; the only downside is that
  `fish_config` won't be able to pick those up and display them as a theme when
  using `fish_config prompt show`). To actually select a scheme, use
  `functions/setscheme.fish`.
