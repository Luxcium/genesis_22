#!/usr/bin/env bash
# =============================================================================
# MEMORY-BANK INSTRUCTIONS VALIDATOR
# =============================================================================
#
# Purpose:
#   Validates that all instruction files in memory-bank/instructions/ follow
#   the required format and conventions. Ensures consistency and discoverability
#   by GitHub Copilot.
#
# Usage:
#   ./scripts/validate-memory-bank.sh
#
# Exit Codes:
#   0 - All validations passed
#   1 - One or more validation errors found
#
# Validation Rules:
#   1. All .instructions.md files must have a 'description:' front-matter header
#   2. External links (http://, https://, ftp://) are not allowed in most files
#   3. Exception: Layer files and specific allowed files can contain external links
#
# Allowed External Link Files:
#   - layer-* (all layer instruction files)
#   - conventional-commits-must-be-used.instructions.md
#   - gitmoji-complete-list.instructions.md
#
# AI Agent Instructions:
#   Run this validator before committing changes to memory-bank/instructions/.
#   All instruction files must be self-contained except for explicitly allowed
#   external references. This ensures offline usability and reduces dependency
#   on external resources.
#
# Human User Instructions:
#   If this validator fails, check the error messages for specific files and
#   issues. Add a 'description:' header if missing, or remove external links
#   unless the file is in the allowed list.
#
# =============================================================================

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

# Enable extended globbing for pattern matching
shopt -s nullglob

# Track validation errors
errors=()

# Files allowed to contain external links
# These are typically reference documents or layer specifications
allow_external=(
  'layer-*'                                      # All layer files
  conventional-commits-must-be-used.instructions.md
  gitmoji-complete-list.instructions.md
  markdown-linting-rules.instructions.md         # References external linting standards
)

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Check if a filename matches any of the allowed external link patterns
# Arguments:
#   $1 - filename to check
# Returns:
#   0 if file is allowed to have external links
#   1 if file is not allowed to have external links
allow_external_file() {
  local name=$1
  for pattern in "${allow_external[@]}"; do
    if [[ $name == $pattern ]]; then
      return 0
    fi
  done
  return 1
}

# =============================================================================
# VALIDATION LOGIC
# =============================================================================

# Iterate through all instruction files
for file in memory-bank/instructions/*.instructions.md; do
  # Skip if file doesn't exist (shouldn't happen with nullglob)
  [[ -f "$file" ]] || continue
  
  # Get base filename for pattern matching
  basename=$(basename "$file")

  # Rule 1: Check for required 'description:' header
  # This is used by VS Code to show file purpose in the UI
  if ! grep -Eq '^[[:space:]]*description:' "$file"; then
    errors+=("$file: missing description header")
  fi

  # Rule 2: Check for external links (unless file is in allowed list)
  # This ensures instructions are self-contained and work offline
  if ! allow_external_file "$basename"; then
    if grep -Eq 'https?://|http://|ftp://' "$file"; then
      errors+=("$file: external links are not allowed")
    fi
  fi

done

# =============================================================================
# REPORT RESULTS
# =============================================================================

# If errors were found, report them and exit with error code
if (( ${#errors[@]} > 0 )); then
  printf '[FAIL] Memory-bank instructions validation failed:\n'
  printf '  - %s\n' "${errors[@]}"
  exit 1
fi

# All validations passed
printf '[OK] Memory-bank instructions validation passed.\n'
