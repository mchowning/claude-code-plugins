# Claude Code Plugins Marketplace

This repository is a marketplace for Claude Code plugins. It currently contains the **Workflow Tools** plugin for codebase research, planning, implementation, and documentation.

## Workflow Tools Plugin

The Workflow Tools plugin provides four commands that work together with specialized research agents. The full flow is

1. `/research-codebase`
2. `/create-plan`
3. `/implement-plan`
4. `/summarize-work`

## Features

### Commands

#### 1. `/research-codebase`

Conduct comprehensive research across the codebase and the internet using parallel sub-agents.

**What it does:**

- Spawns multiple specialized agents to research different aspects concurrently
- Locates relevant files and components across the codebase
- Analyzes how code works with precise file:line references
- Searches for similar implementations and patterns
- Discovers relevant notes and documentation
- Fetches external resources and Jira context
- Generates timestamped research documents with YAML frontmatter

**Output:** Research document in `WORKING_NOTES_DIR/{date}_research_{topic}.md`

#### 2. `/create-plan`

Create detailed implementation plans through an interactive, iterative process.

**What it does:**

- Reads any provided files for context
- Spawns research tasks to gather implementation details
- Presents design options and gathers user feedback iteratively
- Creates comprehensive implementation plans with success criteria
- Writes detailed plans to `WORKING_NOTES_DIR` for later execution

**Output:** Plan document in `WORKING_NOTES_DIR/{date}_plan_{topic}.md`

#### 3. `/implement-plan`

Follow an approved plan with strict TDD practices and progress tracking.

**What it does:**

- Follows plans from `WORKING_NOTES_DIR` step-by-step
- Enforces Test-Driven Development (red-green-refactor cycle)
- Tracks progress with checkmarks directly in the plan document
- Handles implementation phase-by-phase
- Verifies success criteria are met

**Usage:**

```bash
/implement-plan @path/to/plan.md
```

**Note:** Requires an existing plan document created by `/create-plan`.

#### 4. `/summarize-work`

Generate comprehensive implementation summaries documenting what changed and why.

**What it does:**

- Checks for uncommitted code changes
- Analyzes git diffs across commits
- Gathers git metadata and commit information
- Fetches Jira details if applicable
- Creates standalone implementation summaries with GitHub permalinks

**Output:** Summary document in `NOTES_DIR/{date}_{topic}.md`

### Specialized Agents

The plugin includes seven specialized agents that are automatically invoked by the slash commands:

1. **codebase-locator** - Finds WHERE files, directories, and components live by topic/feature
2. **codebase-analyzer** - Analyzes HOW code works with precise file:line references and data flow
3. **codebase-pattern-finder** - Locates similar implementations and usage patterns as templates
4. **notes-locator** - Discovers relevant notes/documents in `WORKING_NOTES_DIR` and `NOTES_DIR`
5. **notes-analyzer** - Analyzes notes documents and extracts insights
6. **web-search-researcher** - Conducts web research for external documentation and resources
7. **jira-searcher** - Searches Jira for issues and historical context using JQL queries

## Installation

### Prerequisites

The plugin requires these external tools to be installed:

- `git` - Version control
- `gh` - GitHub CLI (for GitHub permalinks and repo information)
- `acli` - Atlassian CLI (optional, required for Jira integration via jira-searcher agent)

### Installation from GitHub

1. **Add the plugin marketplace:**

   ```bash
   /plugin marketplace add mchowning/claude-code-plugins
   ```

2. **Install the plugin:**

   ```bash
   /plugin install workflow-tools
   ```

3. **Restart Claude Code** to load the plugin

### Project-Level Auto-Install

To automatically install the plugin, add to `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "mchowning-marketplace": {
      "source": {
        "source": "github",
        "repo": "mchowning/claude-code-plugins"
      }
    }
  },
  "enabledPlugins": ["workflow-tools@mchowning-marketplace"]
}
```

Team members will auto-install the plugin when they trust the repository.

### Local Development

For local plugin development:

1. **Add your local marketplace directory:**

   ```bash
   /plugin marketplace add /path/to/claude-code-plugins
   ```

2. **Install the plugin:**

   ```bash
   /plugin install workflow-tools
   ```

3. **Restart Claude Code** to load the plugin

## Configuration

### Directory Variables

The plugin automatically defines the following directory variables with sensible defaults:

- `WORKING_NOTES_DIR`: `working-notes/` - Temporary research documents and plans (not committed to git)
- `NOTES_DIR`: `notes/` - Implementation summaries and permanent documentation (committed to git)

**No manual configuration is required** - the plugin's CLAUDE.md defines these automatically.

**Customization notes:**

- `WORKING_NOTES_DIR` can be overridden in your personal `.claude/settings.json` if you prefer a different location for temporary research files
- `NOTES_DIR` should **not** be overridden in shared repositories - all team members should commit documentation to the same directory to build a unified knowledge base

**Recommended:** Add `working-notes/` to your `.gitignore` file since these are temporary research and planning documents. The `notes/` directory should be committed to git as permanent documentation.

## Workflow Example

Here's a typical workflow using all four commands:

1. **Research the codebase** to understand how a feature works:

   ```bash
   /research-codebase How does user authentication work in this codebase?
   ```

2. **Create an implementation plan** based on research:

   ```bash
   /create-plan Improve auth by [...]. Look at @working-notes/2025-01-15_research_authentication-setup.md
   ```

3. **Implement the plan** with TDD:

   ```bash
   /implement-plan @working-notes/2025-01-15_plan_auth-improvements.md
   ```

4. **Summarize the work** for documentation:
   ```bash
   /summarize-work
   ```

## Usage Philosophy & Best Practices

### Philosophy & Core Principles

I get the most out of this plugin by:

- **Working slowly and deliberately** - Let Claude take time to think through problems rather than rushing to implementation
- **Managing context carefully** - Clear Claude's context frequently to maintain performance and clarity
- **Questioning unexpected behavior** - When Claude does something that seems unusual, ask "why did you do X?" This often leads Claude to discover better approaches even when its original approach wasn't wrong

### Context Management Strategy

One of the key benefits of this file-based workflow is the ability to clear Claude's context between phases:

- **Clear between major phases** - After completing research, clear context before planning. After planning, clear before implementation.
- **Clear during long phases** - If a phase is taking a long time or producing extensive discussion, clear context and restart with just the relevant documents
- **Why this matters** - Fresh context helps Claude focus on what's most relevant and prevents performance degradation from overly long conversations
- **File-based workflow enables this** - Because research, plans, and progress are all written to files, you can safely clear context and have Claude pick up where it left off

### Review Process & Priorities

Not all review effort is equal. I try to focus my attention where it matters most:

**Early-stage reviews are critical** - Mistakes in research or planning compound into bigger problems later:

- If research misunderstands the system, the plan will be wrong
- If the plan is misguided, the implementation will be wrong
- If implementation is wrong but research and plan were right, fixes are usually straightforward

**Review priorities:**

1. **Research documents** (highest priority) - Verify understanding of the problem and codebase is correct
2. **Implementation plans** - Ensure the approach is sound before writing code
3. **Tests** - If tests verify the right behavior, implementation is more likely correct
4. **Implementation code** (lowest priority) - If earlier stages were right, implementation issues are usually minor

This prioritization may feel counterintuitive since you naturally want to skim pretty markdown documents and focus on code, but investing review effort early prevents compounding mistakes.

### Building Project Context with Summaries

The `/summarize-work` command creates committed documentation that builds institutional knowledge:

- **NOTES_DIR summaries are committed** - Unlike temporary research in WORKING_NOTES_DIR, summaries in NOTES_DIR are permanent project documentation
- **Searchable by future developers and agents** - When working on related features later, you or Claude can search these summaries to understand WHY decisions were made
- **Builds institutional knowledge** - Over time, you accumulate a searchable history of implementation decisions, technical trade-offs, and architectural patterns
- **Complements code and tests** - While code shows WHAT and tests show BEHAVIOR, summaries explain WHY and document the thinking behind changes

Think of work summaries as first-class project documentation, not just an optional final step.

### When to Use This Workflow

The full 4-command workflow is powerful but not always necessary:

**Use the full workflow for:**

- Complex features requiring deep codebase understanding
- Changes touching unfamiliar areas of the codebase
- Features with multiple viable implementation approaches
- Work requiring coordination across multiple systems/components

**Skip research when:**

- You already understand the relevant codebase areas well
- The change is localized to code you recently worked on
- The feature is straightforward with an obvious implementation

**Skip planning when:**

- The task is simple with a clear, single approach
- You're making minor tweaks or bug fixes
- The change is very small in scope

**Jump straight to implementation for:**

- Trivial changes (typo fixes, simple refactoring)
- Well-understood, repetitive tasks
- Changes that don't require architectural decisions

**Rule of thumb:** If you find yourself uncertain about how to approach a task, step back and use `/research-codebase` or `/create-plan` before continuing.

### Limitations & Trade-offs

This plugin represents one approach to working with Claude, not the only approach:

- **Can be overkill** - For simple tasks, this structured workflow adds overhead that may not be worth it
- **Requires discipline** - The workflow works best when you actually review each phase carefully and clear context appropriately
- **Not always faster** - The emphasis on research and planning means you move slower initially, but ideally avoid costly mistakes later
- **Works for some personalities** - This approach fits those who enjoy refactoring and reviewing more than initial implementation; others may prefer different workflows

The goal is not to use this workflow for everything, but to have it available when tackling complex problems that benefit from structured research, planning, and documentation.

## Command Details

### Research Documents

Research documents include:

- YAML frontmatter with metadata (date, git commit, branch, repository)
- Research question and high-level summary
- Detailed findings organized by component/area
- Code references with file:line notation
- Architecture insights and patterns discovered
- Historical context from notes and Jira
- Related research documents
- Open questions for further investigation

### Plan Documents

Plan documents include:

- YAML frontmatter with metadata
- Problem statement and context
- Design options considered
- Detailed implementation steps with checkboxes for progress tracking
- Testing strategy
- Success criteria
- Rollback plan

### Summary Documents

Summary documents include:

- YAML frontmatter with metadata
- High-level overview of changes
- Technical details explaining WHY changes were made
- Git references with full commit messages
- GitHub permalinks to specific code changes
- Testing and verification approach

## Helper Scripts

The plugin includes a helper script bundled in the `scripts/` directory:

- **claude-md-frontmatter.sh** - Generates YAML frontmatter with git metadata

This script is automatically referenced using `${CLAUDE_PLUGIN_ROOT}/scripts/` path substitution.

## Best Practices

1. **Start with research** - Use `/research-codebase` to understand before making changes
2. **Plan before implementing** - Use `/create-plan` to think through the approach
3. **Follow TDD strictly** - The `/implement-plan` command strongly encourages red-green-refactor
4. **Document your work** - Use `/summarize-work` to create searchable implementation records
5. **Iterate on plans** - The planning process is interactive; provide feedback and refine
6. **Keep documents updated** - Research and plans can and should be updated with follow-up information. This does not happen automatically so when there is a change in direction, it's a good idea to prompt claude to update the research and plan docs.

## Development

### Repository Structure

```
claude-code-plugins/          # Marketplace root
├── .claude-plugin/
│   └── marketplace.json      # Marketplace manifest
└── workflow-tools/           # Plugin directory
    ├── .claude-plugin/
    │   └── plugin.json       # Plugin manifest
    ├── commands/             # Slash commands
    │   ├── research-codebase.md
    │   ├── create-plan.md
    │   ├── implement-plan.md
    │   └── summarize-work.md
    ├── agents/               # Specialized agents
    │   ├── codebase-locator.md
    │   ├── codebase-analyzer.md
    │   ├── codebase-pattern-finder.md
    │   ├── notes-locator.md
    │   ├── notes-analyzer.md
    │   ├── web-search-researcher.md
    │   └── jira-searcher.md
    ├── scripts/              # Helper scripts
    │   └── claude-md-frontmatter.sh
    └── CLAUDE.md
```

## Acknowledgments

This plugin takes significant inspiration from the Human Layer team's excellent Claude Code setup, particularly their approach to structured workflow commands and research agents. Check out their setup at [humanlayer/humanlayer/.claude/commands](https://github.com/humanlayer/humanlayer/tree/main/.claude).

## License

MIT

## Version

1.0.0
