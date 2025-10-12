#!/usr/bin/env bash
# =============================================================================
# PROMPT FILES VALIDATOR
# =============================================================================
#
# Purpose:
#   Validates that all prompt files in memory-bank/prompts/ follow the required
#   format and structure. Uses Python for precise front-matter and structure
#   validation.
#
# Usage:
#   ./scripts/validate-prompts.sh
#
# Exit Codes:
#   0 - All validations passed
#   1 - One or more validation errors found
#
# Validation Rules:
#   1. Must start with front-matter (---)
#   2. Front-matter must include 'description:' field
#   3. Only allowed keys: description, mode, model, tools
#   4. Must have blank line after front-matter
#   5. Must have path marker comment (<!-- memory-bank/prompts/filename.md -->)
#   6. Must have blank line after path marker
#   7. Must have H1 title immediately after marker block
#   8. Must have at least one "## Slash Command:" section
#   9. No external links allowed (http://, https://)
#
# File Structure:
#   ---
#   description: Brief description
#   ---
#   
#   <!-- memory-bank/prompts/example.prompt.md -->
#   
#   # Prompt Title
#   
#   ## Slash Command: /example
#   
#   [prompt content]
#
# AI Agent Instructions:
#   Run this validator before committing changes to memory-bank/prompts/.
#   Prompt files must follow the exact structure to be properly recognized
#   by GitHub Copilot. The Slash Command section is required for the prompt
#   to be usable via keyboard shortcuts.
#
# Human User Instructions:
#   If this validator fails, check the error messages for specific structural
#   issues. Ensure your prompt file has proper front-matter, path marker, and
#   at least one Slash Command section.
#
# =============================================================================

set -euo pipefail

# =============================================================================
# PYTHON VALIDATION SCRIPT
# =============================================================================

# Use Python for precise parsing and validation
# Python provides better front-matter and structure validation than shell
python3 <<'PY'
"""
Prompt File Validator

This script validates the structure and format of prompt files in the
memory-bank/prompts/ directory. It ensures all files follow the required
format for GitHub Copilot integration.

Validation rules:
1. Front-matter must be present and properly formatted
2. Required fields must be present
3. Path marker comment must match filename
4. Structure must follow exact layout requirements
5. No external links allowed
"""
import pathlib
import sys

# Track validation errors
errors = []

# Allowed front-matter keys
allowed_keys = {"description", "mode", "model", "tools"}

# Iterate through all prompt files
for path in sorted(pathlib.Path("memory-bank/prompts").glob("*.prompt.md")):
    text = path.read_text(encoding="utf-8").splitlines()
    
    # Validation: Check for front-matter start marker
    if not text or text[0].strip() != "---":
        errors.append(f"{path}: missing front-matter start")
        continue
    
    # Validation: Check for front-matter end marker
    try:
        end = text.index('---', 1)
    except ValueError:
        errors.append(f"{path}: missing front-matter end")
        continue

    # Extract and validate front-matter
    frontmatter = text[1:end]
    
    # Validation: Check for required description field
    if not any(line.startswith("description:") for line in frontmatter):
        errors.append(f"{path}: front-matter missing description")

    # Validation: Check for disallowed front-matter keys
    for line in frontmatter:
        if not line.strip():
            continue
        if ':' not in line:
            continue
        key = line.split(':', 1)[0].strip()
        if key not in allowed_keys:
            errors.append(f"{path}: disallowed front-matter key '{key}'")

    # Validation: Check for blank line after front-matter
    if len(text) <= end + 1 or text[end + 1].strip() != "":
        errors.append(f"{path}: expected blank line after front-matter")
        continue

    # Validation: Check for path marker comment
    expected_marker = f"<!-- memory-bank/prompts/{path.name} -->"
    if len(text) <= end + 2 or text[end + 2].strip() != expected_marker:
        errors.append(f"{path}: missing or incorrect path marker comment")
        continue

    # Validation: Check for blank line after path marker
    if len(text) <= end + 3 or text[end + 3].strip() != "":
        errors.append(f"{path}: expected blank line after path marker")
        continue

    # Validation: Check for H1 title
    body = text[end + 4 :]
    if not body or not body[0].startswith("# "):
        errors.append(f"{path}: expected H1 title immediately after marker block")
        continue

    # Validation: Check for Slash Command section
    first_h2_index = None
    for idx, line in enumerate(body):
        if line.startswith("## "):
            first_h2_index = idx
            break

    if first_h2_index is None:
        errors.append(f"{path}: missing Slash Command section")
        continue

    # Validation: Check that first H2 is a Slash Command
    if not body[first_h2_index].startswith("## Slash Command: "):
        errors.append(f"{path}: first H2 must be a Slash Command section")

    # Validation: Check for external links
    if any("http://" in line or "https://" in line for line in text):
        errors.append(f"{path}: external links are not allowed")

# =============================================================================
# REPORT RESULTS
# =============================================================================

# If errors were found, report them and exit with error code
if errors:
    print("[FAIL] Prompt validation failed:")
    for err in errors:
        print(f"  - {err}")
    sys.exit(1)

# All validations passed
print("[OK] Prompt validation passed.")
PY
