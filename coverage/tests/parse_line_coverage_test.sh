#!/usr/bin/env bash
set -euo pipefail

fixture="${TEST_SRCDIR}/${TEST_WORKSPACE}/coverage/tests/fixtures/blanket_index.html"
parser="${TEST_SRCDIR}/${TEST_WORKSPACE}/coverage/scripts/parse_line_coverage.py"

output="$(python3 "${parser}" "${fixture}")"

if [[ "${output}" != "100.00 8 8" ]]; then
  echo "unexpected coverage summary: ${output}" >&2
  exit 1
fi

echo "ok"
