#!/usr/bin/env bash
set -euo pipefail

fixture="${TEST_SRCDIR}/${TEST_WORKSPACE}/coverage/tests/fixtures/symbol_report.json"
script="${TEST_SRCDIR}/${TEST_WORKSPACE}/coverage/scripts/normalize_symbol_report.py"

workdir="$(mktemp -d)"
trap 'rm -rf "${workdir}"' EXIT

cp "${fixture}" "${workdir}/symbol_report.json"

python3 "${script}" "${workdir}/symbol_report.json" "/workspace" "/execroot"

python3 - "${workdir}/symbol_report.json" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as fh:
    data = json.load(fh)

files = sorted({s.get("filename") for s in data.get("symbols", [])})
expected = ["src/lib.rs", "src/rel.rs"]
if files != expected:
    raise SystemExit(f"unexpected filenames: {files}")

print("ok")
PY
