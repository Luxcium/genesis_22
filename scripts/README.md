# Scripts Overview

The scripts in this directory are safe to run repeatedly. Each script validates its preconditions before making changes and logs its actions so agents can trace what happened. All scripts are designed to be idempotent and can be executed multiple times without causing issues.

## Quick Reference

| Script | Purpose | When to Run |
|--------|---------|-------------|
| `init.sh` | Verify foundation files and initialize repository | After cloning or creating new project |
| `env-setup.sh` | Validate development environment and generate report | Start of each session or when debugging setup issues |
| `ensure-plans.sh` | Ensure canonical ExecPlan template exists and matches upstream | After cloning or when auditing memory-bank agents plans |
| `triad-health.sh` | Check memory-bank triad and VS Code settings | Before/after modifying memory-bank or settings |
| `validate-memory-bank.sh` | Validate instruction files | Before committing changes to instructions |
| `validate-chatmodes.sh` | Validate chatmode files | Before committing changes to chatmodes |
| `validate-prompts.sh` | Validate prompt files | Before committing changes to prompts |
| `list-slash-commands.sh` | List all available slash commands | When discovering available prompts |

## Detailed Script Documentation

### init.sh

**Purpose**: Verifies the presence of foundation files required for Genesis 22 projects and initializes a git repository if one doesn't exist.

**Usage**:
```bash
./scripts/init.sh
```

**What it does**:
1. Verifies presence of all foundation files (.editorconfig, .gitattributes, .gitignore, LICENSE, README.md, VERSION, scripts/README.md, scripts/init.sh)
2. Makes all shell scripts in scripts/ directory executable
3. Initializes git repository if .git/ directory doesn't exist
4. Logs execution timestamp for audit trail

**Exit codes**:
- `0` - Success (all foundation files present or created)
- `1` - Failure (critical files missing or git initialization failed)

**AI Agent Instructions**: Run this script when bootstrapping a new Genesis 22 project or verifying an existing one. This is typically the first script executed after cloning. Check the exit code and logged warnings to determine if manual intervention is needed for missing files.

**Human User Instructions**: Run this after cloning a Genesis 22 repository to ensure all foundation files are present and the environment is properly initialized. If any warnings appear, consult the layer-1 bootstrap instructions in the memory-bank/instructions/ directory.

---

### env-setup.sh

**Purpose**: Validates the development environment and provides a comprehensive report of all tools, versions, and configurations.

**Usage**:
```bash
./scripts/env-setup.sh [--verbose] [--report-only]
```

**Options**:
- `--verbose` - Show detailed output for all checks
- `--report-only` - Only generate report, don't attempt any fixes

**What it does**:
1. Validates Bash version (>= 4.0)
2. Checks Git installation and configuration
3. Validates Python 3 installation and version (>= 3.8)
4. Checks Node.js installation and version (>= 18)
5. Validates project structure (foundation files, memory-bank directories)
6. Checks shell scripts are executable
7. Validates Jupyter notebook environment (if notebooks/ exists)
8. Generates comprehensive environment report

**Exit codes**:
- `0` - All checks passed, environment is ready
- `1` - Some checks failed, see output for details
- `2` - Critical failure, environment cannot be validated

**Environment Variables**:
- `PYTHON_MIN_VERSION` - Minimum Python version (default: 3.8)
- `NODE_MIN_VERSION` - Minimum Node.js version (default: 18)

**AI Agent Instructions**: This script should be run at the start of any session to validate the environment. The output provides essential context about available tools and configurations. Always check the exit code to determine if the environment is ready for work.

**Human User Instructions**: Run this script after cloning the repository or when setting up a new development environment. It will check all required tools and provide specific guidance if anything is missing or misconfigured.

---

### ensure-plans.sh

**Purpose**: Guarantees that `memory-bank/agents/PLANS.md` exists and matches the upstream Genesis 22 template.

**Usage**:
```bash
./scripts/ensure-plans.sh [--show-diff]
```

**What it does**:
1. Checks for required utilities (`curl`, `diff`, `mktemp`).
2. Creates `memory-bank/agents/` when missing.
3. Downloads the canonical `PLANS.md` if no local copy exists.
4. Compares the local file against the upstream reference and reports drift.

**Options**:
- `--show-diff` - Display the unified diff when differences are detected.

**Exit codes**:
- `0` - Success (template installed or files match).
- `1` - Differences detected between local and upstream.
- `2` - Critical failure (missing dependency, download error, etc.).

**AI Agent Instructions**: Run this script after cloning or when verifying Memory Bank integrity. Treat a non-zero exit code as a cue to reconcile local changes with the upstream template before continuing work.

**Human User Instructions**: Use this script during audits to ensure the canonical ExecPlan template is present. If the script reports differences, review the output (optionally with `--show-diff`) and decide whether to update the local file.

---

### triad-health.sh

**Purpose**: Validates the health of the memory-bank "triad" structure (instructions, chatmodes, and prompts) and ensures VS Code settings are properly configured for GitHub Copilot integration.

**Usage**:
```bash
./scripts/triad-health.sh
```

**What it does**:
1. Runs validators for memory-bank, chatmodes, and prompts
2. Counts files in each triad directory
3. Validates .vscode/settings.json configuration for:
   - chat.instructionsFilesLocations
   - chat.promptFiles toggle
   - chat.promptFilesLocations
   - chat.modeFilesLocations

**Exit codes**:
- `0` - All health checks passed
- `1` - One or more health checks failed

**Dependencies**:
- validate-memory-bank.sh
- validate-chatmodes.sh
- validate-prompts.sh
- python3 (for JSON parsing)

**AI Agent Instructions**: Run this script to verify the memory-bank triad is properly configured and all validator scripts pass. If this fails, check the individual validator output and the VS Code settings.json configuration.

**Human User Instructions**: This script ensures your development environment is properly configured for GitHub Copilot's custom instructions feature. Run it after modifying any files in memory-bank/ or .vscode/settings.json.

---

### validate-memory-bank.sh

**Purpose**: Validates that all instruction files in memory-bank/instructions/ follow the required format and conventions.

**Usage**:
```bash
./scripts/validate-memory-bank.sh
```

**Validation Rules**:
1. All .instructions.md files must have a 'description:' front-matter header
2. External links (http://, https://, ftp://) are not allowed in most files
3. Exception: Layer files and specific allowed files can contain external links

**Allowed External Link Files**:
- layer-* (all layer instruction files)
- conventional-commits-must-be-used.instructions.md
- gitmoji-complete-list.instructions.md

**Exit codes**:
- `0` - All validations passed
- `1` - One or more validation errors found

**AI Agent Instructions**: Run this validator before committing changes to memory-bank/instructions/. All instruction files must be self-contained except for explicitly allowed external references. This ensures offline usability and reduces dependency on external resources.

**Human User Instructions**: If this validator fails, check the error messages for specific files and issues. Add a 'description:' header if missing, or remove external links unless the file is in the allowed list.

---

### validate-chatmodes.sh

**Purpose**: Validates that all chatmode files in memory-bank/chatmodes/ follow the required format, use approved models, and have correct tool configurations.

**Usage**:
```bash
./scripts/validate-chatmodes.sh
```

**Validation Rules**:
1. Must have 'description:' in front-matter
2. Must specify an allowed model (GPT-5 Preview or GPT-5 mini Preview)
3. Must have exactly the tools: ['codebase', 'editFiles', 'fetch']
4. Must have exactly one H1 heading
5. No external links allowed (http://, https://, ftp://)
6. All links must be relative paths

**Allowed Models**:
- GPT-5 (Preview)
- GPT-5 mini (Preview)

**Required Tools**:
- ['codebase', 'editFiles', 'fetch']

**Exit codes**:
- `0` - All validations passed
- `1` - One or more validation errors found

**AI Agent Instructions**: Run this validator before committing changes to memory-bank/chatmodes/. Chat modes must use approved models and tools to ensure consistent behavior across the development team. Never modify existing model or tools values without explicit user approval.

**Human User Instructions**: If this validator fails, check the specific error messages. Ensure your chatmode file uses an approved model and the exact tools list. All links must be relative (no external URLs).

---

### validate-prompts.sh

**Purpose**: Validates that all prompt files in memory-bank/prompts/ follow the required format and structure.

**Usage**:
```bash
./scripts/validate-prompts.sh
```

**Validation Rules**:
1. Must start with front-matter (---)
2. Front-matter must include 'description:' field
3. Only allowed keys: description, mode, model, tools
4. Must have blank line after front-matter
5. Must have path marker comment (`<!-- memory-bank/prompts/filename.md -->`)
6. Must have blank line after path marker
7. Must have H1 title immediately after marker block
8. Must have at least one "## Slash Command:" section
9. No external links allowed (http://, https://)

**Required Structure**:
```markdown
---
description: Brief description
---

<!-- memory-bank/prompts/example.prompt.md -->

# Prompt Title

## Slash Command: /example

[prompt content]
```

**Exit codes**:
- `0` - All validations passed
- `1` - One or more validation errors found

**AI Agent Instructions**: Run this validator before committing changes to memory-bank/prompts/. Prompt files must follow the exact structure to be properly recognized by GitHub Copilot. The Slash Command section is required for the prompt to be usable via keyboard shortcuts.

**Human User Instructions**: If this validator fails, check the error messages for specific structural issues. Ensure your prompt file has proper front-matter, path marker, and at least one Slash Command section.

---

### list-slash-commands.sh

**Purpose**: Lists all available slash commands defined in prompt files.

**Usage**:
```bash
./scripts/list-slash-commands.sh
```

**Output Format**:
```
filename:line_number:## Slash Command: /command-name
```

**Example Output**:
```
memory-bank/prompts/example.prompt.md:12:## Slash Command: /example
memory-bank/prompts/another.prompt.md:8:## Slash Command: /another
```

**Exit codes**:
- `0` - Successfully listed slash commands
- `1` - No prompt files found or error occurred

**AI Agent Instructions**: Run this script to discover available custom prompts. The output shows the filename, line number, and slash command name for each prompt. Use this information to learn what prompts are available for use.

**Human User Instructions**: Run this script to see all available slash commands. Each line shows where the command is defined and what its name is. You can then use these commands in GitHub Copilot chat by typing the slash command.

---

## Usage Guidelines

### For AI Agents

1. **Session Start**: Run `env-setup.sh` to validate the environment
2. **Before Commits**: Run relevant validators (`validate-*.sh`) for modified files
3. **Health Check**: Run `triad-health.sh` after modifying memory-bank or VS Code settings
4. **Discovery**: Use `list-slash-commands.sh` to learn available prompts
5. **Foundation Check**: Run `init.sh` when bootstrapping or verifying a project

### For Human Users

1. **Initial Setup**: Run `init.sh` after cloning
2. **Environment Check**: Run `env-setup.sh` when troubleshooting or setting up
3. **Pre-Commit**: Run validators before committing changes to memory-bank
4. **Learning**: Use `list-slash-commands.sh` to discover available prompts
5. **Regular Health Check**: Run `triad-health.sh` periodically to ensure configuration

## Conventions

### Script Requirements

- All shell scripts must be executable and should use `#!/usr/bin/env bash`
- Scripts must perform dry checks before mutating repository state
- Log outcomes using concise, structured messages (e.g., `[INFO]`, `[WARN]`, `[ERROR]`, `[OK]`, `[FAIL]`)
- Scripts should be idempotent (safe to run multiple times)
- Scripts should exit with appropriate exit codes (0 for success, non-zero for failure)

### Documentation Requirements

Each script must include:
- Header comment block with:
  - Purpose statement
  - Usage examples
  - Exit code documentation
  - What the script does (step-by-step)
  - AI agent instructions
  - Human user instructions
- Inline comments explaining complex logic
- Section headers using comment blocks

### Adding New Scripts

When adding a new script:

1. **Create the script** with proper header documentation
2. **Make it executable**: `chmod +x scripts/new-script.sh`
3. **Test thoroughly** to ensure idempotence
4. **Document in this README** by adding entry to the Quick Reference table and creating a detailed section
5. **Update relevant validators** if the script affects validated content
6. **Commit with descriptive message** explaining the script's purpose

### Maintenance Guidelines

- Keep scripts focused on single responsibilities
- Prefer shell scripts for simple validations and Python for complex parsing
- Use consistent logging formats across all scripts
- Update documentation when modifying script behavior
- Test scripts in clean environments to ensure portability

## Troubleshooting

### Common Issues

**Scripts not executable**
```bash
chmod +x scripts/*.sh
```

**Python not found**
```bash
# Check Python installation
which python3
python3 --version
```

**Validators failing**
```bash
# Run individual validator to see specific errors
./scripts/validate-memory-bank.sh
./scripts/validate-chatmodes.sh
./scripts/validate-prompts.sh
```

**Environment check failing**
```bash
# Run with verbose output to see details
./scripts/env-setup.sh --verbose
```

### Getting Help

1. Check script header documentation for usage and exit codes
2. Run scripts with `--verbose` flag (if supported) for detailed output
3. Review error messages and trace back to specific validation rules
4. Consult memory-bank/instructions/ for broader context
5. Check AGENTS.md for recent session context that might explain issues

## Related Documentation

- [Layer 1 Bootstrap Instructions](../memory-bank/instructions/layer-1-verify-and-bootstrap.instructions.md)
- [Layer 2 Development Environment](../memory-bank/instructions/layer-2-verify-and-bootstrap.instructions.md)
- [Memory Bank Protocol](../memory-bank/instructions/copilot-memory-bank.instructions.md)
- [Main Project README](../README.md)
- [Agent Activity Log](../AGENTS.md)
