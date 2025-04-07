load("@aspect_rules_lint//format:defs.bzl", "format_multirun", "format_test")

def use_format_targets(fix_name = "format.fix", check_name = "format.check"):
    format_multirun(
        name = fix_name,
        python = "@aspect_rules_lint//format:ruff",
        starlark = "@buildifier_prebuilt//:buildifier",
        yaml = "@aspect_rules_lint//format:yamlfmt",
        visibility = ["//visibility:public"],
    )

    format_test(
        name = check_name,
        no_sandbox = True,
        python = "@aspect_rules_lint//format:ruff",
        starlark = "@buildifier_prebuilt//:buildifier",
        yaml = "@aspect_rules_lint//format:yamlfmt",
        workspace = "//:MODULE.bazel",
        visibility = ["//visibility:public"],
    )
