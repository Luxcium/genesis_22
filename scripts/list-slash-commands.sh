#!/usr/bin/env bash
# =============================================================================
# SLASH COMMANDS LISTER
# =============================================================================
#
# Purpose:
#   Lists all available slash commands defined in prompt files. This helps
#   discover what custom prompts are available for use in GitHub Copilot.
#
# Usage:
#   ./scripts/list-slash-commands.sh
#
# Exit Codes:
#   0 - Successfully listed slash commands
#   1 - No prompt files found or error occurred
#
# Output Format:
#   filename:line_number:## Slash Command: /command-name
#
# Example Output:
#   memory-bank/prompts/example.prompt.md:12:## Slash Command: /example
#   memory-bank/prompts/another.prompt.md:8:## Slash Command: /another
#
# AI Agent Instructions:
#   Run this script to discover available custom prompts. The output shows
#   the filename, line number, and slash command name for each prompt. Use
#   this information to learn what prompts are available for use.
#
# Human User Instructions:
#   Run this script to see all available slash commands. Each line shows where
#   the command is defined and what its name is. You can then use these
#   commands in GitHub Copilot chat by typing the slash command.
#
# =============================================================================

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

# Enable extended globbing for pattern matching
shopt -s nullglob

# Array of all prompt files
files=(memory-bank/prompts/*.prompt.md)

# =============================================================================
# VALIDATION AND EXECUTION
# =============================================================================

# Check if any prompt files exist
if (( ${#files[@]} == 0 )); then
  echo "No prompt files found." >&2
  exit 1
fi

# Use grep to find and display all Slash Command sections
# -H: print filename
# -n: print line number
# Pattern: lines starting with "## Slash Command:"
grep -Hn '^## Slash Command:' "${files[@]}"
