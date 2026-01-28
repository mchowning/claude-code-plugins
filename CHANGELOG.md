# Changelog

## 2026-01-26

### Changed
- **Split `/external-review` into specialized commands**
  - `/workflow-tools:review-code` for reviewing code changes and implementation plans
  - `/workflow-tools:review-doc` for reviewing research documents and general documents
- Added `workflow-tools:` prefix to all commands for namespace consistency

## 2026-01-15

### Changed
- Renamed `/review-doc` command to `/external-review` for clarity
- Refactored command to use shell script (`scripts/external-review.sh`) for parallel review execution
- Added `disable-model-invocation: true` frontmatter to prevent automatic invocation—command must be explicitly invoked by user
- `/implement-plan` now explicitly requires updating the plan document when deviating from it

### Added
- `scripts/external-review.sh` - Shell script for running external AI reviews in parallel

### Removed
- `commands/review-doc.md` - Replaced by `commands/external-review.md`

## 2026-01-08

### Changed
- `/create-research-doc` now includes intent clarification phase
  - Asks about research goal only if not provided in arguments
  - Only asks clarifying questions if goal statement is ambiguous
  - Lighter-touch approach that defers research methodology to agent

## 2026-01-07

### Changed
- `/implement-plan` now includes comprehensive documentation update guidance
  - Identifies affected markdown files (README, CLAUDE.md, API docs, etc.)
  - Guidance on when and how to update documentation proportionally
- `/create-work-summary-doc` now auto-commits the generated summary document
- `/create-plan-doc` now explicitly stops at plan approval instead of starting implementation
  - Directs users to use `/implement-plan` for execution
- Added `$ARGUMENTS` variable to `/create-research-doc` and `/investigate-bug` for additional context

## 2025-12-23

### Changed
- Extended `$ARGUMENTS` detection to `/create-plan-doc`, `/implement-plan`, and `/review-doc`
  - Commands now skip redundant questions when information is provided upfront

## 2025-12-21

### Changed
- `/create-work-summary-doc` now detects pre-provided information (context docs, Jira ticket, git scope) from the user's prompt and only asks about missing pieces
  - If user provides a Jira ticket like `PROJ-1234`, the command skips asking about Jira
  - If user specifies "from default branch" or "last commit", the command skips asking about git scope
  - If user references document paths, the command skips asking about context documents
  - If all information is provided upfront, `AskUserQuestion` is skipped entirely

## 2025-12-19

### Changed
- `/create-research-doc` and `/create-plan-doc` now resolve ambiguities interactively
  - Added Scope sections to prevent Claude from implementing instead of documenting
  - Ambiguities resolved via one-at-a-time questions rather than deferring to "Open Questions"
  - Renamed "Open Questions" to "Future Research Directions" in templates
- Added design philosophy section and Human Layer video link to README

## 2025-12-18

### Changed
- Improved uncommitted changes support in `/create-work-summary-doc`
  - Removed "(not recommended)" label for uncommitted changes option
  - Skip commit history collection when user explicitly chose uncommitted changes
  - Simplified Git References section for uncommitted changes (just branch + status)

## 2025-12-12

### Changed
- Replaced `frontmatter-generator` agent with skill-based shell script for faster, cheaper, and more deterministic metadata collection
  - Created `skills/frontmatter/SKILL.md` with skill definition
  - Created `skills/frontmatter/workflow-tools-frontmatter.sh` script for direct execution
  - Updated `/create-research-doc`, `/create-plan-doc`, and `/create-work-summary-doc` to call script directly

### Removed
- `workflow-tools/agents/frontmatter-generator.md` agent - replaced by skill-based approach

## 2025-12-04

### Changed
- Renamed `jira` agent back to `jira-searcher` and removed work item creation capability
  - Jira ticket creation functionality moved to separate `jira-ticket-creator` agent outside this plugin
  - `jira-searcher` agent now focuses solely on searching and viewing Jira work items

## 2025-12-02

### Changed
- Renamed `jira-searcher` agent to `jira` to reflect expanded capabilities
- Enhanced `jira` agent with work item creation capability using `acli jira workitem create`
  - Added comprehensive documentation for create command with examples
  - Documented required flags (summary, project, type) and optional flags (description, assignee, labels, parent)
  - Agent now supports both searching/viewing and creating Jira work items

## 2025-12-01

### Changed
- **Improved external review reliability**: Restructured external review steps in all doc-generation commands to make them structurally unavoidable
  - Changed from sequential steps (easy to skip) to nested substeps within document finalization (required to complete)
  - Simplified external review instructions by removing complex bash pseudocode in favor of clear procedural steps
  - Removed redundant checkpoint steps that added noise without fixing structural issues
  - Updated `/create-plan-doc`: Merged Steps 5, 5.5, 6 into new "Finalize Document Quality" step with substeps
  - Updated `/create-research-doc`: Consolidated Steps 7, 8 into "Finalize Document Quality" step
  - **Added external review to `/create-work-summary-doc`**: Previously had no external review step at all
- External review now embedded as part of completing the document rather than a separate post-completion step

## 2025-11-21

### Added
- `workflow-tools/scripts/workflow-tools-frontmatter.sh` script for automated metadata collection ([e4008f8](https://github.com/mchowning/claude-code-plugins/commit/e4008f8))
- Comprehensive README.md for workflow-tools plugin with installation instructions and required permissions ([e4008f8](https://github.com/mchowning/claude-code-plugins/commit/e4008f8))
- Optional automated quality check to `/create-plan-doc` and `/create-research-doc` using `CLAUDE_EXTERNAL_REVIEW_COMMAND` environment variable ([6efb666](https://github.com/mchowning/claude-code-plugins/commit/6efb666))

### Changed
- Enhanced `git-history` agent with explicit GitHub PR search command examples for searching PR descriptions (`gh pr list --search "in:body"`) and PR comments (`gh search prs "in:comments"`)
- Refactored `frontmatter-generator` agent to embed bash commands directly instead of calling external script, as `${CLAUDE_PLUGIN_ROOT}` variable is not available in agent markdown execution contexts
- Updated README directory structure to reflect current agent list, including `git-history` and `frontmatter-generator` agents

### Removed
- `workflow-tools/scripts/workflow-tools-frontmatter.sh` script - functionality now embedded directly in `frontmatter-generator` agent
- `workflow-tools/scripts/` directory - no longer needed after script removal

## 2025-11-14

### Added
- `/investigate-bug` command for systematic root cause analysis using the scientific method ([20ff35f](https://github.com/mchowning/claude-code-plugins/commit/20ff35f))
- `/review-doc` command for external AI review of research/plan documents ([3f53c45](https://github.com/mchowning/claude-code-plugins/commit/3f53c45))
- Document selection prompts when invoking `/create-plan-doc` and `/implement-plan` without arguments - suggests 2 most recent documents ([234b3d4](https://github.com/mchowning/claude-code-plugins/commit/234b3d4), [e9c4e7e](https://github.com/mchowning/claude-code-plugins/commit/e9c4e7e))

### Changed
- Standardized agent invocations to use fully-qualified names (e.g., `workflow-tools:codebase-locator`) ([4918fe9](https://github.com/mchowning/claude-code-plugins/commit/4918fe9))

## 2025-11-11

### Changed
- Renamed commands for clarity ([166f0f7](https://github.com/mchowning/claude-code-plugins/commit/166f0f7)):
  - `/research-codebase` → `/create-research-doc`
  - `/create-plan` → `/create-plan-doc`
  - `/summarize-work` → `/create-work-summary-doc`

### Removed
- Directory variables from configuration ([b6b0f44](https://github.com/mchowning/claude-code-plugins/commit/b6b0f44))

## 2025-11-07

### Changed
- Minor updates and refinements ([d8ae986](https://github.com/mchowning/claude-code-plugins/commit/d8ae986))

## 2025-11-05

### Changed
- Updated `/create-work-summary-doc` to use objective language in summaries ([cc93678](https://github.com/mchowning/claude-code-plugins/commit/cc93678))

## 2025-10-30

### Changed
- Updated README with comprehensive documentation improvements ([17dab36](https://github.com/mchowning/claude-code-plugins/commit/17dab36))

## 2025-10-29

### Added
- Initial release with 4 core workflow commands ([3717096](https://github.com/mchowning/claude-code-plugins/commit/3717096)):
  - `/create-research-doc` - Comprehensive codebase and web research using parallel sub-agents
  - `/create-plan-doc` - Interactive, iterative implementation planning
  - `/implement-plan` - TDD-based plan execution with progress tracking
  - `/create-work-summary-doc` - Generate implementation summaries documenting changes and rationale
- 7 specialized research agents ([3717096](https://github.com/mchowning/claude-code-plugins/commit/3717096)):
  - `codebase-locator` - Finds files, directories, and components
  - `codebase-analyzer` - Analyzes code implementation details
  - `codebase-pattern-finder` - Locates similar implementations and usage patterns
  - `notes-locator` - Discovers relevant documents in `working-notes/`
  - `notes-analyzer` - Deeply analyzes notes and extracts insights
  - `web-search-researcher` - Conducts web research for external documentation
  - `jira-searcher` - Searches Jira for issues and business context
- `git-history` specialized agent for searching git history, PRs, and PR comments ([a98dea0](https://github.com/mchowning/claude-code-plugins/commit/a98dea0))
- Helper script `claude-md-frontmatter.sh` for document metadata generation ([3717096](https://github.com/mchowning/claude-code-plugins/commit/3717096))
- Comprehensive README with usage philosophy and workflow examples ([3717096](https://github.com/mchowning/claude-code-plugins/commit/3717096), [775013c](https://github.com/mchowning/claude-code-plugins/commit/775013c))
- MIT License and marketplace configuration for distribution ([3717096](https://github.com/mchowning/claude-code-plugins/commit/3717096))

### Changed
- Replaced frontmatter-generator script with inline frontmatter generation in commands ([935e864](https://github.com/mchowning/claude-code-plugins/commit/935e864), [0632620](https://github.com/mchowning/claude-code-plugins/commit/0632620))
- Moved README.md to repository root ([51cb1d0](https://github.com/mchowning/claude-code-plugins/commit/51cb1d0))
