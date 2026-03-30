#!/usr/bin/env python3
"""Check whether the custom icon font's BMP PUA codepoints collide with other installed fonts."""

import shutil
import subprocess
import sys
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError:  # pragma: no cover - fallback for older python
    import tomli as tomllib

BMP_PUA_START = 0xE000
BMP_PUA_END = 0xF8FF
OWN_FAMILY = "Custom Icon Fonts"


def die(message: str) -> None:
    print(f"error: {message}", file=sys.stderr)
    raise SystemExit(1)


def load_icon_map() -> list[tuple[str, int]]:
    map_path = Path.home() / ".local" / "share" / "fonts" / "custom-svgs" / "icon-map.toml"
    if not map_path.is_file():
        return []
    data = tomllib.loads(map_path.read_text())
    entries = data.get("icons", [])
    result: list[tuple[str, int]] = []
    for item in entries:
        text = str(item.get("codepoint", "")).strip().upper()
        if text.startswith("U+"):
            text = text[2:]
        result.append((str(item.get("filename", "")), int(text, 16)))
    return result


def foreign_families(fc_list: Path, codepoint: int) -> list[str]:
    """Return font families other than our own that claim this codepoint."""
    result = subprocess.run(
        [str(fc_list), f":charset={codepoint:04X}", "family"],
        capture_output=True,
        text=True,
    )
    families = [
        line.strip().rstrip(",")
        for line in result.stdout.strip().splitlines()
        if line.strip()
    ]
    return [f for f in families if f != OWN_FAMILY]


def count_free_after(fc_list: Path, start: int) -> int:
    """Count consecutive free codepoints starting at `start`, up to BMP PUA end."""
    count = 0
    for cp in range(start, BMP_PUA_END + 1):
        if foreign_families(fc_list, cp):
            break
        count += 1
    return count


def main() -> None:
    fc_list_path = shutil.which("fc-list")
    if not fc_list_path:
        die("fc-list not found on PATH")
    fc_list = Path(fc_list_path)

    entries = load_icon_map()
    if not entries:
        print("no codepoints mapped in icon-map.toml")
        return

    mapped_codepoints = {cp for _, cp in entries}
    print(f"checking {len(mapped_codepoints)} mapped codepoint(s) for collisions...")

    collisions: dict[int, list[str]] = {}
    for cp in sorted(mapped_codepoints):
        foreign = foreign_families(fc_list, cp)
        if foreign:
            collisions[cp] = foreign

    if not collisions:
        print("no collisions found")
        next_cp = max(mapped_codepoints) + 1
        free = count_free_after(fc_list, next_cp)
        print(f"{free} consecutive free codepoint(s) available after U+{next_cp - 1:04X}")
        return

    print(f"\nfound {len(collisions)} collision(s):\n")
    for cp, families in collisions.items():
        names = [fn for fn, c in entries if c == cp]
        icon_name = names[0] if names else "?"
        print(f"  U+{cp:04X} ({icon_name}): {', '.join(families)}")

    print("\nexisting codepoints must be remapped; update icon-map.toml and "
          "any configs that reference these codepoints (neovim, wezterm)")
    raise SystemExit(1)


if __name__ == "__main__":
    main()
