#!/usr/bin/env python3
"""Enforce Genux's source imports and resolved runtime dependency boundary."""

import json
from pathlib import Path
import posixpath
import sys
from urllib.parse import unquote, urljoin, urlparse
from urllib.request import url2pathname


PACKAGE_ROOT = Path(__file__).resolve().parent.parent
FORBIDDEN_PACKAGES = frozenset({"fluent_ui", "material_ui", "cupertino_ui"})
SDK_PACKAGES = frozenset({"flutter", "sky_engine"})


def runtime_dependencies(graph):
    """Inspect only the root's runtime closure; dev tools are not shipped."""
    if graph.get("roots") != ["genux"]:
        return set(), ["Expected a resolved dependency graph rooted at genux"]
    packages = {package["name"]: package for package in graph["packages"]}
    errors = []
    seen = set()
    pending = ["genux"]
    while pending:
        name = pending.pop()
        if name in seen:
            continue
        seen.add(name)
        if name in FORBIDDEN_PACKAGES:
            errors.append(f"Forbidden runtime dependency: {name}")
        package = packages.get(name)
        if package is None:
            errors.append(f"Runtime dependency missing from resolved graph: {name}")
        else:
            pending.extend(package.get("dependencies", []))
    return seen, sorted(errors)


def runtime_dependency_errors(graph):
    return runtime_dependencies(graph)[1]


def dart_tokens(source):
    """Yield Dart identifiers, string literals and punctuation, skipping comments.

    Directive URIs must be string literals. Keeping strings as tokens also
    avoids mistaking documentation or ordinary string contents for directives.
    """
    i = 0
    while i < len(source):
        c = source[i]
        if c.isspace():
            i += 1
        elif source.startswith("//", i):
            end = source.find("\n", i + 2)
            i = len(source) if end < 0 else end + 1
        elif source.startswith("/*", i):
            i += 2
            depth = 1
            while i < len(source) and depth:
                if source.startswith("/*", i):
                    depth += 1
                    i += 2
                elif source.startswith("*/", i):
                    depth -= 1
                    i += 2
                else:
                    i += 1
            if depth:
                raise ValueError("Unterminated block comment")
        elif c in "'\"" or (c == "r" and i + 1 < len(source) and source[i + 1] in "'\""):
            raw = c == "r"
            if raw:
                i += 1
            quote = source[i]
            delimiter = quote * (3 if source.startswith(quote * 3, i) else 1)
            i += len(delimiter)
            chars = []
            while i < len(source) and not source.startswith(delimiter, i):
                if not raw and source[i] == "\\" and i + 1 < len(source):
                    # Dart supports escaped characters in URIs. Decode the
                    # common forms and fail closed for others.
                    escaped = source[i + 1]
                    if escaped not in "\\'\"/":
                        chars.append("\\" + escaped)
                    else:
                        chars.append(escaped)
                    i += 2
                else:
                    chars.append(source[i])
                    i += 1
            if i >= len(source):
                raise ValueError("Unterminated string literal")
            i += len(delimiter)
            yield ("string", "".join(chars))
        elif c.isalpha() or c in "_$":
            start = i
            i += 1
            while i < len(source) and (source[i].isalnum() or source[i] in "_$"):
                i += 1
            yield ("identifier", source[start:i])
        else:
            i += 1
            yield ("symbol", c)


def directive_uris(source):
    tokens = list(dart_tokens(source))
    for index, (kind, value) in enumerate(tokens):
        if kind != "identifier" or value not in {"import", "export", "part"}:
            continue
        # `part` is also a valid contextual identifier, and `part of` does
        # not introduce a library to scan. Real URI directives begin with a
        # literal immediately after the directive keyword.
        if index + 1 >= len(tokens) or tokens[index + 1][0] != "string":
            continue
        for token_kind, token_value in tokens[index + 1:]:
            if token_kind == "symbol" and token_value == ";":
                break
            if token_kind == "string":
                yield token_value


def uri_error(uri, source_path, lib_root):
    uri = unquote(uri)
    if "\\" in uri:
        return f"Unsupported escaped directive URI: {uri}"
    if uri.startswith("package:"):
        package, _, path = uri[len("package:"):].partition("/")
        path = posixpath.normpath(path)
        if path.startswith("/") or path == ".." or path.startswith("../"):
            return f"Invalid package directive URI: {uri}"
        if package in FORBIDDEN_PACKAGES:
            return f"Forbidden package import/export: {uri}"
        if package == "flutter" and (
            path in {"material.dart", "cupertino.dart"}
            or path.startswith(("src/material/", "src/cupertino/"))
        ):
            return f"Forbidden Flutter UI import/export: {uri}"
    elif uri.startswith("dart:"):
        return None
    elif ":" in uri or uri.startswith("//"):
        return f"Unsupported directive URI scheme: {uri}"
    else:
        target = (source_path.parent / uri).resolve()
        if not target.is_relative_to(lib_root.resolve()):
            return f"Relative directive points outside package lib: {uri}"
    return None


def source_errors(lib_root):
    if lib_root.is_symlink() or not lib_root.is_dir():
        return [f"Library directory does not exist: {lib_root}"]
    errors = []
    for path in sorted(lib_root.rglob("*")):
        if path.is_symlink():
            errors.append(f"Symlink in library source tree: {path}")
            continue
        if not path.is_file() or path.suffix != ".dart":
            continue
        try:
            for uri in directive_uris(path.read_text(encoding="utf-8")):
                error = uri_error(uri, path, lib_root)
                if error:
                    errors.append(f"{path}: {error}")
        except ValueError as error:
            errors.append(f"{path}: {error}")
    return errors


def package_source_errors(graph, config, config_path):
    """Check every source file in runtime packages, excluding the SDK itself.

    Scanning all library files is deliberately conservative: a transitive
    package cannot later expose a forbidden UI import without failing CI. SDK
    packages are exempt because Flutter ships Material and Cupertino alongside
    the low-level widgets on which Genux relies.
    """
    names, errors = runtime_dependencies(graph)
    packages = {package["name"]: package for package in config["packages"]}
    for name in sorted(names - SDK_PACKAGES):
        if name not in packages:
            errors.append(f"Runtime package missing from package config: {name}")
            continue
        entry = packages[name]
        root_uri = urljoin(config_path.resolve().as_uri(), entry["rootUri"])
        # package_config's omitted packageUri means the package root itself.
        lib_uri = urljoin(root_uri.rstrip("/") + "/", entry.get("packageUri", ""))
        parsed = urlparse(lib_uri)
        if parsed.scheme != "file" or parsed.netloc not in {"", "localhost"}:
            errors.append(f"Unsupported package source URI for {name}: {lib_uri}")
            continue
        errors.extend(source_errors(Path(url2pathname(parsed.path))))
    return errors


def main():
    graph_path = PACKAGE_ROOT / ".dart_tool/package_graph.json"
    config_path = PACKAGE_ROOT / ".dart_tool/package_config.json"
    try:
        graph = json.loads(graph_path.read_text(encoding="utf-8"))
        config = json.loads(config_path.read_text(encoding="utf-8"))
        errors = package_source_errors(graph, config, config_path)
    except (OSError, KeyError, TypeError, ValueError) as error:
        print(f"Unable to check Genux independence: {error}", file=sys.stderr)
        return 1
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print("Genux source imports and runtime dependencies are independent of the prohibited UI libraries")
    return 0


if __name__ == "__main__":
    sys.exit(main())
