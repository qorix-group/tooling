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

load("@rules_shell//shell:sh_test.bzl", "sh_test")

package(default_visibility = ["//visibility:public"])

sh_test(
    name = "parse_line_coverage_test",
    srcs = ["parse_line_coverage_test.sh"],
    data = [
        "fixtures/blanket_index.html",
        "//coverage:scripts/parse_line_coverage.py",
    ],
)

sh_test(
    name = "ferrocene_report_help_test",
    srcs = ["ferrocene_report_help_test.sh"],
    data = [
        "//coverage:ferrocene_report",
    ],
)

sh_test(
    name = "normalize_symbol_report_test",
    srcs = ["normalize_symbol_report_test.sh"],
    data = [
        "fixtures/symbol_report.json",
        "//coverage:scripts/normalize_symbol_report.py",
    ],
)
