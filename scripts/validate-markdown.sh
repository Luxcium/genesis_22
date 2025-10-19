#!/usr/bin/env bash
# =============================================================================
# MARKDOWN FILES VALIDATOR
# =============================================================================
#
# Purpose:
#   Validates that all markdown files follow the project's linting rules and
#   conventions. Checks for common formatting issues, typos, and structural
#   problems.
#
# Usage:
#   ./scripts/validate-markdown.sh [--fix-typos] [--check-only]
#
# Options:
#   --fix-typos    Automatically fix common typos in markdown files
#   --check-only   Only report issues, don't suggest fixes
#
# Exit Codes:
#   0 - All validations passed
#   1 - One or more validation errors or warnings found
#   2 - Critical failure (missing dependencies, file access errors)
#
# Validation Rules:
#   1. No trailing spaces (except for line breaks)
#   2. No multiple consecutive blank lines
#   3. No hard tabs (use spaces)
#   4. Headings surrounded by blank lines
#   5. Space after heading hash marks
#   6. No trailing punctuation in headings (except ? and !)
#   7. Consistent list markers (use -)
#   8. Code blocks specify language
#   9. Common typo detection
#   10. Line length recommendations (warnings only)
#
# AI Agent Instructions:
#   Run this validator on all markdown files before committing changes.
#   This ensures consistent formatting across the project and catches
#   common typos. If validation fails, either fix issues manually or
#   use the --fix-typos flag for automatic corrections of typos.
#   Always re-run the validator after making fixes to ensure all issues
#   are resolved.
#
# Human User Instructions:
#   If this validator fails, review the specific error messages for each file.
#   Most formatting issues can be fixed manually by following the suggestions.
#   Use --fix-typos flag to automatically correct common typos. After fixing
#   issues, re-run the validator to confirm all problems are resolved.
#
# =============================================================================

set -uo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

# Enable extended globbing for pattern matching
shopt -s nullglob

# Colors for output (if terminal supports it)
if [[ -t 1 ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m' # No Color
else
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  NC=''
fi

# Command line options
FIX_TYPOS=0
CHECK_ONLY=0

# Parse command line arguments
for arg in "$@"; do
  case $arg in
    --fix-typos)
      FIX_TYPOS=1
      shift
      ;;
    --check-only)
      CHECK_ONLY=1
      shift
      ;;
    *)
      # Unknown option
      ;;
  esac
done

# Track validation results
errors=()
warnings=()
files_checked=0
files_with_issues=0

# Common typos to detect (typo -> correct)
declare -A typos=(
  ["alwas"]="always"
  ["alredy"]="already"
  ["ouutput"]="output"
  ["uare"]="are"
  ["puurposful"]="purposeful"
  ["anumerate"]="enumerate"
  ["beggining"]="beginning"
  ["occured"]="occurred"
  ["recieve"]="receive"
  ["seperate"]="separate"
  ["teh"]="the"
  ["adn"]="and"
  ["taht"]="that"
  ["thier"]="their"
  ["thier"]="their"
  ["becuase"]="because"
  ["definately"]="definitely"
  ["occurance"]="occurrence"
  ["untill"]="until"
)

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_ok() {
  echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

log_fail() {
  echo -e "${RED}[FAIL]${NC} $1"
}

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

# Check for trailing spaces (except double space for line break)
check_trailing_spaces() {
  local file="$1"
  local issues_found=0
  
  while IFS= read -r line_num; do
    if [[ $issues_found -eq 0 ]]; then
      errors+=("$file: trailing spaces found (lines: $line_num)")
      issues_found=1
    fi
  done < <(grep -n ' $' "$file" | grep -v '  $' | cut -d: -f1 || true)
  
  return $issues_found
}

# Check for multiple consecutive blank lines
check_multiple_blank_lines() {
  local file="$1"
  local issues_found=0
  local blank_count=0
  local line_num=0
  
  while IFS= read -r line; do
    ((line_num++))
    if [[ -z "$line" ]]; then
      ((blank_count++))
      if [[ $blank_count -gt 1 ]]; then
        if [[ $issues_found -eq 0 ]]; then
          errors+=("$file: multiple consecutive blank lines (around line $line_num)")
          issues_found=1
        fi
      fi
    else
      blank_count=0
    fi
  done < "$file"
  
  return $issues_found
}

# Check for hard tabs
check_hard_tabs() {
  local file="$1"
  local issues_found=0
  
  if grep -q $'\t' "$file"; then
    errors+=("$file: hard tabs found (use spaces instead)")
    issues_found=1
  fi
  
  return $issues_found
}

# Check heading formatting
check_headings() {
  local file="$1"
  local issues_found=0
  local prev_line=""
  local line_num=0
  local in_front_matter=0
  local in_code_block=0
  
  while IFS= read -r line; do
    ((line_num++))
    
    # Track code blocks
    if [[ "$line" =~ ^\`\`\` ]]; then
      if [[ $in_code_block -eq 0 ]]; then
        in_code_block=1
      else
        in_code_block=0
      fi
      prev_line="$line"
      continue
    fi
    
    # Skip lines in code blocks
    if [[ $in_code_block -eq 1 ]]; then
      prev_line="$line"
      continue
    fi
    
    # Track front matter
    if [[ "$line" =~ ^---$ ]]; then
      if [[ $in_front_matter -eq 0 ]]; then
        in_front_matter=1
        prev_line="$line"
        continue
      else
        in_front_matter=0
        prev_line="$line"
        continue
      fi
    fi
    
    # Skip lines in front matter
    if [[ $in_front_matter -eq 1 ]]; then
      prev_line="$line"
      continue
    fi
    
    # Check if line starts with # (potential heading)
    if [[ "$line" =~ ^#+ ]]; then
      # Check for space after hash marks (proper heading format: "# Text" or "## Text")
      if ! [[ "$line" =~ ^#+\  ]]; then
        errors+=("$file:$line_num: no space after # in heading")
        issues_found=1
        # Skip other checks if not a proper heading
        prev_line="$line"
        continue
      fi
      
      # Check for multiple spaces after hash
      if [[ "$line" =~ ^#+\ \ + ]]; then
        errors+=("$file:$line_num: multiple spaces after # in heading")
        issues_found=1
      fi
      
      # Check for trailing punctuation (except ? and !)
      if [[ "$line" =~ [.,]$ ]] || [[ "$line" =~ [\;:]$ ]]; then
        errors+=("$file:$line_num: heading ends with punctuation")
        issues_found=1
      fi
      
      # Check for blank line before heading (skip if first line after front matter)
      if [[ -n "$prev_line" ]] && [[ $line_num -gt 2 ]]; then
        local check_prev=1
        # Allow heading right after front matter end
        if [[ "$prev_line" =~ ^---$ ]]; then
          check_prev=0
        fi
        # Allow heading after HTML comment
        if [[ "$prev_line" =~ ^\<\!-- ]]; then
          check_prev=0
        fi
        if [[ $check_prev -eq 1 ]] && [[ -n "$prev_line" ]]; then
          warnings+=("$file:$line_num: heading not surrounded by blank lines")
        fi
      fi
    fi
    
    prev_line="$line"
  done < "$file"
  
  return $issues_found
}

# Check code block language specification
check_code_blocks() {
  local file="$1"
  local issues_found=0
  local line_num=0
  
  while IFS= read -r line; do
    ((line_num++))
    
    # Check for code block without language
    if [[ "$line" =~ ^\`\`\`$ ]]; then
      warnings+=("$file:$line_num: code block without language specification")
    fi
  done < "$file"
  
  return $issues_found
}

# Check for common typos
check_typos() {
  local file="$1"
  local issues_found=0
  
  for typo in "${!typos[@]}"; do
    local correct="${typos[$typo]}"
    
    # Use word boundaries to avoid partial matches
    if grep -qiw "$typo" "$file"; then
      local line_nums=$(grep -niw "$typo" "$file" | cut -d: -f1 | tr '\n' ',' | sed 's/,$//')
      warnings+=("$file: possible typo '$typo' -> '$correct' (lines: $line_nums)")
      issues_found=1
    fi
  done
  
  return $issues_found
}

# Check line length (warning only)
check_line_length() {
  local file="$1"
  local max_length=120
  local issues_found=0
  local in_code_block=0
  local line_num=0
  
  while IFS= read -r line; do
    ((line_num++))
    
    # Track code blocks
    if [[ "$line" =~ ^\`\`\` ]]; then
      if [[ $in_code_block -eq 0 ]]; then
        in_code_block=1
      else
        in_code_block=0
      fi
      continue
    fi
    
    # Skip code blocks, URLs, and tables
    if [[ $in_code_block -eq 1 ]] || [[ "$line" =~ http ]] || [[ "$line" =~ ^\| ]]; then
      continue
    fi
    
    # Check line length
    if [[ ${#line} -gt $max_length ]]; then
      if [[ $issues_found -eq 0 ]]; then
        warnings+=("$file: lines exceed $max_length characters (first at line $line_num)")
        issues_found=1
      fi
      break
    fi
  done < "$file"
  
  return $issues_found
}

# Fix typos in file
fix_typos_in_file() {
  local file="$1"
  local temp_file="${file}.tmp"
  local fixed_count=0
  
  cp "$file" "$temp_file"
  
  for typo in "${!typos[@]}"; do
    local correct="${typos[$typo]}"
    
    # Fix case-sensitive matches with word boundaries
    if grep -qw "$typo" "$temp_file"; then
      sed -i "s/\b$typo\b/$correct/g" "$temp_file"
      ((fixed_count++))
    fi
    
    # Fix case-insensitive but preserve case for first letter
    local typo_cap="$(tr '[:lower:]' '[:upper:]' <<< ${typo:0:1})${typo:1}"
    local correct_cap="$(tr '[:lower:]' '[:upper:]' <<< ${correct:0:1})${correct:1}"
    if grep -qw "$typo_cap" "$temp_file"; then
      sed -i "s/\b$typo_cap\b/$correct_cap/g" "$temp_file"
      ((fixed_count++))
    fi
  done
  
  if [[ $fixed_count -gt 0 ]]; then
    mv "$temp_file" "$file"
    log_info "$file: fixed $fixed_count typo(s)"
  else
    rm "$temp_file"
  fi
}

# Validate a single markdown file
validate_file() {
  local file="$1"
  local file_has_issues=0
  
  # Run all checks
  check_trailing_spaces "$file" || file_has_issues=1
  check_multiple_blank_lines "$file" || file_has_issues=1
  check_hard_tabs "$file" || file_has_issues=1
  check_headings "$file" || file_has_issues=1
  check_code_blocks "$file" || file_has_issues=1
  check_typos "$file" || file_has_issues=1
  check_line_length "$file" || file_has_issues=1
  
  return $file_has_issues
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

log_info "Starting markdown validation..."

# Find all markdown files
markdown_files=()
while IFS= read -r -d '' file; do
  markdown_files+=("$file")
done < <(find . -type f -name "*.md" -not -path "*/node_modules/*" -not -path "*/.git/*" -print0)

if [[ ${#markdown_files[@]} -eq 0 ]]; then
  log_error "No markdown files found"
  exit 2
fi

log_info "Found ${#markdown_files[@]} markdown file(s) to validate"

# Apply typo fixes if requested
if [[ $FIX_TYPOS -eq 1 ]]; then
  log_info "Applying typo fixes..."
  for file in "${markdown_files[@]}"; do
    fix_typos_in_file "$file"
  done
  log_ok "Typo fixes applied"
fi

# Validate each file
for file in "${markdown_files[@]}"; do
  ((files_checked++))
  log_info "Validating file $files_checked/${#markdown_files[@]}: $file"
  
  if ! validate_file "$file"; then
    ((files_with_issues++))
  fi
done

# =============================================================================
# REPORT RESULTS
# =============================================================================

echo ""
log_info "Validation complete: checked $files_checked file(s)"

# Report errors
if [[ ${#errors[@]} -gt 0 ]]; then
  echo ""
  log_fail "Found ${#errors[@]} error(s):"
  for error in "${errors[@]}"; do
    echo "  - $error"
  done
fi

# Report warnings
if [[ ${#warnings[@]} -gt 0 ]]; then
  echo ""
  log_warn "Found ${#warnings[@]} warning(s):"
  for warning in "${warnings[@]}"; do
    echo "  - $warning"
  done
fi

# Summary
echo ""
if [[ ${#errors[@]} -eq 0 ]] && [[ ${#warnings[@]} -eq 0 ]]; then
  log_ok "All markdown files are valid!"
  exit 0
elif [[ ${#errors[@]} -eq 0 ]]; then
  log_warn "Validation completed with warnings (${#warnings[@]} warning(s))"
  if [[ $CHECK_ONLY -eq 0 ]]; then
    echo ""
    log_info "Tips:"
    echo "  - Review warnings and consider addressing them"
    echo "  - Use --fix-typos to automatically fix common typos"
    echo "  - Some warnings are informational and may not require action"
  fi
  exit 0
else
  log_fail "Validation failed with ${#errors[@]} error(s) and ${#warnings[@]} warning(s)"
  if [[ $CHECK_ONLY -eq 0 ]]; then
    echo ""
    log_info "Tips:"
    echo "  - Fix errors in the listed files"
    echo "  - Use --fix-typos to automatically fix common typos"
    echo "  - Re-run validator after making changes"
    echo "  - See memory-bank/instructions/markdown-linting-rules.instructions.md for details"
  fi
  exit 1
fi
