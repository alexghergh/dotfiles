# don't set theme in non-interactive shells
if not status is-interactive
    return
end

# default theme style
set -l theme_style dark

# wezterm sets this env var
if test "$DOTFILES_THEME_STYLE" = light
    set theme_style light
end

set -g fish_color_cwd_root red
set -g fish_color_hg_added green
set -g fish_color_hg_clean green
set -g fish_color_hg_copied magenta
set -g fish_color_hg_deleted red
set -g fish_color_hg_dirty red
set -g fish_color_hg_modified yellow
set -g fish_color_hg_renamed magenta
set -g fish_color_hg_unmerged red
set -g fish_color_hg_untracked yellow
set -g fish_color_history_current --bold
set -g fish_color_match --background=brblue
set -g fish_color_status red
set -g fish_color_valid_path --underline

# light theme: TokyoNight Day
if test "$theme_style" = light
    set -g fish_color_autosuggestion 848cb5
    set -g fish_color_command 007197
    set -g fish_color_comment 848cb5
    set -g fish_color_end b15c00
    set -g fish_color_error f52a65
    set -g fish_color_escape 9854f1
    set -g fish_color_keyword 9854f1
    set -g fish_color_normal 3760bf
    set -g fish_color_operator 587539
    set -g fish_color_option 9854f1
    set -g fish_color_param 7847bd
    set -g fish_color_quote 8c6c3e
    set -g fish_color_redirection 3760bf
    set -g fish_color_search_match --background=b7c1e3
    set -g fish_color_selection --background=b7c1e3
    set -g fish_pager_color_completion 3760bf
    set -g fish_pager_color_description 848cb5
    set -g fish_pager_color_prefix 007197
    set -g fish_pager_color_progress 848cb5
    set -g fish_pager_color_selected_background --background=b7c1e3

# dark theme: TokyoNight Storm
else if test "$theme_style" = dark
    set -g fish_color_autosuggestion 565f89
    set -g fish_color_command 7dcfff
    set -g fish_color_comment 565f89
    set -g fish_color_end ff9e64
    set -g fish_color_error f7768e
    set -g fish_color_escape bb9af7
    set -g fish_color_keyword bb9af7
    set -g fish_color_normal c0caf5
    set -g fish_color_operator 9ece6a
    set -g fish_color_option bb9af7
    set -g fish_color_param 9d7cd8
    set -g fish_color_quote e0af68
    set -g fish_color_redirection c0caf5
    set -g fish_color_search_match --background=2e3c64
    set -g fish_color_selection --background=2e3c64
    set -g fish_pager_color_completion c0caf5
    set -g fish_pager_color_description 565f89
    set -g fish_pager_color_prefix 7dcfff
    set -g fish_pager_color_progress 565f89
    set -g fish_pager_color_selected_background --background=2e3c64
end
