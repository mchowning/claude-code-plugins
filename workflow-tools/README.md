# workflow-tools Plugin

A comprehensive Claude Code plugin for structured software development workflows, including research, planning, implementation, and documentation.

## Features

- **Research documentation** - Conduct comprehensive codebase analysis using parallel sub-agents
- **Technical planning** - Create detailed implementation plans through iterative process
- **TDD implementation** - Follow approved plans with test-driven development and progress tracking
- **Work summaries** - Generate comprehensive documentation of what was changed and why

## Installation

1. Install the plugin through Claude Code's plugin system
2. Add required permissions to your `claude_settings.json`

### Required Permissions

Add the following to your `permissions.allow` array in `~/.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(*/workflow-tools-frontmatter.sh)"
    ]
  }
}
```

This allows the frontmatter-generator agent to collect git metadata without permission prompts.

**Note:** If the wildcard pattern doesn't work in your Claude Code version, use the full path:

```json
"Bash(/full/path/to/claude-code-plugins/workflow-tools/scripts/workflow-tools-frontmatter.sh)"
```

## Commands

The plugin provides four workflow commands:

### `/create-research-doc`
Conduct comprehensive research across the codebase using parallel sub-agents to explore implementation details, patterns, and architecture.

### `/create-plan-doc`
Create detailed implementation plans through an interactive, iterative process. Produces technical specifications ready for execution.

### `/implement-plan`
Follow an approved technical plan with TDD methodology and automatic progress tracking.

### `/create-work-summary-doc`
Generate comprehensive implementation summaries documenting what was changed and why.

## Specialized Agents

The plugin includes eight specialized agents automatically invoked by commands:

- **codebase-locator** - Finds WHERE files, directories, and components live
- **codebase-analyzer** - Analyzes HOW code works with precise file:line references
- **codebase-pattern-finder** - Locates similar implementations and usage patterns
- **notes-locator** - Discovers relevant notes/documents in `working-notes/`
- **notes-analyzer** - Deeply analyzes notes documents and extracts insights
- **web-search-researcher** - Conducts web research for external documentation
- **jira-searcher** - Searches Jira for issues and business context
- **git-history** - Searches git history, PRs, and PR comments for implementation context
- **frontmatter-generator** - Collects git metadata for documentation templates

## Helper Scripts

The plugin includes helper scripts bundled in the `scripts/` directory:

- **workflow-tools-frontmatter.sh** - Generates YAML frontmatter with git metadata (date/time, commit, branch, repository)

Scripts are automatically referenced using `${CLAUDE_PLUGIN_ROOT}/scripts/` path substitution.

## Documentation Structure

The plugin creates two types of documentation:

### Working Notes (`working-notes/`)
- Temporary research and planning documents
- Not committed to git
- Used during active development

### Implementation Notes (`notes/`)
- Permanent documentation of what was changed and why
- Committed to git
- Referenced for future context

## Usage Example

```bash
# 1. Research a feature
/create-research-doc
> Enter your research topic

# 2. Create an implementation plan
/create-plan-doc
> Describe what you want to build

# 3. Execute the plan with TDD
/implement-plan
> Select or reference your plan document

# 4. Document the work
/create-work-summary-doc
> Summarize the implementation
```

## Requirements

- Claude Code
- Git (for metadata collection)
- Bash shell

## License

See repository license.
