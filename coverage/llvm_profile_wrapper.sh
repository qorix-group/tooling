#!/usr/bin/env bash
set -euo pipefail

# Wrapper for Bazel tests: set LLVM_PROFILE_FILE to TEST_UNDECLARED_OUTPUTS_DIR
# so .profraw files are collected into test.outputs.

if [[ -n "${TEST_UNDECLARED_OUTPUTS_DIR:-}" ]]; then
  mkdir -p "${TEST_UNDECLARED_OUTPUTS_DIR}"
  export LLVM_PROFILE_FILE="${TEST_UNDECLARED_OUTPUTS_DIR}/%p.profraw"
fi

exec "$@"
