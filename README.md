# Genesis 22 Project Template

## Overview
This repository provides the baseline artifacts required to bootstrap a new Genesis 22 project. It establishes shared conventions, automation entry points, and persistent memory so collaborators and AI agents can iterate consistently.

## Features
- Canonical repository scaffolding that is safe to re-run.
- Standardized editor, tooling, and documentation expectations.
- Memory-bank structure for durable AI instructions and prompts.
- Scripts for repeatable initialization and verification workflows.
- Comprehensive environment validation and health checking.

## Quick Start

### For New Users
1. Run `scripts/init.sh` to verify the foundation and initialize missing pieces.
2. Run `scripts/env-setup.sh` to validate your development environment.
3. Review the contents of `memory-bank/` to understand the layered instructions.
4. Update `AGENTS.md` with session context before beginning any significant changes.

### For AI Agents
1. **Session Start**: Run `scripts/env-setup.sh` to understand available tools and environment state.
2. **Check Health**: Run `scripts/triad-health.sh` to verify memory-bank configuration.
3. **Discover Prompts**: Use `scripts/list-slash-commands.sh` to learn available custom prompts.
4. **Before Commits**: Run relevant validators for any files you modify in memory-bank/.
5. **Update Context**: Always update memory-bank files before ending your session.

## Documentation

### Core Documentation
- `memory-bank/instructions/` contains layered bootstrap guides for agents.
- `memory-bank/prompts/` and `memory-bank/chatmodes/` will house reusable prompts and chat modes as they are created.
- `AGENTS.md` tracks agent sessions and context hand-offs.
- `scripts/README.md` provides comprehensive documentation for all automation scripts.

### For AI Agents: File Maintenance Instructions

#### Memory Bank Protocol
All AI agents working on this project must follow the Memory Bank protocol:

1. **Read First**: Read all memory-bank files at the start of every task
2. **Document Decisions**: Write to memory-bank each time you make a decision to be implemented
3. **Write Before End**: Update memory-bank just before completing any task
4. **State Preservation**: Ensure your state will not be lost if interrupted

#### Core Memory Bank Files (Always Update)
- `memory-bank/projectbrief.md` - Project overview and goals
- `memory-bank/productContext.md` - Product-related information
- `memory-bank/activeContext.md` - **MOST CRITICAL** - Current work focus, recent changes, next steps
- `memory-bank/systemPatterns.md` - Technical decisions and architecture
- `memory-bank/techContext.md` - Technologies, setup, constraints
- `memory-bank/progress.md` - What works, what's left, current status

#### Code Documentation Standards

**All code must include**:
- **Header comments** explaining purpose, usage, and intent
- **Inline comments** for complex logic or non-obvious decisions
- **Function/method documentation** with parameters, return values, and examples
- **TSDoc blocks** for all exported TypeScript APIs (parameters, returns, examples)
- **Docstrings** for all Python functions (NumPy style preferred)

**Comment Guidelines**:
- Write for both human readers and AI agents
- Explain the "why" not just the "what"
- Include usage examples where helpful
- Document assumptions and constraints
- Mark TODOs with clear descriptions and context

**Script Documentation** (in `scripts/`):
- Header block with purpose, usage, exit codes, and instructions
- Section headers using comment blocks
- Detailed inline comments for complex logic
- Both AI agent and human user instructions

#### File Creation and Modification Rules

**Before Creating Files**:
1. Check if the file already exists using view or file system commands
2. Verify it's needed and doesn't duplicate existing functionality
3. Ensure it follows project conventions and structure
4. Add appropriate .gitignore entries if it's a generated/build artifact

**When Modifying Files**:
1. Preserve existing code style and conventions
2. Add comments explaining your changes
3. Update related documentation
4. Run relevant validators before committing
5. Test your changes to ensure they work

**Idempotence Principle**:
- All scripts must be safe to run multiple times
- Check for existing state before making changes
- Never destructively overwrite without verification
- Log all actions for audit trail

#### Validation and Testing

**Before Committing Changes**:

| Changed Files | Run This Validator |
|---------------|-------------------|
| `memory-bank/instructions/*.instructions.md` | `scripts/validate-memory-bank.sh` |
| `memory-bank/chatmodes/*.chatmode.md` | `scripts/validate-chatmodes.sh` |
| `memory-bank/prompts/*.prompt.md` | `scripts/validate-prompts.sh` |
| Any memory-bank or VS Code settings | `scripts/triad-health.sh` |
| Any shell scripts | Test manually and verify idempotence |
| Python code | Run relevant tests and linters if available |
| TypeScript code | Run relevant tests and linters if available |

**Testing Standards**:
- Test scripts in clean environments when possible
- Verify idempotence (run twice, same result)
- Check exit codes and error handling
- Validate output format and messages
- Ensure backward compatibility

#### Session Workflow for AI Agents

**At Session Start**:
1. Run `scripts/env-setup.sh` to understand environment
2. Read all memory-bank core files to understand context
3. Check `AGENTS.md` for recent activity
4. Review `memory-bank/progress.md` for current status

**During Work**:
1. Update `memory-bank/activeContext.md` with decisions and changes
2. Run validators before committing modified files
3. Document complex decisions in relevant memory-bank files
4. Add comprehensive comments to all code changes

**Before Session End**:
1. Update all modified memory-bank files
2. Update `memory-bank/progress.md` with completion status
3. Update `AGENTS.md` with session summary
4. Run `scripts/triad-health.sh` to verify configuration
5. Commit all changes with descriptive messages

#### Common Patterns and Preferences

**TypeScript/JavaScript**:
- Use TypeScript-first development
- Add TSDoc blocks to all exported APIs
- Follow ESLint flat configuration
- Use Prettier via eslint-config-prettier (not eslint-plugin-prettier)
- Prefer Node.js 22+ features and syntax

**Python**:
- Target Python 3.8+ (3.12 for notebooks)
- Use type hints for function signatures
- Write NumPy-style docstrings
- Follow PEP 8 conventions
- Include docstrings for all public functions/classes

**Shell Scripts**:
- Use `#!/usr/bin/env bash` shebang
- Set `set -euo pipefail` for safety
- Include comprehensive header documentation
- Use structured logging (`[INFO]`, `[WARN]`, `[ERROR]`)
- Make scripts idempotent

**Documentation**:
- Use Markdown for all documentation
- Include examples where helpful
- Keep README files up to date
- Link to related documentation
- Write for both humans and AI agents

## Project Structure

```
genesis_22/
├── .github/              # GitHub configuration
│   └── copilot-instructions.md  # Copilot guardrails
├── .vscode/              # VS Code workspace settings
├── memory-bank/          # Durable memory and instructions
│   ├── instructions/     # Layered bootstrap guides
│   ├── chatmodes/        # Custom chat modes
│   ├── prompts/          # Reusable prompt cards
│   ├── projectbrief.md   # Project overview
│   ├── activeContext.md  # Current work focus
│   ├── progress.md       # Status tracking
│   └── ...               # Other context files
├── notebooks/            # Jupyter notebook templates
│   ├── canonical-template.ipynb
│   ├── requirements.txt
│   └── README.md
├── scripts/              # Automation and validation
│   ├── init.sh           # Foundation verification
│   ├── env-setup.sh      # Environment validation
│   ├── triad-health.sh   # Memory-bank health check
│   ├── validate-*.sh     # Format validators
│   └── README.md         # Comprehensive script docs
├── AGENTS.md             # Multi-agent activity log
├── README.md             # This file
└── VERSION               # Project version
```

## Environment Setup

### Required Tools
- **Git** - Version control (any recent version)
- **Python 3.8+** - For scripts and notebooks (3.12 recommended)
- **Bash 4.0+** - For shell scripts

### Optional Tools
- **Node.js 18+** - For TypeScript/JavaScript projects
- **Jupyter** - For notebook work (install via `pip install -r notebooks/requirements.txt`)

### Verification
Run the environment validation script to check your setup:
```bash
./scripts/env-setup.sh --verbose
```

This will verify all tools, versions, and configurations, then generate a comprehensive report.

## Contributing

### For Humans
Pull requests should maintain idempotent scripts and respect the layered instruction model. Document decisions and update `memory-bank/progress.md` as milestones advance.

**Guidelines**:
1. Run validators before committing
2. Update relevant documentation
3. Add tests for new functionality
4. Follow existing code style
5. Write clear commit messages

### For AI Agents
Follow the Memory Bank protocol and file maintenance instructions above. Always:
1. Read memory-bank files at session start
2. Document all decisions
3. Update memory-bank before ending session
4. Run validators before committing
5. Maintain code comments and documentation

## Scripts Reference

See [scripts/README.md](scripts/README.md) for comprehensive documentation of all automation scripts.

**Quick Commands**:
```bash
# Verify foundation files
./scripts/init.sh

# Check environment setup
./scripts/env-setup.sh

# Validate memory-bank health
./scripts/triad-health.sh

# List available slash commands
./scripts/list-slash-commands.sh

# Validate specific file types
./scripts/validate-memory-bank.sh
./scripts/validate-chatmodes.sh
./scripts/validate-prompts.sh
```

## Troubleshooting

### Scripts Not Executable
```bash
chmod +x scripts/*.sh
```

### Environment Check Fails
```bash
./scripts/env-setup.sh --verbose
```
Review the detailed output to identify missing or misconfigured tools.

### Validator Failures
Run the specific validator to see detailed error messages:
```bash
./scripts/validate-memory-bank.sh
```

### Memory Bank Out of Sync
Re-read all memory-bank core files and update `activeContext.md` with current state.

## License
This project is licensed under the MIT License. See `LICENSE` for details.

## Support
- Open an issue in the repository for bugs or feature requests
- Document blockers in `memory-bank/progress.md` to surface needs
- Check `AGENTS.md` for recent session context
- Review `memory-bank/instructions/` for detailed guidance

## Acknowledgments
This template builds on the Genesis layered bootstrap process and the Vigilant Codex project foundations.
