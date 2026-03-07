# ast_diff_lua.py
# AST diff engine for Lua files.
# Uses tree-sitter for parsing.

from tree_sitter import Language, Parser
import tree_sitter_lua as tslua
from dataclasses import dataclass


@dataclass
class SemanticEvent:
    """Represents a single semantic change between two versions of a file."""
    type: str
    name: str
    description: str
    line: int = 0


def get_parser():
    """Initialize and return a Lua tree-sitter parser."""
    language = Language(tslua.language())
    parser = Parser(language)
    return parser


def extract_functions(source: str) -> dict:
    """
    Parse a Lua source string and extract all function definitions.
    Returns a dict like: { "function_name": {"node": ..., "line": ...} }
    """
    parser = get_parser()
    tree = parser.parse(bytes(source, "utf-8"))
    functions = {}

    def visit(node):
        # Regular function: function foo() end
        if node.type == "function_declaration":
            name_node = node.child_by_field_name("name")
            if name_node:
                functions[name_node.text.decode()] = {
                    "node": node,
                    "line": node.start_point[0] + 1,
                }

        # Method: function M.foo() end
        if node.type == "function_declaration":
            name_node = node.child_by_field_name("name")
            if name_node and "." in name_node.text.decode():
                functions[name_node.text.decode()] = {
                    "node": node,
                    "line": node.start_point[0] + 1,
                }

        # Local function: local function foo() end
        if node.type == "local_function":
            name_node = node.child_by_field_name("name")
            if name_node:
                functions[name_node.text.decode()] = {
                    "node": node,
                    "line": node.start_point[0] + 1,
                }

        for child in node.children:
            visit(child)

    visit(tree.root_node)
    return functions


def diff_functions(old_functions: dict, new_functions: dict) -> list:
    """
    Compare two dicts of functions and return a list of SemanticEvents.
    """
    events = []

    for name in new_functions:
        if name not in old_functions:
            events.append(SemanticEvent(
                type="ADDED",
                name=name,
                description="new function added",
                line=new_functions[name]["line"],
            ))

    for name in old_functions:
        if name not in new_functions:
            events.append(SemanticEvent(
                type="REMOVED",
                name=name,
                description="function was removed",
                line=0,
            ))

    for name in new_functions:
        if name in old_functions:
            old_code = old_functions[name]["node"].text.decode()
            new_code = new_functions[name]["node"].text.decode()
            if old_code != new_code:
                events.append(SemanticEvent(
                    type="MODIFIED",
                    name=name,
                    description="implementation changed",
                    line=new_functions[name]["line"],
                ))

    return events


def diff(old_source: str, new_source: str) -> list:
    """
    Main entry point for the Lua diff engine.
    Returns a list of dicts ready to be serialized as JSON.
    """
    old_functions = extract_functions(old_source)
    new_functions = extract_functions(new_source)
    events = diff_functions(old_functions, new_functions)

    return [
        {
            "type": e.type,
            "name": e.name,
            "description": e.description,
            "line": e.line,
        }
        for e in events
    ]
