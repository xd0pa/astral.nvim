# tests/python/test_ast_diff_lua.py
# Unit tests for the Lua AST diff engine.

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "../../python"))

from ast_diff_lua import diff, extract_functions


def test_extract_function_declaration():
    source = """
function saludar(nombre)
    print(nombre)
end
"""
    functions = extract_functions(source)
    assert "saludar" in functions


def test_extract_local_function():
    source = """
local function foo()
    return 1
end
"""
    functions = extract_functions(source)
    assert "foo" in functions


def test_extract_empty_file():
    functions = extract_functions("")
    assert functions == {}


def test_diff_added_function():
    old = "function foo()\n  return 1\nend"
    new = "function foo()\n  return 1\nend\nfunction bar()\n  return 2\nend"
    events = diff(old, new)
    assert any(e["type"] == "ADDED" and e["name"] == "bar" for e in events)


def test_diff_removed_function():
    old = "function foo()\n  return 1\nend\nfunction bar()\n  return 2\nend"
    new = "function foo()\n  return 1\nend"
    events = diff(old, new)
    assert any(e["type"] == "REMOVED" and e["name"] == "bar" for e in events)


def test_diff_no_changes():
    source = "function foo()\n  return 1\nend"
    events = diff(source, source)
    assert events == []
