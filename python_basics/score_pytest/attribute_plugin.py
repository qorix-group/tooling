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
from __future__ import annotations

from collections.abc import Callable
from typing import Any
from typing import Literal

import pytest

# Type aliases for better readability
TestFunction = Callable[..., Any]
Decorator = Callable[[TestFunction], TestFunction]


def add_test_properties(
    *,
    partially_verifies: list[str] | None = None,
    fully_verifies: list[str] | None = None,
    test_type: Literal[
        "fault-injection", "interface-test", "requirements-based", "resource-usage"
    ],
    derivation_technique: Literal[
        "requirements-analysis",
        "design-analysis",
        "boundary-values",
        "equivalence-classes",
        "fuzz-testing",
        "error-guessing",
        "explorative-testing",
    ],
) -> Decorator:
    """
    Decorator to add user properties, file and lineNr to testcases in the XML output
    """
    # Early error handling
    if partially_verifies is None and fully_verifies is None:
        raise ValueError(
            "Either 'partially_verifies' or 'fully_verifies' must be provided."
        )

    #          ╭──────────────────────────────────────╮
    #          │  HINT. This is currently commented   │
    #          │ out to not restrict usage a lot but  │
    #          │   will be commented back in in the   │
    #          │                future                │
    #          ╰──────────────────────────────────────╯

    # if not test_type:
    #     raise ValueError("'test_type' is required and cannot be empty.")
    #
    # if not derivation_technique:
    #     raise ValueError("'derivation_technique' is required and cannot be empty.")
    #

    def decorator(func: Any) -> TestFunction:
        # Clean properties (skip None)
        properties = {
            "PartiallyVerifies": ", ".join(partially_verifies)
            if partially_verifies
            else "",
            "FullyVerifies": ", ".join(fully_verifies) if fully_verifies else "",
            "TestType": test_type,
            "DerivationTechnique": derivation_technique,
        }
        # Ensure a 'description' is there inside the Docstring
        doc = getattr(func, "__doc__", None)
        if not doc or not doc.strip():
            name = getattr(func, "__name__", "Object")
            raise ValueError(f"{name} does not have a description in docstrings.")

        cleaned_properties = {k: v for k, v in properties.items() if v}
        
        # This works for both classes and functions
        return pytest.mark.test_properties(cleaned_properties)(func)

    return decorator


def pytest_runtest_makereport(item: pytest.Item, call: pytest.CallInfo[None]) -> None:
    """Attach file and line info to the report for use in junitxml output."""
    if call.when != "call":
        return
    # Since our decorator 'add_test_properties' will create a 'test_properties' marker
    # This function then searches for the nearest dictionary attached to an item with
    # that marker and parses this into properties.

    # In short:
    #   => This function adds the properties specified via the decorator to the item so
    #      they can be written to the XML output in the end
    # Note: This does NOT add 'line' and 'file' to the testcase.

    marker = item.get_closest_marker("test_properties")
    if marker and isinstance(marker.args[0], dict):
        for k, v in marker.args[0].items():
            item.user_properties.append((k, str(v)))


@pytest.fixture(autouse=True)
def add_file_and_line_attr(
    record_xml_attribute: Callable[[str, str], None], request: pytest.FixtureRequest
) -> None:
    node = request.node
    # node.location returns (filename, lineno, display_name)
    raw_file_path, line_number, _ = node.location
    
    # If it's a class-based test and we want the specific method line
    if request.cls and request.function:
        import inspect
        try:
            # Get the actual source lines of the function/method
            _, func_line = inspect.getsourcelines(request.function)
            line_number = func_line
        except Exception:
            pass

    # Clean the file path
    clean_file_path = raw_file_path.split("_main/")[-1]
    
    record_xml_attribute("file", str(clean_file_path))
    # Using the raw line number is usually safer than +1 
    # as IDEs/tools map to the 'def' line anyway
    record_xml_attribute("line", str(line_number))
