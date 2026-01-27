#!/usr/bin/env bash
set -euo pipefail

script="${TEST_SRCDIR}/${TEST_WORKSPACE}/coverage/ferrocene_report.sh"

output="$(bash "${script}" --help)"

if ! echo "${output}" | grep -q "Generate Ferrocene Rust coverage reports"; then
  echo "help output did not contain expected header" >&2
  exit 1
fi

if ! echo "${output}" | grep -q -- "--min-line-coverage"; then
  echo "help output missing --min-line-coverage" >&2
  exit 1
fi

echo "ok"
