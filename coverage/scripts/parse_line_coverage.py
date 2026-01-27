#!/usr/bin/env python3
import re
import sys
from pathlib import Path

if len(sys.argv) != 2:
    print("usage: parse_line_coverage.py <html_path>", file=sys.stderr)
    sys.exit(2)

path = Path(sys.argv[1])
try:
    text = path.read_text(encoding="utf-8", errors="ignore")
except FileNotFoundError:
    sys.exit(1)

m = re.search(r'([0-9]+(?:\.[0-9]+)?)%\s*\((\d+)/(\d+)\s+lines\)', text)
if not m:
    sys.exit(2)

print(f"{m.group(1)} {m.group(2)} {m.group(3)}")
