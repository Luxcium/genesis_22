#!/usr/bin/env bash
# =============================================================================
# ENSURE MEMORY-BANK AGENTS PLANS SCRIPT
# =============================================================================
#
# Purpose:
#   Checks for the presence of the memory-bank/agents/ directory and installs
#   the canonical PLANS.md file from the Genesis 22 template when missing. If
#   the directory (and file) already exist, the script compares the local copy
#   against the upstream reference to highlight differences.
#
# Usage:
#   ./scripts/ensure-plans.sh [--show-diff]
#
# Options:
#   --show-diff  Print the unified diff when differences are detected.
#
# Exit Codes:
#   0 - Success; PLANS.md installed or already matches upstream.
#   1 - Differences detected between local and upstream PLANS.md.
#   2 - Critical failure (missing dependencies, network error, etc.).
#
# What This Script Does:
#   1. Validates that required utilities (curl, diff, mktemp) are available.
#   2. Ensures the memory-bank/agents directory exists, creating it if needed.
#   3. Downloads the upstream PLANS.md when the local file is missing.
#   4. If the local file exists, runs a background diff against the upstream
#      version and reports whether the contents match.
#
# AI Agent Instructions:
#   Run this script to guarantee the canonical ExecPlan template is present.
#   Treat a non-zero exit code as a signal to reconcile local modifications
#   with the upstream reference before proceeding.
#
# Human User Instructions:
#   Execute this script after cloning or when auditing template drift. If the
#   script exits with code 1, inspect the reported differences and decide
#   whether to update the local PLANS.md file.
#
# =============================================================================

set -Eeuo pipefail

# =============================================================================
# CONSTANTS AND CONFIGURATION
# =============================================================================

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly AGENTS_DIR="$PROJECT_ROOT/memory-bank/agents"
readonly LOCAL_PLANS_FILE="$AGENTS_DIR/PLANS.md"
readonly REMOTE_PLANS_URL="https://raw.githubusercontent.com/Luxcium/genesis_22/a7e20c9e4013b89072258a7349bc192b84617e31/memory-bank/agents/PLANS.md"

SHOW_DIFF=false
EXIT_STATUS=0
REMOTE_TEMP_FILE=""
DIFF_TEMP_FILE=""

# =============================================================================
# LOGGING UTILITIES
# =============================================================================

log_info()  { printf '[INFO] %s\n' "$1"; }
log_warn()  { printf '[WARN] %s\n' "$1"; }
log_error() { printf '[ERROR] %s\n' "$1" >&2; }
log_ok()    { printf '[OK] %s\n' "$1"; }

# =============================================================================
# CLEANUP HANDLER
# =============================================================================

cleanup() {
  if [[ -n "$REMOTE_TEMP_FILE" && -f "$REMOTE_TEMP_FILE" ]]; then
    rm -f "$REMOTE_TEMP_FILE"
  fi
  if [[ -n "$DIFF_TEMP_FILE" && -f "$DIFF_TEMP_FILE" ]]; then
    rm -f "$DIFF_TEMP_FILE"
  fi
}

trap cleanup EXIT

# =============================================================================
# ARGUMENT PARSING
# =============================================================================

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --show-diff)
        SHOW_DIFF=true
        shift
        ;;
      -h|--help)
        print_help
        exit 0
        ;;
      *)
        log_error "Unknown argument: $1"
        print_help >&2
        exit 2
        ;;
    esac
  done
}

print_help() {
  cat <<'EOF'
Usage: ./scripts/ensure-plans.sh [--show-diff]

Ensures memory-bank/agents/PLANS.md exists and matches the upstream reference.

Options:
  --show-diff   Print the unified diff when differences are detected.
  -h, --help    Display this help message.

Exit codes:
  0  Success (installed upstream file or local copy matches)
  1  Differences detected between local and upstream
  2  Critical error (missing commands, download failure, etc.)
EOF
}

# =============================================================================
# PRECONDITION CHECKS
# =============================================================================

ensure_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log_error "Required command '$cmd' is not available."
    exit 2
  fi
}

check_prerequisites() {
  ensure_command curl
  ensure_command diff
  ensure_command mktemp
}

# =============================================================================
# CORE OPERATIONS
# =============================================================================

ensure_agents_directory() {
  if [[ ! -d "$AGENTS_DIR" ]]; then
    log_info "Creating missing directory: $AGENTS_DIR"
    mkdir -p "$AGENTS_DIR"
    log_ok "Directory created."
  else
    log_ok "Directory exists: $AGENTS_DIR"
  fi
}

fetch_remote_plans() {
  REMOTE_TEMP_FILE="$(mktemp)"
  log_info "Downloading upstream PLANS.md"
  if ! curl -fsSL "$REMOTE_PLANS_URL" -o "$REMOTE_TEMP_FILE"; then
    log_error "Failed to download upstream PLANS.md from $REMOTE_PLANS_URL"
    exit 2
  fi
  log_ok "Downloaded upstream PLANS.md"
}

install_plans_if_missing() {
  if [[ ! -f "$LOCAL_PLANS_FILE" ]]; then
    log_info "Local PLANS.md not found. Installing upstream template."
    cp "$REMOTE_TEMP_FILE" "$LOCAL_PLANS_FILE"
    log_ok "Installed upstream PLANS.md at $LOCAL_PLANS_FILE"
    EXIT_STATUS=0
    return 0
  fi
  return 1
}

compare_plans_files() {
  DIFF_TEMP_FILE="$(mktemp)"
  log_info "Comparing local PLANS.md with upstream reference"

  # Run diff in background while temporarily disabling exit-on-error.
  set +e
  diff -u "$LOCAL_PLANS_FILE" "$REMOTE_TEMP_FILE" >"$DIFF_TEMP_FILE" &
  local diff_pid=$!
  wait "$diff_pid"
  local diff_exit=$?
  set -e

  case "$diff_exit" in
    0)
      log_ok "Local PLANS.md matches upstream reference."
      EXIT_STATUS=0
      ;;
    1)
      log_warn "Differences detected between local and upstream PLANS.md."
      EXIT_STATUS=1
      if [[ "$SHOW_DIFF" == true ]]; then
        printf '\n%s\n' "===== BEGIN DIFF ====="
        cat "$DIFF_TEMP_FILE"
        printf '%s\n\n' "===== END DIFF ====="
      else
        log_info "Run with --show-diff to see the unified diff."
      fi
      ;;
    *)
      log_error "diff command failed with exit code $diff_exit."
      EXIT_STATUS=2
      ;;
  esac
}

# =============================================================================
# MAIN
# =============================================================================

main() {
  parse_args "$@"
  check_prerequisites
  ensure_agents_directory
  fetch_remote_plans

  if install_plans_if_missing; then
    log_info "No comparison necessary; upstream template installed."
    exit "$EXIT_STATUS"
  fi

  compare_plans_files
  exit "$EXIT_STATUS"
}

main "$@"
