# DASH License Checker Bazel Integration

This directory provides Bazel build configurations and custom rules to integrate the DASH license checker into projects. The setup includes a macro to define a java_binary target for license validation and a custom rule for converting requirement files into the appropriate DASH format.

## Directory Structure

```bash
├── BUILD
├── dash.bzl
├── tool/formatters
│   ├── BUILD
│   ├── dash_format_converter.bzl
│   └── dash_format_converter.py
└── README.md
```

### File Descriptions

**BUILD**

- This file is empty and serves only to mark this directory as a Bazel package.

**dash.bzl**

- Contains the dash_license_checker macro, which defines a `java_binary` target to run the DASH license checker.
- Loads `dash_format_converter.bzl` from the `formatters` package to preprocess requirement files.
- Converts the input `requirements_lock.txt` file into a format compatible with the DASH license tool before invoking the Java-based checker.
- Converts also Cargo.lock inputs intp a format compatible with the DASH license tool

**tool/formatters/BUILD**

- Empty file indicating that formatters is a Bazel package.

**tool/formatters/dash_format_converter.bzl**

- Defines a custom Bazel rule `dash_format_converter`.
- Calls `dash_format_converter.py` to transform `requirements_lock.txt`  or `Cargo.lock` into a format that the DASH tool can process.

**tool/formatters/dash_format_converter.py**

- Implements the logic to convert the input into a format accepted by the DASH license checker.
- This script is executed as part of the `dash_format_converter` Bazel rule.

## Usage

To integrate the DASH license checker into your Bazel project, define a target in your `BUILD` file as follows:

```bash
load("@dash_license_checker//:dash.bzl", "dash_license_checker")

dash_license_checker(
    name = "my_project_license_check",
    src = "//path/to/requirements_lock.txt",
    visibility = ["//visibility:public"],
)
```

This will:

1. Use dash_format_converter to process requirements_lock.txt.
2. Create a java_binary target that executes the DASH license checker with the converted file.
3. Ensure compliance with dependency licensing requirements in your project.



Example to check `RUST` based dependecies:

```bash
# Needed for Dash tool to check rust dependency licenses.
filegroup(
    name = "cargo_lock",
    srcs = [
        "_tooling/Cargo.lock",
    ],
    visibility = ["//visibility:public"],
)

dash_license_checker(
    name = "rust",
    src = "//docs:cargo_lock",
    visibility = ["//visibility:public"],
    file_type = "cargo"
)

```

