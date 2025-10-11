---
description: Guardrails for GitHub Copilot interactions in the Genesis 22 workspace.
---

# Copilot Guardrails

- Prioritize TypeScript solutions and ensure exported APIs include TSDoc blocks describing purpose, parameters, and return values.
- Assume Node.js 22 or [seek for the Active LTS version](https://nodejs.org/en/about/releases/) update the documentation when you detect next version lts, it is mandatory to update teh information now if it is outdated or if it is not we have that version, later for runtime behaviors, syntax, and library availability; avoid features outside that baseline.
- Follow the repository's ESLint flat configuration and treat all autofixable rules as warnings; integrate Prettier via `eslint-config-prettier` and never run `eslint-plugin-prettier`.
- Consider files in `memory-bank/` as the authoritative context. Reference the layered instructions before proposing structural changes or automation.
- When generating prompts or chat modes, reuse existing instructions instead of duplicating guidance; link to `memory-bank/instructions/` entries.
- Confirm new files respect the idempotent bootstrap philosophy—verify before creating or mutating repository state.

## Usage Guidance

- Log entries in reverse chronological order (newest at top of its section).
- Capture what changed, why it matters, and what remains.
- Reference related `memory-bank/*` updates or commits where helpful.
- The `web/` directory is the Next.js app workspace, avoid confusion.
- Ensure you are in the proper folder of project `<root>` and web/`<root>` are not in a same folder.

## Collaboration Expectations

- Summarize assumptions and highlight open questions so humans can respond quickly.
- If a task depends on information outside the repository, call it out explicitly and request confirmation before proceeding.

## 🤖 Known Limitations

- In any `.prompt.md` or `.chatmode.md` file, the `tools:` front-matter key **must** have its value on the same line (e.g. `tools: [ ... ]`).
  Splitting the array onto the next line currently breaks VS Code's parser and Copilot's tool-detection logic.

## CRITICAL MEMORY BANK PROTOCOL (keeping it stateful, ingesting previous context)

**IMPERATIVE REQUIREMENT**: NOW MUST synchronize memory bank AND on EVERY task execution:

1. **READ FIRST**: Read ALL memory bank files at start of EVERY task (not optional)
2. **DOCUMENT DECISIONS**: Write to memory bank each time I make a decision to be implemented
3. **WRITE BEFORE END**: Update memory bank just before completing any task
4. **STATE PRESERVATION**: Ensure my state will not be lost if interrupted

### Multi-Agent Coordination

GitHub Copilot is one of **three AI agents** working on this project:

1. **Cline** - Task execution, file operations, command execution (see [`.clinerules`](../.clinerules))
2. **GitHub Copilot** (me) - Code completion, inline assistance (THIS FILE)
3. **Codex/Codex-CLI** - Autonomous agent workflows (see [`AGENTS.md`](../AGENTS.md))

**Cross-Agent References**:

- **Cline's Rules**: [`.clinerules`](../.clinerules) - Cline's operational blueprint
- **Copilot's Rules**: `.github/copilot-instructions.md` (this file) - My operational blueprint
- **Agent Activity Log**: [`AGENTS.md`](../AGENTS.md) - Cross-agent session tracking
- **Core Protocol**: [`memory-bank/instructions/copilot-memory-bank.instructions.md`](../memory-bank/instructions/copilot-memory-bank.instructions.md) - Universal Memory Bank protocol

All three agents follow the same Memory Bank protocol but have agent-specific configuration files.

### Core Files (Required)

Before to mark a task as completed you MUST imperatively update memory bank files with current state of task, including any changes made, decisions taken, and dependencies updated. why and thought process behind to be kept in mind for future reference.

> [!IMPORTANT] 
> [ImperatAive Instructions Git Hub Copilot MUST ALWAYS Follow](../memory-bank/instructions/copilot-memory-bank.instructions.md):

- 'memory-bank/projectbrief.md'
- 'memory-bank/productContext.md'
- 'memory-bank/activeContext.md'
- 'memory-bank/systemPatterns.md'
- 'memory-bank/techContext.md'
- 'memory-bank/dependencies.md'
- 'memory-bank/progress.md'

> [!WARNING]
> You must also remember to write at end, just before you mention task is completed, then look for any problems resolving each before to write to the memory bank again if any issues are found, after resolving them or if no resolution is found explain the resolutions attempts, so the next session knows where we are at.

### Additional Memory Bank And Similar Context Files

  > [!CAUTION]
  > - [`AGENTS.md`](../AGENTS.md) (Multi-agent activity entry instructions and log for Cline, Copilot, and Codex)
  > You must also remember to write at end, just before you mention task is completed, then look for any problems resolving each before to write to the memory bank again if any issues are found, after resolving them or if no resolution is found explain the resolutions attempts, so the next session knows where we are at.  
 > - [`.clinerules`](../.clinerules) (Cline's operational rules) This file is the operational blueprint for Cline, the autonomous task execution agent. Cline uses this file to understand its capabilities, and learn from the user preferences and constraints, references protocols for interacting with the system and other agents  
 > - [`.github/copilot-instructions.md`](../.github/copilot-instructions.md) (THIS FILE - Copilot rules) This file is the operational blueprint for GitHub Copilot, the AI code completion agent. Copilot uses this file to understand its capabilities, and learn from the user preferences and constraints, references protocols for interacting with the system and other agents
 > - [`memory-bank/chatmodes/*.chatmode.md`](../memory-bank/chatmodes/)  
 > - [`memory-bank/instructions/*.instructions.md`](../memory-bank/instructions/)  
 > - [`memory-bank/prompts/*.prompts.md`](../memory-bank/prompts/)  

## Radical Documentation Changes: Migration into Memory Bank [2025-07-27]

All 3 instructions like folders, `instructions/`, `prompts/`, and `chatmodes/` have been migrated from `.github/` into the `memory-bank/` directory. The Copilot entry point remains `.github/copilot-instructions.md` for compatibility with official VS Code tooling. This change is motivated by the need for an organised, stateful, and agent-friendly directives system. Centralising instructions, prompts, and chatmodes in the memory bank enables better context preservation, easier maintenance, and improved collaboration between AI agents and human contributors. All references and explanatory notes have been updated across the codebase to reflect this change. Future changes must follow this structure and maintain clarity for all contributors and agents.

Before to mark a task as completed you MUST imperatively update memory bank files with current state of task, including any changes made, decisions taken, and dependencies updated. why and thought process behind to be kept in mind for future reference.

## CRITICAL MEMORY BANK PROTOCOL (keep context stateful for future reference)

- [`memory-bank/chatmodes/*.chatmode.md`](../memory-bank/chatmodes/)
- [`memory-bank/instructions/*.instructions.md`](../memory-bank/instructions/)
- [`memory-bank/prompts/*.prompts.md`](../memory-bank/prompts/)
- [`.github/copilot-instructions.md`](../.github/copilot-instructions.md) (THIS FILE)
- [`AGENTS.md`](../AGENTS.md) (for Codex and Codex CLI)

---

<!-- AUTONOMUS AND AGENTIC SELF INSTRUCTION WRITTEN BY COPILOT AI AGENT MUST BE SET  BELOW THIS LINE -->

## IMPORTANT BEHAVIOURS' PREFERENCES AND NOTABLE EXCEPTIONS

THIS SECTION IS FOR AUTONOMUS AND AGENTIC SELF INSTRUCTION WRITTEN BY COPILOT AI AGENT MUST BE SET IN SUBSECTION BELOW THIS STATEMENT

### Persistence [2025-08-11T15:49:56-04:00]

- You are an agent - please keep going until the user's query is completely resolved, before ending your turn and yielding back to the user.
- Only terminate your turn when you are sure that the problem is solved.
- Never stop or hand back to the user when you encounter uncertainty — research or deduce the most reasonable approach and continue.
- Do not ask the human to confirm or clarify assumptions, as you can always adjust later — decide what the most reasonable assumption is, proceed with it, and document it for the user's reference after you finish acting
