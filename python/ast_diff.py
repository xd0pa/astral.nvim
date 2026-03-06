# ast_diff.py
# Core AST diffing logic.
# Receives two versions of a file and returns a list of semantic events.

import libcst as cst
from dataclasses import dataclass
from typing import Optional

@dataclass
class SemanticEvent:
    """Represents a single semantic change between two versions of a file."""
    type: str           # ADDED, REMOVED, MODIFIED
    name: str           # name of the funciton/class that changed
    description: str    # human readable description of what changed

def extract_functions(source: str) -> dict:
    """
    Parse a Python source string and extract all function definitions.
    Returns a dict like: { "function_name": FunctionDef_node }
    """
    try:
        tree = cst.parse_module(source)
    except cst.ParserSyntaxError:
        return {}

    functions = {}

    for node in tree.body:
        if isinstance(node, cst.SimpleStatementLine):
            continue
        if isinstance(node, cst.FunctionDef):
            name = node.name.value
            functions[name] = node

    return functions

def diff_functions(old_functions: dict, new_functions: dict) -> list:
    """
    Compare two dicts of functions and return a list of SemanticEvents.
    """
    events = []

    # Find added functions (exist in new but not in old)
    for name in new_functions:
        if name not in old_functions:
            events.append(SemanticEvent(
                type="ADDED",
                name=name,
                description=f"new function added"
            ))

    # Find removed functions (exist in old but not in new)
    for name in old_functions:
        if name not in new_functions:
            events.append(SemanticEvent(
                type="REMOVED",
                name=name,
                description=f"function was removed"
            ))

    # Find modified functions (exist in both but are different)
    for name in new_functions:
        if name in old_functions:
            old_code = cst.parse_module("").code_for_node(old_functions[name])
            new_code = cst.parse_module("").code_for_node(new_functions[name])
            if old_code != new_code:
                events.append(SemanticEvent(
                    type="MODIFIED",
                    name=name,
                    description=detect_change(old_functions[name], new_functions[name])
                    ))

    return events

def detect_change(old_func: cst.FunctionDef, new_func: cst.FunctionDef) -> str:
    """
    Given two versions of the same function, describe what changed.
    """
    # Check if the signature changed (parameters)
    old_params = [p.name.value for p in old_func.params.params]
    new_params = [p.name.value for p in new_func.params.params]

    if old_params != new_params:
        return f"signature changed: {old_params} -> {new_params}"

    # Check if the number of lines changed significantly
    old_lines = len(old_func.body.body)
    new_lines = len(new_func.body.body)

    if old_lines != new_lines:
        return f"body changed: {old_lines} -> {new_lines} statements"

    # Generic fallback
    return "implementation changed"

def diff(old_source: str, new_source: str) -> list:
    """
    Main entry point for the diff engine.
    Returns a list of dicts ready to be serialized as JSON.
    """
    old_functions = extract_functions(old_source)
    new_functions = extract_functions(new_source)

    events = diff_functions(old_functions, new_functions)

    # Convert dataclasses to dicts for JSON serialization
    return [{"type": e.type, "name": e.name, "description": e.description} for e in events]
