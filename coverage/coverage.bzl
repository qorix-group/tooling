# *******************************************************************************
# Copyright (c) 2025 Contributors to the Eclipse Foundation
#
# See the NOTICE file(s) distributed with this work for additional
# information regarding copyright ownership.
#
# This program and the accompanying materials are made available under the
# terms of the Apache License Version 2.0 which is available at
# https://www.apache.org/licenses/LICENSE-2.0
#
# SPDX-License-Identifier: Apache-2.0
# *******************************************************************************

"""Bazel helpers for Ferrocene Rust coverage workflows."""

def _shell_quote(value):
    if value == "":
        return "''"
    return "'" + value.replace("'", "'\"'\"'") + "'"

def _rust_coverage_report_impl(ctx):
    script = ctx.actions.declare_file(ctx.label.name + ".sh")

    args = []
    for cfg in ctx.attr.bazel_configs:
        if cfg:
            args.extend(["--bazel-config", cfg])
    if ctx.attr.query:
        args.extend(["--query", ctx.attr.query])
    if ctx.attr.min_line_coverage:
        args.extend(["--min-line-coverage", ctx.attr.min_line_coverage])

    args_parts = [_shell_quote(a) for a in args]
    # The wrapper script forwards preconfigured args and any extra CLI args.
    exec_line = "exec \"${ferrocene_report}\""
    if args_parts:
        exec_line += " \\\n  " + " \\\n  ".join(args_parts)
    exec_line += " \\\n  \"$@\""

    # Resolve the report script via runfiles for remote/CI compatibility.
    runfile_path = ctx.executable._ferrocene_report.short_path
    script_content = """#!/usr/bin/env bash
set -euo pipefail

report_runfile={runfile}
if [[ -n "${{RUNFILES_DIR:-}}" ]]; then
  ferrocene_report="${{RUNFILES_DIR}}/${{report_runfile}}"
elif [[ -n "${{RUNFILES_MANIFEST_FILE:-}}" ]]; then
  ferrocene_report="$(grep -m1 "^${{report_runfile}} " "${{RUNFILES_MANIFEST_FILE}}" | cut -d' ' -f2-)"
else
  ferrocene_report="${{report_runfile}}"
fi

if [[ ! -x "${{ferrocene_report}}" ]]; then
  echo "ferrocene_report not found at ${{ferrocene_report}}" >&2
  exit 1
fi

{exec_line}
""".format(runfile = _shell_quote(runfile_path), exec_line = exec_line)

    ctx.actions.write(script, script_content, is_executable = True)

    runfiles = ctx.runfiles(files = [ctx.executable._ferrocene_report])
    return [DefaultInfo(executable = script, runfiles = runfiles)]

rust_coverage_report = rule(
    implementation = _rust_coverage_report_impl,
    executable = True,
    attrs = {
        "bazel_configs": attr.string_list(
            default = ["ferrocene-coverage"],
            doc = "Bazel configs passed to ferrocene_report.",
        ),
        "query": attr.string(
            default = 'kind("rust_test", //...)',
            doc = "Bazel query used to discover rust_test targets.",
        ),
        "min_line_coverage": attr.string(
            default = "",
            doc = "Optional minimum line coverage percentage.",
        ),
        "_ferrocene_report": attr.label(
            default = Label("//coverage:ferrocene_report"),
            executable = True,
            cfg = "exec",
        ),
    },
    doc = "Creates a repo-local wrapper for Ferrocene Rust coverage reports.",
)
