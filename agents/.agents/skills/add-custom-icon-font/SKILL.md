---
name: add-custom-icon-font
description: Add or rebuild the local custom icon font under ~/.local/share/fonts from named SVG sources plus icon-map.toml, checking required build tools early and rebuilding CustomIconFonts.ttf with nanoemoji.
---

# Add Custom Icon Font

Use this skill when the task is to add an SVG icon to the local custom icon font or rebuild `CustomIconFonts.ttf` from the existing icon set.

## Working area

- installed font: `~/.local/share/fonts/CustomIconFonts.ttf`
- persistent source SVGs: `~/.local/share/fonts/custom-svgs`
- persistent codepoint mapping: `~/.local/share/fonts/custom-svgs/icon-map.toml`
- fontconfig fallback override for system-wide font discovery: `~/.config/fontconfig/fonts.conf`
- helper script: `scripts/add_svg_icon.py`
- collision checker: `scripts/check_codepoints.py`
- nanoemoji config template: `references/nanoemoji-config.example.toml`

## Codepoint constraints

Codepoints must be in the **BMP PUA** range (U+E000–U+F8FF). Codepoints outside the BMP do not work in Qt applications including KDE Plasma notifications or other apps, because Qt does not perform font fallback for supplementary-plane characters.

`icon-map.toml` is the definitive source of truth for codepoint assignments. Do not change existing codepoints unless absolutely necessary — they are referenced in neovim and wezterm configs, and changing them requires updating those configs too. New icons are assigned the next sequential codepoint after the current highest.

Other PUA-using fonts (Nerd Fonts, Font Awesome, Codicons) may claim nearby codepoints in future versions. The build script checks each newly assigned codepoint against installed fonts and stops if a collision is detected. If a collision occurs:
1. run `check_codepoints.py` to identify affected codepoints and how much free space remains for a contiguous map
2. tell the user which codepoint(s) collide and what free range is available for a new icon
3. the user must decide whether to remap existing entries or pick a different range; remapping requires updating both `icon-map.toml` and the neovim/wezterm configs that reference those codepoints

## Prerequisites

- require `nanoemoji`, `fc-cache`, `fc-list`, and `fc-query`
- resolve tools from `PATH`; do not go searching elsewhere for them
- test dependencies before changing any files; if one is missing, stop and tell the user which one is missing

## Rules

1. keep human-readable source filenames like `neovim.svg`, `codex.svg`, and `claude.svg`
2. keep `custom-svgs` limited to named source SVGs plus `icon-map.toml`; `emoji_u<HEX>.svg` exists only in the temporary build directory
3. treat `icon-map.toml` as the persistent filename-to-codepoint mapping and preserve existing assignments
4. derive the next codepoint from the highest assigned private-use codepoint visible in `icon-map.toml`
5. rebuild `CustomIconFonts.ttf` from all mapped SVGs every time an icon is added or the mapping changes
6. stage new imports in memory and the temporary build directory first; do not update `custom-svgs` or `icon-map.toml` until the rebuild succeeds
7. normalize incoming SVGs before import when needed:
   - use numeric `width`, `height`, and `viewBox`
   - prefer a tight square canvas
   - avoid `1em` sizing
   - crop or recenter oversized canvases before rebuilding or the icon will render too small
8. after rebuilding, verify that the new codepoint renders and that the previous glyphs still exist

## Preferred workflow

1. inspect `~/.local/share/fonts/custom-svgs` and `icon-map.toml`
2. confirm `nanoemoji`, `fc-cache`, `fc-list`, and `fc-query` are available before mutating anything
3. if needed, normalize a working copy of the incoming SVG before import
4. run this skill's helper to stage the SVG, assign the next codepoint, rebuild the font, then persist the SVG and `icon-map.toml` only after the build succeeds:

```bash
python scripts/add_svg_icon.py /path/to/icon.svg --name short-name
```

5. if the sources or mapping already exist and only the font needs to be regenerated, run:

```bash
python scripts/add_svg_icon.py --rebuild
```

6. if debugging is needed, rerun with `--keep-build-dir`; the helper prints `kept build directory: ...` on success and `build directory preserved at ...` on failure:

```bash
python scripts/add_svg_icon.py --rebuild --keep-build-dir
```

7. inspect the generated `emoji_u<HEX>.svg` files and `custom-icon-fonts.toml` in that build directory if `nanoemoji` output or glyph placement looks wrong
8. ask the user to test the resulting codepoints with `printf` in the CLI (present the command to run)

## Troubleshooting

- if the helper says a required tool is missing, notify the user
- if the helper reports a codepoint collision, run `check_codepoints.py` to see which codepoints are affected and how much free space remains; tell the user and let them decide how to proceed — remapping codepoints requires updating both `icon-map.toml` and the neovim/wezterm configs
- if `fc-cache` succeeds but the terminal still shows fallback glyphs, verify the terminal is configured to use `CustomIconFonts.ttf` and then test with `printf`
- if Plasma notifications show boxes but the terminal works, verify `~/.config/fontconfig/fonts.conf` exists and contains the `Custom Icon Fonts` fallback override, then restart plasmashell (`kquitapp6 plasmashell; plasmashell &disown`) to pick up the change
- if the helper preserves a build directory, inspect the generated `emoji_u<HEX>.svg` files first; canvas size and centering problems usually show up there
- if `icon-map.toml` and `custom-svgs/*.svg` drift apart, fix the missing source or mapping entry before rebuilding
