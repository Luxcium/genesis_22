---
description: Markdown linting rules and standards for Genesis 22 project files
---

# Markdown Linting Rules

This document defines the markdown linting rules and standards that all AI agents must follow when creating or editing markdown files in the Genesis 22 project.

## Core Principles

1. **Consistency**: All markdown files should follow the same formatting conventions
2. **Readability**: Markdown should be clear and easy to read in both raw and rendered forms
3. **Validation**: All markdown files must pass automated validation before commits
4. **AI Agent Compliance**: AI agents must output properly linted markdown without manual intervention

## Linting Rules

### Structure Rules

#### MD001 - Heading Levels
- Headings should increment by one level at a time
- Never skip heading levels (e.g., don't go from H1 to H3)
- Example:
  ```markdown
  # H1
  ## H2
  ### H3
  ```

#### MD002 - First Heading
- First heading should be a top-level heading (H1)
- Files with front-matter are exempt from this rule

#### MD003 - Heading Style
- Use ATX-style headings (with `#` symbols)
- Consistent heading style throughout the document
- Example: `# Heading` not `Heading\n=======`

#### MD004 - List Style
- Use consistent marker style for unordered lists
- Prefer `-` (dash) for bullet points
- Example:
  ```markdown
  - Item 1
  - Item 2
  - Item 3
  ```

#### MD005 - List Indentation
- Lists should be properly indented
- Use 2 spaces for nested list items

### Content Rules

#### MD009 - No Trailing Spaces
- Remove trailing spaces from end of lines
- Exception: Two spaces for hard line breaks

#### MD010 - No Hard Tabs
- Use spaces instead of tabs
- Tabs can cause rendering issues in different environments

#### MD011 - No Reversed Links
- Link syntax should be `[text](url)` not `(url)[text]`

#### MD012 - No Multiple Blank Lines
- Maximum one consecutive blank line
- Reduces unnecessary whitespace

#### MD013 - Line Length
- Recommended maximum: 120 characters
- Long lines can be harder to review in diffs
- Exceptions: URLs, tables, code blocks

### Link Rules

#### MD034 - No Bare URLs
- Use proper link syntax: `[text](url)`
- Don't use bare URLs like `http://example.com`

#### MD039 - No Space in Link Text
- Link text should not have spaces at start/end
- Example: `[text](url)` not `[ text ](url)`

#### MD042 - No Empty Links
- All links must have non-empty URLs
- Example: `[text](url)` not `[text]()`

### Code Rules

#### MD031 - Fenced Code Blocks Surrounded by Blank Lines
- Code blocks should have blank lines before and after
- Improves readability

#### MD040 - Fenced Code Language
- Always specify language for code blocks
- Example:
  ````markdown
  ```bash
  echo "Hello"
  ```
  ````

### Formatting Rules

#### MD018 - No Missing Space After Hash
- Space required after hash in headings
- Example: `# Heading` not `#Heading`

#### MD019 - No Multiple Spaces After Hash
- Only one space after hash in headings
- Example: `# Heading` not `#  Heading`

#### MD022 - Headings Surrounded by Blank Lines
- Blank lines before and after headings
- Improves document structure

#### MD023 - Headings Must Start at Beginning of Line
- No indentation before heading markers

#### MD026 - No Trailing Punctuation in Headings
- Headings should not end with punctuation (`.`, `,`, `;`, `:`)
- Question marks (`?`) and exclamation marks (`!`) are allowed

### List Rules

#### MD029 - Ordered List Item Prefix
- Use `1.` for all items (auto-numbering)
- Or use sequential numbering `1.`, `2.`, `3.`
- Stay consistent within the document

#### MD030 - Spaces After List Markers
- Exactly one space after list marker
- Example: `- Item` not `-  Item`

### Emphasis Rules

#### MD036 - No Emphasis Instead of Heading
- Don't use emphasis (bold/italic) instead of proper headings
- Example: Use `## Heading` not `**Heading**`

#### MD037 - No Spaces Inside Emphasis Markers
- Example: `**bold**` not `** bold **`

## Special Rules for Genesis 22

### Front-Matter Rules

1. All instruction, prompt, and chatmode files must start with front-matter
2. Front-matter must be valid YAML between `---` markers
3. Required fields:
   - `description:` - Brief description of the file's purpose

### Path Marker Rules (Prompts)

1. Prompt files must include path marker after front-matter
2. Format: `<!-- memory-bank/prompts/filename.md -->`
3. Must have blank line after marker

### External Links

1. **Memory Bank Instructions**: No external links allowed (except layer files and specific exceptions)
2. **Chatmodes**: No external links allowed
3. **Prompts**: No external links allowed
4. **Allowed Exceptions**:
   - `layer-*.instructions.md` files
   - `conventional-commits-must-be-used.instructions.md`
   - `gitmoji-complete-list.instructions.md`

### Heading Rules

1. **Chatmodes**: Must have exactly one H1 heading
2. **Prompts**: Must have H1 title immediately after path marker

## Common Typos to Avoid

AI agents should be aware of and avoid these common typos:

1. "alwas" → "always"
2. "alredy" → "already"
3. "ouutput" → "output"
4. "uare" → "are"
5. "puurposful" → "purposeful"
6. "anumerate" → "enumerate"
7. "beggining" → "beginning"
8. "occured" → "occurred"
9. "recieve" → "receive"
10. "seperate" → "separate"

## AI Agent Instructions

### When Creating Markdown Files

1. Start with proper front-matter (if required)
2. Use consistent heading hierarchy
3. Apply all formatting rules automatically
4. Run spell check on content
5. Validate against project-specific rules
6. Never commit markdown files with known linting errors

### When Editing Markdown Files

1. Preserve existing formatting style
2. Fix any linting errors encountered
3. Don't introduce new linting violations
4. Update content while maintaining structure
5. Validate changes before committing

### Validation Workflow

1. **Before Creating**: Review linting rules
2. **During Creation**: Apply rules as you write
3. **Before Committing**: Run validation script
4. **After Validation Fails**: Fix all errors
5. **Repeat**: Validate again until all checks pass

## Markdown Linting Script

The project includes a validation script at `scripts/validate-markdown.sh` that checks all these rules. Run it before committing:

```bash
./scripts/validate-markdown.sh
```

## Tools and Automation

### Recommended Tools

1. **markdownlint-cli**: Command-line interface for markdown linting
2. **markdownlint**: Node.js library for markdown validation
3. **VS Code Extensions**:
   - markdownlint extension for real-time validation
   - Markdown All in One for formatting assistance

### Installation (Optional)

For local development, markdown linting tools can be installed:

```bash
# Using npm (if available)
npm install -g markdownlint-cli

# Or using system package manager
# Ubuntu/Debian
sudo apt-get install ruby-mdl

# macOS
brew install markdownlint-cli
```

Note: The validation script is designed to work without external dependencies by implementing basic checks in shell script.

## Configuration

Markdown linting configuration follows these principles:

1. **Strictness**: Enforce rules consistently
2. **Practicality**: Allow reasonable exceptions
3. **Compatibility**: Work with existing tools
4. **Maintainability**: Easy to understand and update

## Related Documentation

- [Memory Bank Protocol](./copilot-memory-bank.instructions.md)
- [Layer 1 Bootstrap](./layer-1-verify-and-bootstrap.instructions.md)
- [Layer 2 Verification](./layer-2-verify-and-bootstrap.instructions.md)
- [Validation Scripts](../../scripts/README.md)

## References

- [Markdownlint Rules](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)
- [Markdown Guide](https://www.markdownguide.org/)
- [CommonMark Spec](https://spec.commonmark.org/)
