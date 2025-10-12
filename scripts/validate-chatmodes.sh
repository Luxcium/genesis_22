#!/usr/bin/env bash
# =============================================================================
# CHATMODE FILES VALIDATOR
# =============================================================================
#
# Purpose:
#   Validates that all chatmode files in memory-bank/chatmodes/ follow the
#   required format, use approved models, and have correct tool configurations.
#
# Usage:
#   ./scripts/validate-chatmodes.sh
#
# Exit Codes:
#   0 - All validations passed
#   1 - One or more validation errors found
#
# Validation Rules:
#   1. Must have 'description:' in front-matter
#   2. Must specify an allowed model (GPT-5 Preview or GPT-5 mini Preview)
#   3. Must have exactly the tools: ['codebase', 'editFiles', 'fetch']
#   4. Must have exactly one H1 heading
#   5. No external links allowed (http://, https://, ftp://)
#   6. All links must be relative paths
#
# Allowed Models:
#   - GPT-5 (Preview)
#   - GPT-5 mini (Preview)
#
# Required Tools:
#   - ['codebase', 'editFiles', 'fetch']
#
# AI Agent Instructions:
#   Run this validator before committing changes to memory-bank/chatmodes/.
#   Chat modes must use approved models and tools to ensure consistent behavior
#   across the development team. Never modify existing model or tools values
#   without explicit user approval.
#
# Human User Instructions:
#   If this validator fails, check the specific error messages. Ensure your
#   chatmode file uses an approved model and the exact tools list. All links
#   must be relative (no external URLs).
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

# Only these models are allowed in chatmode files
allowed_models=("GPT-5 (Preview)" "GPT-5 mini (Preview)")

# Exact tools specification required (must match exactly)
expected_tools="['codebase', 'editFiles', 'fetch']"

# =============================================================================
# VALIDATION LOGIC
# =============================================================================

# Iterate through all chatmode files
for file in memory-bank/chatmodes/*.chatmode.md; do
  # Skip if file doesn't exist (shouldn't happen with nullglob)
  [[ -f "$file" ]] || continue
  
  # Parse front-matter and extract key values
  in_front=0         # Flag: are we inside front-matter block?
  description_found=0  # Flag: did we find description field?
  model_value=""     # Extracted model value
  tools_value=""     # Extracted tools value

  # Read file line by line to parse front-matter
  while IFS='' read -r line; do
    # Front-matter is delimited by '---' markers
    if [[ $line == '---' ]]; then
      if (( in_front == 0 )); then
        # Start of front-matter
        in_front=1
        continue
      else
        # End of front-matter
        break
      fi
    fi

    # Parse front-matter fields
    if (( in_front == 1 )); then
      case $line in
        description:*) description_found=1 ;;
        model:*) model_value=${line#model: } ;;
        tools:*) tools_value=${line#tools: } ;;
      esac
    fi
  done < "$file"

  # Validation: Check for required description
  if (( description_found == 0 )); then
    errors+=("$file: missing description in front-matter")
  fi

  # Validation: Check model is specified and allowed
  if [[ -z $model_value ]]; then
    errors+=("$file: missing model in front-matter")
  else
    # Check if model is in allowed list
    match=0
    for allowed in "${allowed_models[@]}"; do
      if [[ $model_value == "$allowed" ]]; then
        match=1
        break
      fi
    done
    if (( match == 0 )); then
      errors+=("$file: model '$model_value' is not allowed")
    fi
  fi

  # Validation: Check tools are specified and match exactly
  if [[ -z $tools_value ]]; then
    errors+=("$file: missing tools in front-matter")
  elif [[ $tools_value != "$expected_tools" ]]; then
    errors+=("$file: tools must be exactly $expected_tools")
  fi

  # Validation: Must have exactly one H1 heading
  h1_count=$(grep -c '^# ' "$file" || true)
  if [[ $h1_count -ne 1 ]]; then
    errors+=("$file: expected exactly one H1 heading, found $h1_count")
  fi

  # Validation: No external links allowed
  if grep -Eq 'https?://|http://|ftp://' "$file"; then
    errors+=("$file: external links are not allowed")
  fi

  # Validation: All links must be relative
  if grep -Eq '://[^ )]+' "$file"; then
    errors+=("$file: links must be relative")
  fi

done

# =============================================================================
# REPORT RESULTS
# =============================================================================

# If errors were found, report them and exit with error code
if (( ${#errors[@]} > 0 )); then
  printf '[FAIL] Chatmode validation failed:\n'
  printf '  - %s\n' "${errors[@]}"
  exit 1
fi

# All validations passed
printf '[OK] Chatmode validation passed.\n'
