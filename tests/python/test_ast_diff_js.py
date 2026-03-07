# tests/python/test_ast_diff_js.py
# Unit tests for the JavaScript AST diff engine.

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "../../python"))

from ast_diff_js import diff, extract_functions


def test_extract_function_declaration():
    source = """
function saludar(nombre) {
    console.log(nombre)
}
"""
    functions = extract_functions(source)
    assert "saludar" in functions


def test_extract_arrow_function():
    source = """
const despedir = (nombre) => {
    console.log(nombre)
}
"""
    functions = extract_functions(source)
    assert "despedir" in functions


def test_extract_empty_file():
    functions = extract_functions("")
    assert functions == {}


def test_diff_added_function():
    old = "function foo() { return 1 }"
    new = "function foo() { return 1 }\nfunction bar() { return 2 }"
    events = diff(old, new)
    assert any(e["type"] == "ADDED" and e["name"] == "bar" for e in events)


def test_diff_removed_function():
    old = "function foo() { return 1 }\nfunction bar() { return 2 }"
    new = "function foo() { return 1 }"
    events = diff(old, new)
    assert any(e["type"] == "REMOVED" and e["name"] == "bar" for e in events)


def test_diff_no_changes():
    source = "function foo() { return 1 }"
    events = diff(source, source)
    assert events == []
