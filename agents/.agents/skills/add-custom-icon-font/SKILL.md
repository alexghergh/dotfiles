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
- helper script: `scripts/add_svg_icon.py`
- nanoemoji config template: `references/nanoemoji-config.example.toml`

## Prerequisites

- require `nanoemoji`, `fc-cache`, and `fc-query`
- resolve tools from `PATH`; do not go searching elsewhere for them
- test dependencies before changing any files; if one is missing, stop and tell the user which one is missing

## Rules

1. keep human-readable source filenames like `neovim.svg`, `codex.svg`, and `claude.svg`
2. keep `custom-svgs` limited to named source SVGs plus `icon-map.toml`; `emoji_u<HEX>.svg` exists only in the temporary build directory
3. treat `icon-map.toml` as the persistent filename-to-codepoint mapping and preserve existing assignments
4. derive the next codepoint from the highest assigned private-use codepoint visible in either `CustomIconFonts.ttf` or `icon-map.toml`; if the font is missing, fall back to the highest mapped codepoint
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
2. confirm `nanoemoji`, `fc-cache`, and `fc-query` are available before mutating anything
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
- if `fc-cache` succeeds but the terminal still shows fallback glyphs, verify the terminal is configured to use `CustomIconFonts.ttf` and then test with `printf`
- if the helper preserves a build directory, inspect the generated `emoji_u<HEX>.svg` files first; canvas size and centering problems usually show up there
- if `icon-map.toml` and `custom-svgs/*.svg` drift apart, fix the missing source or mapping entry before rebuilding
