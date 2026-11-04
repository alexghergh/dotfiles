"""Inline Graphviz SVGs into an HTML report.

Usage: assemble.py <report.src.html> <report.html>

Each `<!-- svg: NAME -->` marker is replaced by the contents of `NAME.svg`
from the source file's directory; a missing SVG stops the script.
"""

import re
import sys
from pathlib import Path

src, out = Path(sys.argv[1]), Path(sys.argv[2])


def inline(match):
    return (src.parent / f"{match.group(1)}.svg").read_text()


out.write_text(re.sub(r"<!-- svg: ([\w-]+) -->", inline, src.read_text()))
