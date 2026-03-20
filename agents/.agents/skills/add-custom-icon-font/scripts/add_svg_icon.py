#!/usr/bin/env python3
"""Rebuild the local custom icon font from named SVG sources."""

import argparse
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError:  # pragma: no cover - fallback for older python
    import tomli as tomllib

START_CODEPOINT = 0xFF000
SAFE_FILENAME_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]*\.svg$")
CHARSET_TOKEN_RE = re.compile(r"^[0-9A-Fa-f]+(?:-[0-9A-Fa-f]+)?$")
CONFIG_TEMPLATE_PATH = (
    Path(__file__).resolve().parent.parent / "references" / "nanoemoji-config.example.toml"
)


def die(message: str) -> None:
    print(f"error: {message}", file=sys.stderr)
    raise SystemExit(1)


def font_paths() -> tuple[Path, Path, Path, Path]:
    fonts_root = Path.home() / ".local" / "share" / "fonts"
    source_root = fonts_root / "custom-svgs"
    map_path = source_root / "icon-map.toml"
    output_ttf = fonts_root / "CustomIconFonts.ttf"
    return fonts_root, source_root, map_path, output_ttf


def require_tool(name: str) -> Path:
    tool = shutil.which(name)
    if tool:
        return Path(tool)
    die(f"missing required tool '{name}' on PATH")


def require_file(path: Path, description: str) -> Path:
    if path.is_file():
        return path
    die(f"missing {description}: {path}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Add an SVG icon to ~/.local/share/fonts/custom-svgs, assign the next available "
            "private-use codepoint, and rebuild CustomIconFonts.ttf."
        )
    )
    parser.add_argument("svg", nargs="?", help="path to the SVG file to import")
    parser.add_argument(
        "--name",
        help="target icon filename in custom-svgs, with or without the .svg suffix",
    )
    parser.add_argument(
        "--rebuild",
        action="store_true",
        help="rebuild the font from custom-svgs and icon-map.toml without importing a new SVG",
    )
    parser.add_argument(
        "--keep-build-dir",
        action="store_true",
        help="keep the temporary nanoemoji build directory for debugging",
    )
    args = parser.parse_args()
    if bool(args.svg) == bool(args.rebuild):
        parser.error("provide an SVG to import or pass --rebuild")
    if args.rebuild and args.name:
        parser.error("--name can only be used when importing an SVG")
    return args


def parse_codepoint(value: object) -> int:
    text = str(value).strip().upper()
    if text.startswith("U+"):
        text = text[2:]
    if not text or any(ch not in "0123456789ABCDEF" for ch in text):
        die(f"invalid codepoint value: {value!r}")
    codepoint = int(text, 16)
    if codepoint < START_CODEPOINT:
        die(f"codepoint U+{codepoint:X} is below the expected private-use range")
    return codepoint


def load_icon_map(map_path: Path) -> list[tuple[str, int]]:
    if not map_path.exists():
        return []

    try:
        data = tomllib.loads(map_path.read_text())
    except tomllib.TOMLDecodeError as exc:
        die(f"invalid TOML in {map_path}: {exc}")

    raw_entries = data.get("icons")
    if raw_entries is None:
        return []
    if not isinstance(raw_entries, list):
        die(f"expected 'icons' to be an array in {map_path}")

    entries: list[tuple[str, int]] = []
    seen_filenames: set[str] = set()
    seen_codepoints: set[int] = set()
    for item in raw_entries:
        if not isinstance(item, dict):
            die(f"invalid icon entry in {map_path}: {item!r}")
        filename = str(item.get("filename", "")).strip()
        if not SAFE_FILENAME_RE.fullmatch(filename):
            die(f"invalid SVG filename in {map_path}: {filename!r}")
        codepoint = parse_codepoint(item.get("codepoint", ""))
        if filename in seen_filenames:
            die(f"duplicate filename in {map_path}: {filename}")
        if codepoint in seen_codepoints:
            die(f"duplicate codepoint in {map_path}: U+{codepoint:X}")
        seen_filenames.add(filename)
        seen_codepoints.add(codepoint)
        entries.append((filename, codepoint))

    return sorted(entries, key=lambda entry: entry[1])


def write_icon_map(map_path: Path, entries: list[tuple[str, int]]) -> None:
    lines = ["# filename -> private-use codepoint mapping for CustomIconFonts", ""]
    for filename, codepoint in sorted(entries, key=lambda entry: entry[1]):
        lines.extend(
            [
                "[[icons]]",
                f'filename = "{filename}"',
                f'codepoint = "{codepoint:X}"',
                "",
            ]
        )

    temp_path: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            "w",
            encoding="utf-8",
            dir=map_path.parent,
            prefix=f".{map_path.name}.",
            delete=False,
        ) as handle:
            handle.write("\n".join(lines).rstrip() + "\n")
            temp_path = Path(handle.name)
        temp_path.replace(map_path)
    finally:
        if temp_path is not None and temp_path.exists():
            temp_path.unlink()


def sanitize_filename(name: str) -> str:
    filename = name.strip()
    if not filename:
        die("icon name cannot be empty")
    if not filename.lower().endswith(".svg"):
        filename = f"{filename}.svg"
    if not SAFE_FILENAME_RE.fullmatch(filename):
        die(
            "icon name must produce a safe SVG filename using letters, digits, dots, underscores, or hyphens"
        )
    return filename


def inspect_font(output_ttf: Path, fc_query: Path) -> tuple[set[int], int | None]:
    if not output_ttf.is_file():
        return set(), None

    result = subprocess.run(
        [str(fc_query), "--format=%{charset}\n", str(output_ttf)],
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        stderr = result.stderr.strip() or "unknown error"
        die(f"fc-query could not inspect {output_ttf}: {stderr}")

    codepoints: set[int] = set()
    max_codepoint: int | None = None
    for token in result.stdout.split():
        if not CHARSET_TOKEN_RE.fullmatch(token):
            continue

        if "-" in token:
            start_text, end_text = token.split("-", 1)
            start = int(start_text, 16)
            end = int(end_text, 16)
        else:
            start = int(token, 16)
            end = start

        if end < START_CODEPOINT:
            continue

        start = max(start, START_CODEPOINT)
        codepoints.update(range(start, end + 1))
        if max_codepoint is None or end > max_codepoint:
            max_codepoint = end

    return codepoints, max_codepoint


def next_codepoint(entries: list[tuple[str, int]], installed_max: int | None) -> int:
    mapped_max = max((codepoint for _, codepoint in entries), default=None)
    current_max = max(
        (codepoint for codepoint in (installed_max, mapped_max) if codepoint is not None),
        default=None,
    )
    if current_max is None:
        return START_CODEPOINT
    return current_max + 1


def plan_import(
    svg_arg: str,
    name_arg: str | None,
    source_root: Path,
    map_path: Path,
    entries: list[tuple[str, int]],
    installed_max: int | None,
) -> tuple[list[tuple[str, int]], tuple[Path, str]]:
    source_path = Path(svg_arg).expanduser().resolve()
    if not source_path.is_file():
        die(f"missing SVG file: {source_path}")
    if source_path.suffix.lower() != ".svg":
        die("the imported file must be an .svg")

    filename = sanitize_filename(name_arg or source_path.stem)
    if filename == map_path.name:
        die(f"{filename} is reserved")
    if any(existing == filename for existing, _ in entries):
        die(f"an icon named {filename} already exists")

    target_path = source_root / filename
    if target_path.exists() or target_path.is_symlink():
        die(f"refusing to overwrite existing path: {target_path}")

    codepoint = next_codepoint(entries, installed_max)
    updated_entries = sorted(entries + [(filename, codepoint)], key=lambda entry: entry[1])
    return updated_entries, (source_path, filename)


def build_font(
    source_root: Path,
    entries: list[tuple[str, int]],
    pending_import: tuple[Path, str] | None,
    nanoemoji: Path,
) -> tuple[Path, Path]:
    if not entries:
        die("icon map is empty; there is nothing to build")

    build_root = Path(tempfile.mkdtemp(prefix="custom-icon-font-build-"))
    try:
        seen_build_names: set[str] = set()
        for filename, codepoint in entries:
            source_path = source_root / filename
            if pending_import is not None and filename == pending_import[1]:
                source_path = pending_import[0]
            if not source_path.is_file():
                die(f"missing mapped SVG: {source_path}")

            build_name = f"emoji_u{codepoint:X}.svg"
            if build_name in seen_build_names:
                die(f"duplicate codepoint staged for build: U+{codepoint:X}")
            seen_build_names.add(build_name)
            shutil.copy2(source_path, build_root / build_name)

        shutil.copy2(
            require_file(CONFIG_TEMPLATE_PATH, "nanoemoji config template"),
            build_root / "custom-icon-fonts.toml",
        )
        subprocess.run(
            [str(nanoemoji), "custom-icon-fonts.toml"],
            cwd=build_root,
            check=True,
        )

        built_ttf = build_root / "build" / "CustomIconFonts.ttf"
        if not built_ttf.is_file():
            die(f"expected rebuilt font at {built_ttf}")
        return build_root, built_ttf
    except BaseException:
        print(f"build directory preserved at {build_root}", file=sys.stderr)
        raise


def verify_font(ttf_path: Path, entries: list[tuple[str, int]], fc_query: Path) -> None:
    installed, _ = inspect_font(ttf_path, fc_query)
    expected = {codepoint for _, codepoint in entries}
    missing = sorted(expected - installed)
    unexpected = sorted(installed - expected)
    if not missing and not unexpected:
        return

    parts: list[str] = []
    if missing:
        parts.append("missing " + ", ".join(f"U+{codepoint:X}" for codepoint in missing))
    if unexpected:
        parts.append("unexpected " + ", ".join(f"U+{codepoint:X}" for codepoint in unexpected))
    die(f"rebuilt font verification failed: {'; '.join(parts)}")


def persist_import(
    source_root: Path,
    map_path: Path,
    entries: list[tuple[str, int]],
    pending_import: tuple[Path, str] | None,
) -> None:
    if pending_import is None:
        return

    source_path, filename = pending_import
    target_path = source_root / filename
    shutil.copy2(source_path, target_path)
    try:
        write_icon_map(map_path, entries)
    except BaseException:
        target_path.unlink(missing_ok=True)
        raise


def main() -> None:
    args = parse_args()
    nanoemoji = require_tool("nanoemoji")
    fc_cache = require_tool("fc-cache")
    fc_query = require_tool("fc-query")
    require_file(CONFIG_TEMPLATE_PATH, "nanoemoji config template")

    fonts_root, source_root, map_path, output_ttf = font_paths()
    fonts_root.mkdir(parents=True, exist_ok=True)
    source_root.mkdir(parents=True, exist_ok=True)

    entries = load_icon_map(map_path)
    _, installed_max = inspect_font(output_ttf, fc_query)

    pending_import: tuple[Path, str] | None = None
    new_entry: tuple[str, int] | None = None
    if args.svg:
        entries, pending_import = plan_import(
            args.svg,
            args.name,
            source_root,
            map_path,
            entries,
            installed_max,
        )
        new_entry = entries[-1]
    elif not map_path.exists():
        die(f"missing icon map: {map_path}")

    build_root: Path | None = None
    succeeded = False
    try:
        build_root, built_ttf = build_font(source_root, entries, pending_import, nanoemoji)
        verify_font(built_ttf, entries, fc_query)
        persist_import(source_root, map_path, entries, pending_import)
        shutil.copy2(built_ttf, output_ttf)
        subprocess.run([str(fc_cache), "-f", str(output_ttf.parent)], check=True)
        verify_font(output_ttf, entries, fc_query)
        succeeded = True
    except BaseException:
        if build_root is not None:
            print(f"build directory preserved at {build_root}", file=sys.stderr)
        raise
    finally:
        if (
            succeeded
            and build_root is not None
            and build_root.exists()
            and not args.keep_build_dir
        ):
            shutil.rmtree(build_root)

    if new_entry is not None:
        print(f"added {new_entry[0]} at U+{new_entry[1]:X}")
    else:
        print(f"rebuilt {output_ttf.name} from {len(entries)} SVGs")
    print(f"installed font: {output_ttf}")
    if build_root is not None and args.keep_build_dir:
        print(f"kept build directory: {build_root}")


if __name__ == "__main__":
    main()
