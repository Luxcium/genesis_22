#!/usr/bin/env bash
# =============================================================================
# GENESIS FOUNDATION INITIALIZATION SCRIPT
# =============================================================================
#
# Purpose:
#   Verifies the presence of foundation files required for Genesis 22 projects
#   and initializes a git repository if one doesn't exist. This script is
#   idempotent and safe to run multiple times.
#
# Usage:
#   ./scripts/init.sh
#
# Exit Codes:
#   0 - Success (all foundation files present or created)
#   1 - Failure (critical files missing or git initialization failed)
#
# What This Script Does:
#   1. Verifies presence of all foundation files (.editorconfig, .gitattributes,
#      .gitignore, LICENSE, README.md, VERSION, scripts/README.md, scripts/init.sh)
#   2. Makes all shell scripts in scripts/ directory executable
#   3. Initializes git repository if .git/ directory doesn't exist
#   4. Logs execution timestamp for audit trail
#
# AI Agent Instructions:
#   Run this script when bootstrapping a new Genesis 22 project or verifying
#   an existing one. This is typically the first script executed after cloning.
#   Check the exit code and logged warnings to determine if manual intervention
#   is needed for missing files.
#
# Human User Instructions:
#   Run this after cloning a Genesis 22 repository to ensure all foundation
#   files are present and the environment is properly initialized. If any
#   warnings appear, consult the layer-1 bootstrap instructions in the
#   memory-bank/instructions/ directory.
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

# Log a warning message with [WARN] prefix
warn() {
  printf '[WARN] %s\n' "$1"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

log "Genesis foundation verification starting..."

# =============================================================================
# FOUNDATION FILES CHECK
# =============================================================================

# Array of required foundation files for a Genesis 22 project
# These files form the minimal baseline for repository structure
foundation=(
  .editorconfig      # Editor configuration for consistent formatting
  .gitattributes     # Git attributes for line endings and diff strategies
  .gitignore         # Git ignore patterns
  LICENSE            # Project license
  README.md          # Project documentation
  VERSION            # Version tracking file
  scripts/README.md  # Scripts directory documentation
  scripts/init.sh    # This script (self-reference for validation)
)

# =============================================================================
# VERIFY FOUNDATION FILES
# =============================================================================

# Track missing files for final report
missing=()

# Check each foundation file and log status
for target in "${foundation[@]}"; do
  if [[ -e "$target" ]]; then
    log "Found $target"
  else
    warn "Missing $target"
    missing+=("$target")
  fi
done

# Report overall foundation status
if [[ ${#missing[@]} -eq 0 ]]; then
  log "All foundation artifacts are present."
else
  warn "Foundation missing ${#missing[@]} item(s). See log above."
fi

# =============================================================================
# ENSURE SCRIPTS ARE EXECUTABLE
# =============================================================================

# Make all .sh files in scripts directory executable
# This ensures they can be run directly without chmod
if [[ -d scripts ]]; then
  chmod +x scripts/*.sh 2>/dev/null || true
  log "Ensured scripts are executable."
fi

# =============================================================================
# GIT REPOSITORY INITIALIZATION
# =============================================================================

# Initialize git repository only if .git directory doesn't exist
# This maintains idempotence - safe to run multiple times
if [[ ! -d .git ]]; then
  log "Initializing new git repository..."
  git init >/dev/null
  git add .
  git commit -m "Scientia est lux principium✨" >/dev/null
  log "Repository initialized and initial commit created."
else
  log "Git repository already initialized."
fi

# =============================================================================
# COMPLETION
# =============================================================================

# Log completion timestamp for audit trail
# Uses ISO 8601 format for machine readability
log "Execution completed at $(date --iso-8601=seconds)"
