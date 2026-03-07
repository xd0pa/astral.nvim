# tests/python/test_ast_diff_python.py
# Unit tests for the Python AST diff engine.

import os
import sys

# Add the python folder to the path so we can import our modules
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "../../python"))

from ast_diff_python import diff, extract_functions

# ── extract_functions ────────────────────────────────────────────────


def test_extract_single_function():
    source = """
def saludar(nombre):
    print(nombre)
"""
    functions = extract_functions(source)
    assert "saludar" in functions


def test_extract_multiple_functions():
    source = """
def foo():
    pass

def bar():
    pass
"""
    functions = extract_functions(source)
    assert "foo" in functions
    assert "bar" in functions


def test_extract_empty_file():
    functions = extract_functions("")
    assert functions == {}


def test_extract_invalid_syntax():
    functions = extract_functions("def (((invalid")
    assert functions == {}


# ── diff ─────────────────────────────────────────────────────────────


def test_diff_added_function():
    old = """
def foo():
    pass
"""
    new = """
def foo():
    pass

def bar():
    pass
"""
    events = diff(old, new)
    assert any(e["type"] == "ADDED" and e["name"] == "bar" for e in events)


def test_diff_removed_function():
    old = """
def foo():
    pass

def bar():
    pass
"""
    new = """
def foo():
    pass
"""
    events = diff(old, new)
    assert any(e["type"] == "REMOVED" and e["name"] == "bar" for e in events)


def test_diff_modified_function():
    old = """
def foo():
    pass
"""
    new = """
def foo():
    print("changed")
"""
    events = diff(old, new)
    assert any(e["type"] == "MODIFIED" and e["name"] == "foo" for e in events)


def test_diff_no_changes():
    source = """
def foo():
    pass
"""
    events = diff(source, source)
    assert events == []


def test_diff_signature_change():
    old = """
def foo(a):
    pass
"""
    new = """
def foo(a, b):
    pass
"""
    events = diff(old, new)
    assert any(
        e["type"] == "MODIFIED" and "signature" in e["description"] for e in events
    )


def test_diff_returns_list():
    """diff() should always return a list, never None"""
    events = diff("", "")
    assert isinstance(events, list)


def test_diff_event_has_required_fields():
    """Every event must have type, name, description and line"""
    old = "def foo():\n    pass"
    new = "def foo():\n    return 1"
    events = diff(old, new)
    for event in events:
        assert "type" in event
        assert "name" in event
        assert "description" in event
        assert "line" in event


def test_diff_line_number_is_positive():
    """Line numbers should always be positive for existing functions"""
    old = "def foo():\n    pass"
    new = "def foo():\n    return 1\ndef bar():\n    pass"
    events = diff(old, new)
    for event in events:
        if event["type"] != "REMOVED":
            assert event["line"] > 0


def test_diff_type_values():
    """Event types should only be ADDED, REMOVED or MODIFIED"""
    old = "def foo():\n    pass\ndef bar():\n    pass"
    new = "def foo():\n    return 1\ndef baz():\n    pass"
    events = diff(old, new)
    valid_types = {"ADDED", "REMOVED", "MODIFIED"}
    for event in events:
        assert event["type"] in valid_types
