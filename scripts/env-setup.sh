#!/usr/bin/env bash
# =============================================================================
# ENVIRONMENT SETUP AND VALIDATION SCRIPT
# =============================================================================
#
# Purpose:
#   Validates the development environment and provides a comprehensive report
#   of all tools, versions, and configurations. This script is idempotent and
#   safe to run repeatedly. It checks for required dependencies and provides
#   guidance when issues are found.
#
# Usage:
#   ./scripts/env-setup.sh [--verbose] [--report-only]
#
# Options:
#   --verbose      Show detailed output for all checks
#   --report-only  Only generate report, don't attempt any fixes
#
# Exit Codes:
#   0 - All checks passed, environment is ready
#   1 - Some checks failed, see output for details
#   2 - Critical failure, environment cannot be validated
#
# Environment Variables:
#   PYTHON_MIN_VERSION  - Minimum Python version (default: 3.8)
#   NODE_MIN_VERSION    - Minimum Node.js version (default: 18)
#
# AI Agent Instructions:
#   This script should be run at the start of any session to validate the
#   environment. The output provides essential context about available tools
#   and configurations. Always check the exit code to determine if the
#   environment is ready for work.
#
# Human User Instructions:
#   Run this script after cloning the repository or when setting up a new
#   development environment. It will check all required tools and provide
#   specific guidance if anything is missing or misconfigured.
#
# =============================================================================

set -euo pipefail

# =============================================================================
# CONFIGURATION AND CONSTANTS
# =============================================================================

readonly SCRIPT_VERSION="1.0.0"
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Minimum required versions
readonly PYTHON_MIN_VERSION="${PYTHON_MIN_VERSION:-3.8}"
readonly NODE_MIN_VERSION="${NODE_MIN_VERSION:-18}"

# Color codes for output (if terminal supports it)
if [[ -t 1 ]]; then
  readonly COLOR_RESET='\033[0m'
  readonly COLOR_RED='\033[0;31m'
  readonly COLOR_GREEN='\033[0;32m'
  readonly COLOR_YELLOW='\033[0;33m'
  readonly COLOR_BLUE='\033[0;34m'
  readonly COLOR_BOLD='\033[1m'
else
  readonly COLOR_RESET=''
  readonly COLOR_RED=''
  readonly COLOR_GREEN=''
  readonly COLOR_YELLOW=''
  readonly COLOR_BLUE=''
  readonly COLOR_BOLD=''
fi

# Flags for script behavior
VERBOSE=false
REPORT_ONLY=false

# =============================================================================
# LOGGING AND OUTPUT FUNCTIONS
# =============================================================================

# Log an informational message
log() {
  printf "${COLOR_BLUE}[INFO]${COLOR_RESET} %s\n" "$1"
}

# Log a success message
success() {
  printf "${COLOR_GREEN}[OK]${COLOR_RESET} %s\n" "$1"
}

# Log a warning message
warn() {
  printf "${COLOR_YELLOW}[WARN]${COLOR_RESET} %s\n" "$1"
}

# Log an error message
error() {
  printf "${COLOR_RED}[ERROR]${COLOR_RESET} %s\n" "$1" >&2
}

# Log a verbose message (only shown if --verbose is set)
verbose() {
  if [[ "$VERBOSE" == true ]]; then
    printf "${COLOR_BLUE}[DEBUG]${COLOR_RESET} %s\n" "$1"
  fi
}

# Print a section header
section() {
  printf "\n${COLOR_BOLD}=== %s ===${COLOR_RESET}\n" "$1"
}

# =============================================================================
# VERSION COMPARISON FUNCTION
# =============================================================================

# Compare two version strings (returns 0 if $1 >= $2, 1 otherwise)
version_gte() {
  local version=$1
  local required=$2
  
  # Remove 'v' prefix if present
  version="${version#v}"
  required="${required#v}"
  
  # Split versions into arrays
  IFS='.' read -ra ver_parts <<< "$version"
  IFS='.' read -ra req_parts <<< "$required"
  
  # Compare each part
  for i in "${!req_parts[@]}"; do
    local ver_part="${ver_parts[$i]:-0}"
    local req_part="${req_parts[$i]:-0}"
    
    # Extract numeric part (handle versions like "3.12.0-dev")
    ver_part=$(echo "$ver_part" | grep -oE '^[0-9]+' || echo "0")
    req_part=$(echo "$req_part" | grep -oE '^[0-9]+' || echo "0")
    
    if (( ver_part > req_part )); then
      return 0
    elif (( ver_part < req_part )); then
      return 1
    fi
  done
  
  return 0
}

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

# Check if a command exists
check_command() {
  local cmd=$1
  local name=${2:-$1}
  
  if command -v "$cmd" &>/dev/null; then
    success "$name is installed"
    verbose "  Path: $(command -v "$cmd")"
    return 0
  else
    error "$name is not installed"
    return 1
  fi
}

# Validate Bash version
validate_bash() {
  section "Bash Environment"
  
  local bash_version="${BASH_VERSION%%.*}"
  log "Bash version: $BASH_VERSION"
  
  if (( bash_version >= 4 )); then
    success "Bash version is sufficient (>= 4.0)"
    return 0
  else
    warn "Bash version is older than recommended (< 4.0)"
    return 1
  fi
}

# Validate Git installation and configuration
validate_git() {
  section "Git Environment"
  
  if ! check_command git "Git"; then
    error "Git is required but not installed"
    return 1
  fi
  
  local git_version
  git_version=$(git --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  log "Git version: $git_version"
  
  # Check git configuration
  local git_name git_email
  git_name=$(git config --get user.name || echo "")
  git_email=$(git config --get user.email || echo "")
  
  if [[ -n "$git_name" ]]; then
    success "Git user.name is configured: $git_name"
  else
    warn "Git user.name is not configured"
  fi
  
  if [[ -n "$git_email" ]]; then
    success "Git user.email is configured: $git_email"
  else
    warn "Git user.email is not configured"
  fi
  
  # Check if we're in a git repository
  if git rev-parse --git-dir &>/dev/null; then
    success "Currently in a Git repository"
    verbose "  Git directory: $(git rev-parse --git-dir)"
    
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    log "Current branch: $current_branch"
  else
    warn "Not currently in a Git repository"
  fi
  
  return 0
}

# Validate Python installation and environment
validate_python() {
  section "Python Environment"
  
  if ! check_command python3 "Python 3"; then
    error "Python 3 is required but not installed"
    return 1
  fi
  
  local python_version
  python_version=$(python3 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  log "Python version: $python_version"
  
  if version_gte "$python_version" "$PYTHON_MIN_VERSION"; then
    success "Python version is sufficient (>= $PYTHON_MIN_VERSION)"
  else
    error "Python version is too old (< $PYTHON_MIN_VERSION)"
    return 1
  fi
  
  # Check pip
  if command -v pip3 &>/dev/null; then
    local pip_version
    pip_version=$(pip3 --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    success "pip3 is installed (version: $pip_version)"
  else
    warn "pip3 is not installed"
  fi
  
  # Check for virtual environment
  if [[ -n "${VIRTUAL_ENV:-}" ]]; then
    success "Python virtual environment is active"
    log "Virtual environment: $VIRTUAL_ENV"
  else
    warn "No Python virtual environment is active"
    log "Consider creating one with: python3 -m venv venv && source venv/bin/activate"
  fi
  
  # Check for common Python tools
  local python_tools=("jupyter" "pylint" "black" "pytest")
  for tool in "${python_tools[@]}"; do
    if command -v "$tool" &>/dev/null; then
      verbose "  $tool: installed"
    else
      verbose "  $tool: not installed"
    fi
  done
  
  return 0
}

# Validate Node.js installation
validate_nodejs() {
  section "Node.js Environment"
  
  if ! check_command node "Node.js"; then
    warn "Node.js is not installed (optional for this project)"
    return 0
  fi
  
  local node_version
  node_version=$(node --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  log "Node.js version: $node_version"
  
  if version_gte "$node_version" "$NODE_MIN_VERSION"; then
    success "Node.js version is sufficient (>= $NODE_MIN_VERSION)"
  else
    warn "Node.js version is older than recommended (< $NODE_MIN_VERSION)"
  fi
  
  # Check npm
  if command -v npm &>/dev/null; then
    local npm_version
    npm_version=$(npm --version 2>&1)
    success "npm is installed (version: $npm_version)"
  else
    warn "npm is not installed"
  fi
  
  return 0
}

# Validate project structure
validate_project_structure() {
  section "Project Structure"
  
  cd "$PROJECT_ROOT" || return 1
  
  # Check foundation files
  local foundation_files=(
    ".editorconfig"
    ".gitattributes"
    ".gitignore"
    "LICENSE"
    "README.md"
    "VERSION"
    "scripts/README.md"
    "scripts/init.sh"
  )
  
  local missing_count=0
  for file in "${foundation_files[@]}"; do
    if [[ -e "$file" ]]; then
      verbose "  Found: $file"
    else
      warn "  Missing: $file"
      ((missing_count++))
    fi
  done
  
  if (( missing_count == 0 )); then
    success "All foundation files are present"
  else
    warn "$missing_count foundation file(s) missing"
  fi
  
  # Check memory-bank structure
  local membank_dirs=(
    "memory-bank/instructions"
    "memory-bank/chatmodes"
    "memory-bank/prompts"
  )
  
  for dir in "${membank_dirs[@]}"; do
    if [[ -d "$dir" ]]; then
      local count
      count=$(find "$dir" -maxdepth 1 -type f | wc -l | tr -d ' ')
      success "Found $dir ($count files)"
    else
      warn "Missing directory: $dir"
    fi
  done
  
  # Check notebook structure
  if [[ -d "notebooks" ]]; then
    success "Notebooks directory exists"
    if [[ -f "notebooks/requirements.txt" ]]; then
      verbose "  notebooks/requirements.txt found"
    fi
  else
    verbose "  notebooks/ directory not present"
  fi
  
  return 0
}

# Validate notebook environment
validate_notebook_environment() {
  section "Jupyter Notebook Environment"
  
  cd "$PROJECT_ROOT" || return 1
  
  if [[ ! -d "notebooks" ]]; then
    log "Notebooks directory not present, skipping notebook validation"
    return 0
  fi
  
  # Check for requirements file
  if [[ -f "notebooks/requirements.txt" ]]; then
    success "Found notebooks/requirements.txt"
    
    # Check if jupyter is installed
    if command -v jupyter &>/dev/null; then
      local jupyter_version
      jupyter_version=$(jupyter --version 2>&1 | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
      success "Jupyter is installed (version: $jupyter_version)"
      
      # List installed kernels
      if jupyter kernelspec list &>/dev/null; then
        verbose "Available Jupyter kernels:"
        jupyter kernelspec list 2>/dev/null | tail -n +2 | while read -r line; do
          verbose "  $line"
        done
      fi
    else
      warn "Jupyter is not installed"
      log "Install with: pip3 install -r notebooks/requirements.txt"
    fi
    
    # Check key dependencies
    local key_deps=("numpy" "pandas" "matplotlib" "scikit-learn")
    for dep in "${key_deps[@]}"; do
      if python3 -c "import $dep" &>/dev/null; then
        verbose "  $dep: installed"
      else
        verbose "  $dep: not installed"
      fi
    done
  else
    log "No requirements.txt found in notebooks/"
  fi
  
  return 0
}

# Validate scripts
validate_scripts() {
  section "Shell Scripts"
  
  cd "$PROJECT_ROOT/scripts" || return 1
  
  local script_count=0
  local executable_count=0
  
  shopt -s nullglob
  for script in *.sh; do
    ((script_count++))
    if [[ -x "$script" ]]; then
      ((executable_count++))
      verbose "  $script: executable"
    else
      warn "  $script: not executable"
    fi
  done
  shopt -u nullglob
  
  log "Found $script_count shell scripts, $executable_count executable"
  
  if (( script_count == executable_count )); then
    success "All scripts are executable"
  else
    warn "Some scripts are not executable. Run: chmod +x scripts/*.sh"
  fi
  
  return 0
}

# =============================================================================
# REPORT GENERATION
# =============================================================================

generate_report() {
  section "Environment Report"
  
  cat <<EOF

${COLOR_BOLD}Genesis 22 Environment Report${COLOR_RESET}
Generated: $(date --iso-8601=seconds 2>/dev/null || date)
Script Version: $SCRIPT_VERSION
Project Root: $PROJECT_ROOT

${COLOR_BOLD}System Information:${COLOR_RESET}
  OS: $(uname -s)
  Kernel: $(uname -r)
  Architecture: $(uname -m)
  Hostname: $(hostname)

${COLOR_BOLD}Shell:${COLOR_RESET}
  Bash: $BASH_VERSION
  Shell: $SHELL

${COLOR_BOLD}Required Tools:${COLOR_RESET}
EOF

  # Git info
  if command -v git &>/dev/null; then
    echo "  Git: $(git --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  else
    echo "  Git: NOT INSTALLED"
  fi
  
  # Python info
  if command -v python3 &>/dev/null; then
    echo "  Python: $(python3 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
    if command -v pip3 &>/dev/null; then
      echo "  pip: $(pip3 --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
    fi
  else
    echo "  Python: NOT INSTALLED"
  fi
  
  # Node info
  if command -v node &>/dev/null; then
    echo "  Node.js: $(node --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
    if command -v npm &>/dev/null; then
      echo "  npm: $(npm --version 2>&1)"
    fi
  else
    echo "  Node.js: not installed (optional)"
  fi
  
  # Jupyter info
  if command -v jupyter &>/dev/null; then
    echo "  Jupyter: $(jupyter --version 2>&1 | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "installed")"
  fi
  
  echo ""
  echo "${COLOR_BOLD}Project Status:${COLOR_RESET}"
  
  # Count files
  local instructions_count chatmodes_count prompts_count
  instructions_count=$(find memory-bank/instructions -maxdepth 1 -name '*.instructions.md' 2>/dev/null | wc -l | tr -d ' ')
  chatmodes_count=$(find memory-bank/chatmodes -maxdepth 1 -name '*.chatmode.md' 2>/dev/null | wc -l | tr -d ' ')
  prompts_count=$(find memory-bank/prompts -maxdepth 1 -name '*.prompt.md' 2>/dev/null | wc -l | tr -d ' ')
  
  echo "  Instructions: $instructions_count files"
  echo "  Chat Modes: $chatmodes_count files"
  echo "  Prompts: $prompts_count files"
  
  # Scripts count
  local scripts_count
  scripts_count=$(find scripts -maxdepth 1 -name '*.sh' 2>/dev/null | wc -l | tr -d ' ')
  echo "  Shell Scripts: $scripts_count files"
  
  echo ""
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
  # Parse command line arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --verbose|-v)
        VERBOSE=true
        shift
        ;;
      --report-only)
        REPORT_ONLY=true
        shift
        ;;
      --help|-h)
        cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS]

Validate the development environment and generate a comprehensive report.

Options:
  --verbose, -v       Show detailed output for all checks
  --report-only       Only generate report, don't attempt any fixes
  --help, -h          Show this help message

Exit Codes:
  0 - All checks passed
  1 - Some checks failed
  2 - Critical failure

Examples:
  $SCRIPT_NAME                  # Run all validations
  $SCRIPT_NAME --verbose        # Run with detailed output
  $SCRIPT_NAME --report-only    # Just generate the report

EOF
        exit 0
        ;;
      *)
        error "Unknown option: $1"
        error "Use --help for usage information"
        exit 2
        ;;
    esac
  done
  
  log "Starting environment validation..."
  log "Script version: $SCRIPT_VERSION"
  verbose "Project root: $PROJECT_ROOT"
  verbose "Verbose mode: $VERBOSE"
  verbose "Report only: $REPORT_ONLY"
  
  # Track overall status
  local overall_status=0
  
  # Run all validations
  validate_bash || overall_status=1
  validate_git || overall_status=1
  validate_python || overall_status=1
  validate_nodejs || overall_status=1
  validate_project_structure || overall_status=1
  validate_scripts || overall_status=1
  validate_notebook_environment || overall_status=1
  
  # Generate final report
  generate_report
  
  # Final status
  if (( overall_status == 0 )); then
    section "Validation Complete"
    success "All environment checks passed!"
    log "Environment is ready for development."
  else
    section "Validation Complete"
    warn "Some environment checks failed."
    log "Review the output above for specific issues and recommendations."
  fi
  
  log "Execution completed at $(date --iso-8601=seconds 2>/dev/null || date)"
  
  return $overall_status
}

# Run main function
main "$@"
