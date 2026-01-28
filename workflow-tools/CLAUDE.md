# Directory Structure

- `working-notes/` -- top-level directory for various notes about the project's implementation (NOT committed to git - temporary research and planning documents)
- `notes/` -- top-level directory for implementation summaries documenting what was changed and why (committed to git - permanent documentation)

# Plugin Commands

This plugin provides seven workflow commands:

1. **`/create-research-doc`** - Conduct comprehensive research across the codebase using parallel sub-agents
2. **`/create-plan-doc`** - Create detailed implementation plans through interactive, iterative process
3. **`/implement-plan`** - Follow an approved technical plan with TDD and progress tracking
4. **`/create-work-summary-doc`** - Generate comprehensive implementation summaries documenting what was changed and why
5. **`/review-code`** - Get external AI review of code changes or implementation plans
6. **`/review-doc`** - Get external AI review of research documents or general documents
7. **`/investigate-bug`** - Systematically investigate bugs using the scientific method

# Specialized Agents

The plugin includes eight specialized agents that are automatically invoked by commands:

- **codebase-locator** - Finds WHERE files, directories, and components live
- **codebase-analyzer** - Analyzes HOW code works with precise file:line references
- **codebase-pattern-finder** - Locates similar implementations and usage patterns
- **notes-locator** - Discovers relevant notes/documents in `working-notes/`
- **notes-analyzer** - Deeply analyzes notes documents and extracts insights
- **web-search-researcher** - Conducts web research for external documentation
- **jira** - Searches Jira for issues and business context
- **git-history** - Searches git history, PRs, and PR comments for implementation context
