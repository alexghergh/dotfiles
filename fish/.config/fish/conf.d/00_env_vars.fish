# environment variables setup
#
# note: set -q only checks if the variable is defined; for set but empty
# variables, see the link below
# https://fishshell.com/docs/current/faq.html#how-do-i-check-whether-a-variable-is-not-empty

# DON'T RENAME THIS FILE; this _needs_ to run first when loading a shell, since
# other conf files depend on these vars

# disable fish's kitty keyboard protocol handling; this is broken on a dvorak
# layout keyboard, because both the physical key and the layout key are mapped
# (try `fish_key_reader`, press any ctrl-_ key combination; 2 keys show); this
# only drops fish's own extended-key prompt handling; other apps are unaffected
if not contains -- no-query-term $fish_features
    set -Ua fish_features no-query-term
end

# basic setup
set -gx EDITOR nvim
set -gx SYSTEMD_EDITOR nvim
set -gx VISUAL nvim
set -gx BROWSER firefox
set -gx PAGER less

# xdg base directories spec
# (https://specifications.freedesktop.org/basedir-spec/latest/ar01s03.html)
set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME "$HOME/.config"
set -q XDG_DATA_HOME; or set -gx XDG_DATA_HOME "$HOME/.local/share"
set -q XDG_CACHE_HOME; or set -gx XDG_CACHE_HOME "$HOME/.cache"
set -q XDG_STATE_HOME; or set -gx XDG_STATE_HOME "$HOME/.local/state"

set -q XDG_DATA_DIRS; or set -gx XDG_DATA_DIRS "/usr/local/share/:/usr/share/"
set --path XDG_DATA_DIRS $XDG_DATA_DIRS

set -q XDG_CONFIG_DIRS; or set -gx XDG_CONFIG_DIRS "/etc/xdg/"
set --path XDG_CONFIG_DIRS $XDG_CONFIG_DIRS

# common user directories
set -q PACKAGES; or set -gx PACKAGES "$HOME/packages"
set -q PROJECTS; or set -gx PROJECTS "$HOME/projects"

# set biber path, just a hack to work on Arch
#fish_add_path --path --append /usr/bin/vendor_perl

# user's local binaries
fish_add_path --path --prepend --move "$HOME/.local/bin"

# rustup/cargo tools
fish_add_path --path --prepend --move "$HOME/.cargo/bin"

# npm global installs (also see https://developer.fedoraproject.org/tech/languages/nodejs/nodejs.html)
fish_add_path --path --prepend --move "$HOME/.npm-global/bin"

# stylua (provided by mason.nvim)
fish_add_path --path --prepend --move "$XDG_DATA_HOME/nvim/mason/bin"

# japanese IME (see https://wiki.archlinux.org/title/Fcitx5)
set -gx XMODIFIERS @im=fcitx
