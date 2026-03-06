#!/usr/bin/env python3
# astral_engine.py
# Entry point for the astral diff engine.
# Called by the Lua bridge as an external process.

import argparse
import json
import subprocess
import sys

from ast_diff import diff

def get_file_at_ref(filepath, ref):
    """Get the content of a file at a specific git ref."""
    import os

    # Expand ~ to absolute path
    filepath = os.path.expanduser(filepath)

    # Get the git root directory
    git_root = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        capture_output=True,
        text=True,
        cwd=os.path.dirname(filepath)
    )
    if git_root.returncode != 0:
        return None

    # Make the path relative to the git root
    relative_path = os.path.relpath(filepath, git_root.stdout.strip())

    result = subprocess.run(
        ["git", "show", f"{ref}:{relative_path}"],
        capture_output=True,
        text=True,
        cwd=git_root.stdout.strip()
    )
    if result.returncode != 0:
        return None
    return result.stdout

def main() -> None:
    parser = argparse.ArgumentParser(description="astral semantic diff engine")
    parser.add_argument("--file", required=True, help="path to the file to diff")
    parser.add_argument("--ref", required=True, help="git ref to diff against")
    args = parser.parse_args()

    # Read current version of the file
    try:
        with open(args.file, "r") as f:
            current_source = f.read()
    except FileNotFoundError:
        print(json.dumps({"error": f"file not found: {args.file}"}))
        sys.exit(1)

    # Read the old version from git
    old_source = get_file_at_ref(args.file, args.ref)
    if old_source is None:
        print(json.dumps({"error": f"could not get file at ref: {args.ref}"}))
        sys.exit(1)

    # Run the semantic diff
    try:
        result = diff(old_source, current_source)
        print(json.dumps(result))
    except Exception as e:
        import traceback
        print(json.dumps({"error": traceback.format_exc()}), file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
