# Workflow Tools Plugin

This plugin provides structured commands for codebase research, planning, implementation, and documentation.

## Variables

- `WORKING_NOTES_DIR`: `working-notes/` -- top-level directory for various notes about the project's implementation (NOT committed to git - temporary research and planning documents)
- `NOTES_DIR`: `notes/` -- top-level directory for implementation summaries documenting what was changed and why (committed to git - permanent documentation)

## Plugin Commands

This plugin provides four workflow commands:

1. **`/research-codebase`** - Conduct comprehensive research across the codebase using parallel sub-agents
2. **`/create-plan`** - Create detailed implementation plans through interactive, iterative process
3. **`/implement-plan`** - Follow an approved technical plan with TDD and progress tracking
4. **`/summarize-work`** - Generate comprehensive implementation summaries documenting what was changed and why

## Specialized Agents

The plugin includes seven specialized agents that are automatically invoked by commands:

- **codebase-locator** - Finds WHERE files, directories, and components live
- **codebase-analyzer** - Analyzes HOW code works with precise file:line references
- **codebase-pattern-finder** - Locates similar implementations and usage patterns
- **notes-locator** - Discovers relevant notes/documents in `WORKING_NOTES_DIR`
- **notes-analyzer** - Deeply analyzes notes documents and extracts insights
- **web-search-researcher** - Conducts web research for external documentation
- **jira-searcher** - Searches Jira for issues and historical context
