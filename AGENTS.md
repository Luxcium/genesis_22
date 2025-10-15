# Codex CLI Agent Guide

This file defines how ANY AI AGENTS and Codex CLI operates if you are reading this you are an ai agent in this repository. It aligns with the Memory Bank protocol and complements `.github/copilot-instructions.md`.

> [!NOTE]
> Seek first into ['github copilot instructions'](./github/copilot-instructions.md) for more information on how we want the project to evolve to use GitHub Copilot with Agents, any behaviour or important information that you see fit for you to use shall be referenced, or included in this set of instructions below at the end. Instruction may be specifict to each agent, or if it is general, it shall be taken into account and referenced using relative links (markdown) or include the language here, in your own AGENTS.md autonomusly and never remove any of your own instructions be carefull when editing your AGENTS.md file yourself not remove, only add.

## Three AI Agent System or More

This project supports your ai agent and at least three AI agents with distinct entry points and responsibilities:

- **Codex CLI (YOU)** → `AGENTS.md` (THIS IS YOUR PRIMARY INSTRUCTION FILE)
- **Cline AI** → `.clinerules/main-rules.md` (Cline AI's primary instruction file)
- **VS Code Copilot** → `.github/copilot-instructions.md` (VS Code Copilot's primary instruction file)

## Core Principles (Subset from Memory Bank)

- Always read all files in `memory-bank/` at the start of a task.
- Plan before acting; document key decisions and assumptions.
- Write back results and decisions to the Memory Bank before concluding a task.
- Treat the Memory Bank as authoritative context. Never ignore it.

## Operating Constraints

- Package manager: `pnpm` (see `packageManager` field in package.json files)
- Node.js: >= 20.11
- No CI/CD automation added unless explicitly requested.
- No test scaffolding added unless requested (development-first flow).

## Monorepo Conventions

- Subprojects live under `services/`, `packages/`, `libraries/`.
- Prefer local, per-package configs when reasonable to reduce cross-project coupling.
- VS Code settings at the repo root enable Prettier + ESLint across subprojects.

## Editor & Tooling

- Formatting: Prettier (required config) with format-on-save.
- Linting: ESLint (flat config in new projects), run fixers on save.
- TypeScript: modern Node target, `src/` → `dist/`, source maps and declarations.
- Scripts: `dev`, `build`, `start`, `lint(:fix)`, `format(:check)`, `typecheck`.

## Standard Task Flow

1. Read Memory Bank files and the target subproject.
2. Outline planned changes; keep them minimal and focused.
3. Implement changes with clear, reviewable diffs.
4. Validate locally (typecheck, lint). Do not add CI.
5. Update Memory Bank (active context + progress) with what changed and why.

## Session-Sticky Preferences (Codex CLI)

- Be proactive: implement requested changes without pausing for confirmation.
- Optimize for developer speed: scripts and editor integration are first-class.
- Respect existing project structure and conventions.

## Dependency Management Protocol (CRITICAL)

**ABSOLUTE RULE: NEVER write dependency version numbers directly in package.json**

**CORRECT approach:**

1. Create package.json with empty `dependencies: {}` and `devDependencies: {}`
2. Install ALL dependencies via CLI commands ONLY:

```bash
# Production dependencies - use explicit version tags
pnpm add langchain@next @langchain/core@next zod@latest dotenv@latest
pnpm add @langchain/openai@next @langchain/anthropic@next

# Development dependencies - use @latest or specific tags
pnpm add -D typescript@latest tsx@latest eslint@latest
pnpm add -D prettier@latest vitest@latest rimraf@latest
pnpm add -D typescript-eslint@latest eslint-config-prettier@latest
pnpm add -D eslint-plugin-simple-import-sort@latest
pnpm add -D eslint-plugin-tsdoc@latest @types/node@latest
```

**FORBIDDEN:**

- ❌ Writing `"typescript": "^5.7.2"` in package.json
- ❌ Hallucinating version numbers from outdated training data
- ❌ Guessing version compatibility
- ❌ Using `pnpm install` without specific packages

**Rationale:**

- AI models have outdated version knowledge (training data cutoff)
- Package registries determine latest versions at install time
- Version tags (`@next`, `@latest`) ensure current releases
- Avoids version conflicts and deprecated packages

**When documenting dependencies:**

- Record WHY a dependency was chosen in `memory-bank/techContext.md`
- Note any version constraints or compatibility requirements
- Document installation commands for reproducibility

## Notes for Future Work

- If adding complex workflows, prefer documenting them in `memory-bank/` and referencing from subproject READMEs.
- When introducing new dependencies, record rationale in `memory-bank/techContext.md` or relevant docs.

Do not add or remove any modes and/or models in the .instructions.md .prompts.md files or .chatmode.md files in their front matter as this is not something you can validate you must avoid hallucinations those are risky never change, add a descriptions if it is missing but never remove or change any of the existing ones.

When you are asked to use a specific mode or model and you are codex/codex-cli you will use the model and mode you operate under already. you must never validate that it exists (or not) in the front matter of the .instructions.md .prompts.md files or .chatmode.md files before use.

## ExecPlans

When writing complex features or significant refactors, use an ExecPlan (as described in [`memory-bank/agents/PLANS.md`](../memory-bank/agents/PLANS.md)) from design to implementation.

## Activity Log

- 2025-10-15 — GitHub Copilot: Added `scripts/ensure-plans.sh` to enforce the canonical ExecPlan template and updated `scripts/README.md` accordingly. Memory Bank context refreshed to capture the new guardrail.
