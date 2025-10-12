#!/usr/bin/env bash
# =============================================================================
# TRIAD HEALTH CHECK SCRIPT
# =============================================================================
#
# Purpose:
#   Validates the health of the memory-bank "triad" structure (instructions,
#   chatmodes, and prompts) and ensures VS Code settings are properly configured
#   for GitHub Copilot integration.
#
# Usage:
#   ./scripts/triad-health.sh
#
# Exit Codes:
#   0 - All health checks passed
#   1 - One or more health checks failed
#
# What This Script Checks:
#   1. Runs validators for memory-bank, chatmodes, and prompts
#   2. Counts files in each triad directory
#   3. Validates .vscode/settings.json configuration for:
#      - chat.instructionsFilesLocations
#      - chat.promptFiles toggle
#      - chat.promptFilesLocations
#      - chat.modeFilesLocations
#
# Dependencies:
#   - validate-memory-bank.sh
#   - validate-chatmodes.sh
#   - validate-prompts.sh
#   - python3 (for JSON parsing)
#
# AI Agent Instructions:
#   Run this script to verify the memory-bank triad is properly configured
#   and all validator scripts pass. If this fails, check the individual
#   validator output and the VS Code settings.json configuration.
#
# Human User Instructions:
#   This script ensures your development environment is properly configured
#   for GitHub Copilot's custom instructions feature. Run it after modifying
#   any files in memory-bank/ or .vscode/settings.json.
#
# =============================================================================

set -euo pipefail

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================

# Log an informational message with [INFO] prefix
log() {
  printf '[INFO] %s\n' "$1"
}

# =============================================================================
# VALIDATOR EXECUTION
# =============================================================================

# Array of validator scripts to run
# Each validator checks a specific aspect of the triad structure
scripts=(
  "$(dirname "$0")/validate-memory-bank.sh"    # Validates instructions files
  "$(dirname "$0")/validate-chatmodes.sh"      # Validates chatmode files
  "$(dirname "$0")/validate-prompts.sh"        # Validates prompt files
)

# =============================================================================
# RUN ALL VALIDATORS
# =============================================================================

# Track overall validation status
# 0 = success, 1 = failure
status=0

# Run each validator script and track results
for script in "${scripts[@]}"; do
  if "$script"; then
    log "$(basename "$script") passed"
  else
    log "$(basename "$script") failed"
    status=1
  fi
done

# =============================================================================
# COUNT TRIAD FILES
# =============================================================================

# Count files in each triad directory
# These counts help identify if expected files are present
instructions_count=$(find memory-bank/instructions -maxdepth 1 -name '*.instructions.md' | wc -l | tr -d ' ')
chatmode_count=$(find memory-bank/chatmodes -maxdepth 1 -name '*.chatmode.md' | wc -l | tr -d ' ')
prompt_count=$(find memory-bank/prompts -maxdepth 1 -name '*.prompt.md' | wc -l | tr -d ' ')

# Log the counts for informational purposes
log "Instructions: $instructions_count"
log "Chat modes: $chatmode_count"
log "Prompt cards: $prompt_count"

# =============================================================================
# VS CODE SETTINGS VALIDATION
# =============================================================================

# Use Python to validate VS Code settings.json configuration
# This ensures GitHub Copilot can discover the custom instructions
python3 <<'PY'
#!/usr/bin/env python3
"""
VS Code Settings Validator

This embedded Python script validates that .vscode/settings.json contains
the required configuration for GitHub Copilot custom instructions.

Required settings:
  - chat.instructionsFilesLocations: must include "memory-bank/instructions"
  - chat.promptFiles: must be enabled (true)
  - chat.promptFilesLocations: must include "memory-bank/prompts"
  - chat.modeFilesLocations: must include "memory-bank/chatmodes"

Exit codes:
  0 - All settings valid
  1 - One or more settings missing or invalid
"""
import json
import sys
from pathlib import Path

# Path to VS Code settings file
settings_path = Path('.vscode/settings.json')

# Track missing or invalid settings
missing = []

# Check if settings file exists
if not settings_path.exists():
    missing.append(".vscode/settings.json is missing")
else:
    # Parse JSON settings
    data = json.loads(settings_path.read_text(encoding='utf-8'))
    
    # Validate instructionsFilesLocations
    instructions_locations = data.get("chat.instructionsFilesLocations", {})
    if "memory-bank/instructions" not in instructions_locations:
        missing.append("settings.json missing chat.instructionsFilesLocations entry")
    
    # Validate promptFiles toggle
    if not data.get("chat.promptFiles", False):
        missing.append("settings.json missing chat.promptFiles toggle")
    
    # Validate promptFilesLocations
    prompt_locations = data.get("chat.promptFilesLocations", {})
    if "memory-bank/prompts" not in prompt_locations:
        missing.append("settings.json missing chat.promptFilesLocations entry")
    
    # Validate modeFilesLocations
    mode_locations = data.get("chat.modeFilesLocations", {})
    if "memory-bank/chatmodes" not in mode_locations:
        missing.append("settings.json missing chat.modeFilesLocations entry")

# Report results
if missing:
    for item in missing:
        print(item)
    sys.exit(1)
PY
# Capture Python script exit status
settings_status=$?

# =============================================================================
# FINAL STATUS REPORT
# =============================================================================

# Check if validators failed
if (( status != 0 )); then
  log "Triad health failed due to validator errors."
fi

# Check if VS Code settings validation failed
if (( settings_status != 0 )); then
  log "Triad health failed due to settings configuration."
fi

# Exit with error if any check failed
if (( status != 0 )) || (( settings_status != 0 )); then
  exit 1
fi

# All checks passed
log "Triad health check passed."
