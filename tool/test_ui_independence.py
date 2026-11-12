import unittest
from pathlib import Path
from tempfile import TemporaryDirectory

from check_ui_independence import (
    package_source_errors,
    runtime_dependency_errors,
    source_errors,
)


def package(name, dependencies=(), dev_dependencies=()):
    return {
        "name": name,
        "dependencies": list(dependencies),
        "devDependencies": list(dev_dependencies),
    }


class DependencyBoundaryTest(unittest.TestCase):
    def test_checks_transitive_runtime_dependencies_but_ignores_dev_tools(self):
        graph = {
            "roots": ["genux"],
            "packages": [
                package("genux", ["flutter", "widget_helpers"], ["flutter_test"]),
                package("flutter", ["material_color_utilities"]),
                package("material_color_utilities"),
                package("flutter_test", ["material_ui"]),
                package("widget_helpers", ["cupertino_ui"]),
                package("cupertino_ui"),
                package("material_ui"),
            ],
        }
        self.assertEqual(
            runtime_dependency_errors(graph),
            ["Forbidden runtime dependency: cupertino_ui"],
        )
        graph["packages"][4]["dependencies"] = []
        self.assertEqual(runtime_dependency_errors(graph), [])

    def test_missing_runtime_package_and_bad_root_fail_closed(self):
        self.assertTrue(runtime_dependency_errors({"roots": [], "packages": []}))
        self.assertTrue(
            runtime_dependency_errors(
                {"roots": ["genux"], "packages": [package("genux", ["missing"])]}
            )
        )

    def test_scans_runtime_package_sources_except_flutter_sdk(self):
        with TemporaryDirectory() as directory:
            root = Path(directory)
            config_file = root / ".dart_tool" / "package_config.json"
            config_file.parent.mkdir()
            for name in ("genux", "flutter", "helper"):
                (root / name / "lib").mkdir(parents=True)
            (root / "flutter/lib/sdk.dart").write_text(
                "import 'package:flutter/material.dart';", encoding="utf-8"
            )
            (root / "helper/lib/helper.dart").write_text(
                "import 'package:flutter/material.dart';", encoding="utf-8"
            )
            graph = {
                "roots": ["genux"],
                "packages": [
                    package("genux", ["flutter", "helper"]),
                    package("flutter"),
                    package("helper"),
                ],
            }
            config = {
                "packages": [
                    {"name": name, "rootUri": f"../{name}/", "packageUri": "lib/"}
                    for name in ("genux", "flutter", "helper")
                ]
            }
            errors = package_source_errors(graph, config, config_file)
            self.assertEqual(len(errors), 1)
            self.assertIn("helper.dart", errors[0])
            (root / "helper/lib/helper.dart").write_text(
                "import 'package:flutter/widgets.dart';", encoding="utf-8"
            )
            self.assertEqual(package_source_errors(graph, config, config_file), [])
            config["packages"][2].pop("packageUri")
            (root / "helper/unsafe.dart").write_text(
                "import 'package:flutter/material.dart';", encoding="utf-8"
            )
            self.assertTrue(package_source_errors(graph, config, config_file))
            config["packages"].pop()
            self.assertTrue(package_source_errors(graph, config, config_file))


class SourceBoundaryTest(unittest.TestCase):
    def check_source(self, source):
        with TemporaryDirectory() as directory:
            lib = Path(directory) / "lib"
            lib.mkdir()
            (lib / "example.dart").write_text(source, encoding="utf-8")
            return source_errors(lib)

    def test_all_forbidden_imports_and_conditional_exports_fail(self):
        for uri in (
            "package:fluent_ui/fluent_ui.dart",
            "package:material_ui/material_ui.dart",
            "package:cupertino_ui/cupertino_ui.dart",
            "package:flutter/material.dart",
            "package:flutter/cupertino.dart",
            "package:flutter/src/material/button.dart",
            "package:flutter/src/cupertino/button.dart",
            "package:flutter/./material.dart",
            "package:flutter/src/../material.dart",
            "package:flutter/%6daterial.dart",
            "package:flutter//material.dart",
            "package:flutter/../../material.dart",
        ):
            with self.subTest(uri=uri):
                self.assertTrue(self.check_source(f"import '{uri}';"))
                self.assertTrue(
                    self.check_source(
                        f"export 'safe.dart' if (dart.library.io) '{uri}';"
                    )
                )

    def test_comments_and_non_directive_strings_are_ignored(self):
        self.assertEqual(
            self.check_source(
                '''// import 'package:flutter/material.dart';
/* outer /* export 'package:fluent_ui/fluent_ui.dart'; */ end */
import 'package:flutter/widgets.dart';
const message = "package:cupertino_ui/cupertino_ui.dart";
final part = 'package:flutter/material.dart';
'''
            ),
            [],
        )

    def test_relative_directives_cannot_escape_lib(self):
        self.assertTrue(self.check_source("export '../outside.dart';"))
        self.assertEqual(self.check_source("export 'src/widget.dart';"), [])
        self.assertTrue(self.check_source("export 'file:///tmp/other.dart';"))
        self.assertTrue(self.check_source("import 'https://example.com/widget.dart';"))

    def test_escaped_or_malformed_directives_fail_closed(self):
        self.assertTrue(self.check_source(r"import 'package:flutter/\u006dat erial.dart';"))
        self.assertTrue(self.check_source("import 'unterminated"))

    def test_symlinked_library_entries_fail_closed(self):
        with TemporaryDirectory() as directory:
            root = Path(directory)
            lib = root / "lib"
            hidden = root / "hidden"
            lib.mkdir()
            hidden.mkdir()
            (hidden / "material.dart").write_text(
                "import 'package:flutter/material.dart';", encoding="utf-8"
            )
            (lib / "link").symlink_to(hidden, target_is_directory=True)
            self.assertTrue(source_errors(lib))


if __name__ == "__main__":
    unittest.main()
