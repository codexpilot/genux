#!/usr/bin/env python3
"""Check the shared presentation fixtures against the experimental JSON Schema."""

import json
from pathlib import Path

from jsonschema import Draft202012Validator


PACKAGE_ROOT = Path(__file__).resolve().parent.parent
SCHEMA_PATH = PACKAGE_ROOT / "schema/genux-presentation-v1.schema.json"
FIXTURE_PATH = PACKAGE_ROOT / "test/fixtures/presentation_contract_cases.json"
EXAMPLE_PATH = PACKAGE_ROOT / "examples/dashboard.json"


def read_json(path):
    return json.loads(path.read_text(encoding="utf-8"))


def main():
    schema = read_json(SCHEMA_PATH)
    Draft202012Validator.check_schema(schema)
    validator = Draft202012Validator(schema)
    cases = read_json(FIXTURE_PATH)
    if not isinstance(cases, list) or not cases:
        raise ValueError(f"{FIXTURE_PATH}: expected a nonempty array")

    expected_counts = {True: 0, False: 0}
    for index, case in enumerate(cases):
        if not isinstance(case, dict) or not isinstance(case.get("valid"), bool):
            raise ValueError(f"{FIXTURE_PATH}: case {index} lacks a boolean valid")
        if "document" not in case:
            raise ValueError(f"{FIXTURE_PATH}: case {index} lacks document")
        expected = case["valid"]
        expected_counts[expected] += 1
        errors = list(validator.iter_errors(case["document"]))
        if (not errors) != expected:
            detail = errors[0].message if errors else "document was accepted"
            raise AssertionError(
                f"{FIXTURE_PATH}: case {index}: expected valid={expected}; {detail}"
            )
    if not all(expected_counts.values()):
        raise ValueError(f"{FIXTURE_PATH}: expected both valid and invalid cases")

    validator.validate(read_json(EXAMPLE_PATH))
    print(f"Schema self-check, {len(cases)} fixture cases, and dashboard passed")


if __name__ == "__main__":
    main()
