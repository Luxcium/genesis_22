# Tech Context

## Stack Baseline
- **Node.js 22+** runtime (20.19.5 currently available)
- **Python 3.8+** for scripts and automation (3.12.3 currently available, 3.12 recommended for notebooks)
- **Bash 4.0+** for shell scripts (5.2.21 currently available)
- TypeScript-first development with TSDoc annotations for documented APIs
- ESLint flat configuration paired with `eslint-config-prettier` for formatting harmony

## Tooling

### Core Scripts
- `scripts/init.sh` - Validates foundation files and handles git bootstrapping if needed
- `scripts/env-setup.sh` - Comprehensive environment validation and reporting (new in 2025-10-12)
  - Checks Bash, Git, Python, Node.js versions
  - Validates project structure and memory-bank directories
  - Verifies Jupyter notebook environment
  - Generates detailed environment report
  - Supports `--verbose` and `--report-only` flags
- `scripts/triad-health.sh` - Validates memory-bank triad and VS Code settings
- `scripts/validate-memory-bank.sh` - Validates instruction file format
- `scripts/validate-chatmodes.sh` - Validates chatmode file format and configuration
- `scripts/validate-prompts.sh` - Validates prompt file structure
- `scripts/list-slash-commands.sh` - Lists all available slash commands from prompts

### Development Environment
- **VS Code** workspace settings tie Copilot to the memory-bank triad for contextual responses
- **Git** version control (2.51.0 currently available)
- **Python** ecosystem:
  - pip for package management
  - Virtual environments recommended (`python3 -m venv venv`)
  - Jupyter for notebook work (optional)
- **Node.js** ecosystem (optional for this project):
  - npm for package management (10.8.2 currently available)

### Validation and Health Checks
All validators designed to run before commits:
- Memory-bank validator checks for required headers and disallows external links (with exceptions)
- Chatmode validator enforces approved models and exact tools configuration
- Prompt validator ensures proper structure with front-matter and slash commands
- Triad health check validates entire memory-bank structure and VS Code settings

## Environment Requirements

### Minimum Versions
- Python: 3.8+ (configurable via `PYTHON_MIN_VERSION`)
- Node.js: 18+ (configurable via `NODE_MIN_VERSION`)
- Bash: 4.0+
- Git: Any recent version

### Recommended Setup
- Python 3.12 for notebook work
- Node.js 20+ for TypeScript projects
- Bash 5.0+ for extended features
- Virtual environment for Python dependencies

### Environment Validation
Run `scripts/env-setup.sh` at the start of any session to:
- Verify all required tools are installed
- Check version compatibility
- Validate project structure
- Generate comprehensive environment report
- Identify missing or misconfigured components

## Constraints
- Avoid destructive operations; scripts must check for pre-existing files before creating new ones
- Network access may require explicit authorization; prefer offline resources when possible
- All scripts must be idempotent (safe to run multiple times)
- Scripts must provide clear exit codes (0 = success, 1 = warnings/failures, 2 = critical)
- Documentation must be maintained for both AI agents and human users

## Documentation Standards

### Shell Scripts
- Header block with purpose, usage, exit codes, and instructions
- Inline comments for complex logic
- Structured logging (`[INFO]`, `[WARN]`, `[ERROR]`, `[OK]`, `[FAIL]`)
- Both AI agent and human user guidance

### Python Code
- Type hints for function signatures (PEP 484/585)
- NumPy-style docstrings for all public functions/classes
- PEP 8 compliance

### TypeScript/JavaScript
- TSDoc blocks for all exported APIs
- Type annotations throughout
- ESLint flat configuration compliance

## Project Conventions
- Idempotence: All automation must be safe to run repeatedly
- Validation: Run relevant validators before committing
- Memory Bank: Always update memory-bank files before ending session
- Documentation: Maintain comprehensive comments and documentation
- Testing: Verify changes work as expected before committing
