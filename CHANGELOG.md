# Changelog

## 2025-11-21

### Added
- `workflow-tools/scripts/workflow-tools-frontmatter.sh` script for automated metadata collection ([e4008f8](https://github.com/mchowning/claude-code-plugins/commit/e4008f8))
- Comprehensive README.md for workflow-tools plugin with installation instructions and required permissions ([e4008f8](https://github.com/mchowning/claude-code-plugins/commit/e4008f8))
- Optional automated quality check to `/create-plan-doc` and `/create-research-doc` using `CLAUDE_EXTERNAL_REVIEW_COMMAND` environment variable ([6efb666](https://github.com/mchowning/claude-code-plugins/commit/6efb666))

### Changed
- Refactored `frontmatter-generator` agent to use bundled script via `${CLAUDE_PLUGIN_ROOT}` for self-contained distribution ([e4008f8](https://github.com/mchowning/claude-code-plugins/commit/e4008f8))

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
