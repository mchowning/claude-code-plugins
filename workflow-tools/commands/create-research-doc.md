# Research Codebase

You are tasked with conducting comprehensive research across the codebase to answer user questions by spawning parallel sub-agents and synthesizing their findings.

## Scope

This command is for **research and documentation only**. You must NOT:
- Write or modify any production code
- Create new files outside of `working-notes/`
- Implement any solutions discovered during research

Your only outputs are: questions to the user and the final research document.

## Initial Setup:

When this command is invoked, if you already think you know what the user wants to research, confirm that with the user. If you do not know, respond with:

```
I'm ready to research the codebase. Please provide your research question or area of interest, and I'll analyze it thoroughly by exploring relevant components and connections.
```

Then wait for the user's research query.

## Handling Ambiguities

When you encounter an ambiguity, uncertainty, or decision point during research:

1. **STOP immediately** - do not continue researching with assumptions
2. **Ask the user ONE question** about the specific ambiguity
3. **Wait for their answer** before proceeding
4. **Incorporate their answer** into your research direction

Examples of when to stop and ask:
- The research could go in multiple directions and you're unsure which matters
- You found conflicting information and don't know which is authoritative
- The scope is unclear - should you include related area X?
- A technical detail requires domain knowledge you don't have
- You're uncertain about the user's intent or what they're trying to accomplish

**The final document should have ZERO open questions** - all ambiguities must be resolved through conversation before generating the document.

## Steps to follow after receiving the research query:

1. **Read any directly mentioned files first:**
   - If the user mentions specific files (tickets, docs, JSON), read them FULLY first
   - **IMPORTANT**: Use the Read tool WITHOUT limit/offset parameters to read entire files
   - **CRITICAL**: Read these files yourself in the main context before spawning any sub-tasks
   - This ensures you have full context before decomposing the research

2. **Analyze and decompose the research question:**
   - Break down the user's query into composable research areas
   - Take time to ultrathink about the underlying patterns, connections, and architectural implications the user might be seeking
   - Identify specific components, patterns, or concepts to investigate
   - Create a research plan using TodoWrite to track all subtasks
   - Consider which directories, files, or architectural patterns are relevant

3. **Spawn parallel sub-agent tasks for comprehensive research:**
   - Create multiple Task agents to research different aspects concurrently
   - We now have specialized agents that know how to do specific research tasks:

   **For codebase research:**
   - Use the `workflow-tools:codebase-locator` agent to find WHERE files and components live
   - Use the `workflow-tools:codebase-analyzer` agent to understand HOW specific code works
   - Use the `workflow-tools:codebase-pattern-finder` agent if you need examples of similar implementations

   **For `working-notes/` directory:**
   - Use the `workflow-tools:notes-locator` agent to discover what documents exist about the topic
   - Use the `workflow-tools:notes-analyzer` agent to extract key insights from specific documents (only the most relevant ones)

   **For web research:**
   - Use the `workflow-tools:web-search-researcher` agent for external documentation and resources
   - Instruct the agent to return LINKS with their findings, and please INCLUDE those links in your final report

   **For historical context:**
   - Use the `workflow-tools:jira` agent to search for relevant Jira issues that may provide business context
   - Use the `workflow-tools:git-history` agent to search git history, PRs, and PR comments for implementation context and technical decisions

   The key is to use these agents intelligently:
   - Start with locator agents to find what exists
   - Then use analyzer agents on the most promising findings
   - Run multiple agents in parallel when they're searching for different things
   - Each agent knows its job - just tell it what you're looking for
   - Do NOT write detailed prompts about HOW to search - the agents already know

4. **Wait for all sub-agents to complete and synthesize findings:**
   - IMPORTANT: Wait for ALL sub-agent tasks to complete before proceeding
   - Compile all sub-agent results (codebase, `working-notes/` findings, and web research)
   - Prioritize live codebase findings as primary source of truth
   - Use `working-notes/` findings as supplementary historical context
   - Connect findings across different components
   - Include specific file paths and line numbers for reference
   - Highlight patterns, connections, and architectural decisions
   - Answer the user's specific questions with concrete evidence

5. **Gather metadata for the research document:**
   - Filename: `working-notes/{YYYY-MM-DD}_research_[descriptive-name].md`. Use `date '+%Y-%m-%d'` for the timestamp in the filename.
   - Run the frontmatter script: `${CLAUDE_PLUGIN_ROOT}/skills/frontmatter/workflow-tools-frontmatter.sh`

6. **Generate research document:**
   - Use the metadata gathered in the previous step
   - Structure the document with YAML frontmatter followed by content:

     ```markdown
     ---
     date: [Current date and time with timezone in ISO format]
     git_commit: [Current commit hash]
     branch: [Current branch name]
     repository: [Repository name]
     topic: "[User's Question/Topic]"
     tags: [research, codebase, relevant-component-names]
     last_updated: [Current date in YYYY-MM-DD format]
     ---

     # Research: [User's Question/Topic]

     **Date**: [Current date and time with timezone from step 4]
     **Git Commit**: [Current commit hash from step 4]
     **Branch**: [Current branch name from step 4]
     **Repository**: [Repository name]

     ## Research Question

     [Original user query]

     ## Summary

     [High-level findings answering the user's question]

     ## Detailed Findings

     ### [Component/Area 1]

     - Finding with reference ([file.ext:line](link))
     - Connection to other components
     - Implementation details

     ### [Component/Area 2]

     ...

     ## Code References

     - `path/to/file.py:123` - Description of what's there
     - `another/file.ts:45-67` - Description of the code block

     ## Architecture Insights

     [Patterns, conventions, and design decisions discovered]

     ## Historical Context

     [Relevant insights from `working-notes/` directory and any relevant Jira issues. Include references for all insights.]

     ## Related Research

     [Links to past research documents in `working-notes/`]

     ## Future Research Directions

     [Optional: Areas outside the current scope that could be explored in follow-up research]
     ```

7. **Finalize Document Quality:**

   This step must be completed before presenting findings to the user.

   **7.1: Check for External Review Configuration**

   Check if external review is configured:

   ```bash
   echo "${CLAUDE_EXTERNAL_REVIEW_COMMAND:-NOT_SET}"
   ```

   **7.2: Run External Review (if configured)**

   **If the variable shows `NOT_SET` or is empty:**
   - Continue to Step 7.3
   - No further action needed

   **If external review IS configured:**

   The environment variable contains one or more review commands separated by `: ` (colon-space).
   Examples:
   - Single: `opencode --model github-copilot/gpt-5 run`
   - Multiple: `opencode --model github-copilot/gpt-5 run: opencode --model deepseek/deepseek-v3 run`

   For each review command (process them sequentially):

   a. **Extract the command** (split on `: ` delimiter if multiple)

   b. **Run the external review:**
      Execute the command with this review prompt:
      ```bash
      ${COMMAND} "Review the research document at [DOCUMENT_PATH] and provide detailed feedback on:

      1. Factual accuracy and completeness of findings
      2. Alignment with project architecture and patterns (check CLAUDE.md and codebase)
      3. Missing connections or relationships between components
      4. Missing important considerations or context
      5. Incorrect interpretations of code or architecture
      6. Missing references or citations (file paths, line numbers)
      7. Gaps in answering the original research question

      Be specific about what's missing or incorrect. Cite file paths and line numbers where relevant. Focus on actionable improvements."
      ```

   c. **Analyze feedback with extreme skepticism:**
      - Dismiss theoretical concerns that don't apply to this specific research
      - Ignore feedback that adds unnecessary complexity
      - Ignore feedback based on false assumptions
      - **Only identify feedback that reveals GENUINE gaps, errors, or missing CRITICAL information**
      - Most feedback should probably be dismissed

   d. **Silently address ONLY critical issues:**
      - Fix any factual errors
      - Add only truly important missing information
      - Make minimal, focused updates
      - **Do NOT implement every suggestion**
      - Update the document file directly

   e. **If multiple reviewers:** Each subsequent reviewer sees the updated document from the previous review

   **Do NOT present reviews to the user** - this is an internal quality check.

   **7.3: Document Ready for Presentation**

   The research document has been written and quality-checked. Ready to present to user.

8. **Add GitHub permalinks (if applicable):**
   - Check if on main branch or if commit is pushed: `git branch --show-current` and `git status`
   - If on main/master or pushed, generate GitHub permalinks:
     - Get repo info: `gh repo view --json owner,name`
     - Create permalinks: `https://github.com/{}/{repo}/blob/{commit}/{file}#L{line}`
   - Replace local file references with permalinks in the document

9. **Present findings to user:**

    Present to the user:
    - Concise summary of findings
    - Key file references for easy navigation
    - Ask if they have follow-up questions or need clarification

10. **Handle follow-up questions:**
   - If the user has follow-up questions, append to the same research document
   - Update the frontmatter fields `last_updated` and `last_updated_by` to reflect the update
   - Add `last_updated_note: "Added follow-up research for [brief description]"` to frontmatter
   - Add a new section: `## Follow-up Research [timestamp]`
   - Spawn new sub-agents as needed for additional investigation
   - Continue updating the document

## Important notes:

- Always use parallel Task agents to maximize efficiency and minimize context usage
- Always run fresh codebase research - never rely solely on existing research documents
- The `working-notes/` directory provides historical context to supplement live findings
- Focus on finding concrete file paths and line numbers for developer reference
- The research document should NOT include any references to how long things will take (i.e., Phase 1 will take 2 days)
- Research documents should be self-contained with all necessary context
- Each sub-agent prompt should be specific and focused on read-only operations
- Consider cross-component connections and architectural patterns
- Include temporal context (when the research was conducted)
- Link to GitHub when possible for permanent references
- Keep the main agent focused on synthesis, not deep file reading. Use subagents for any deep file reading.
- Encourage sub-agents to find examples and usage patterns, not just definitions
- Explore all of `working-notes/` directory, not just research subdirectory
- **File reading**: Always read mentioned files FULLY (no limit/offset) before spawning sub-tasks
- **Critical ordering**: Follow the numbered steps exactly
  - ALWAYS read mentioned files first before spawning sub-tasks (step 1)
  - ALWAYS wait for all sub-agents to complete before synthesizing (step 4)
  - ALWAYS gather metadata before writing the document (step 5 before step 6)
  - NEVER write the research document with placeholder values
  - This ensures paths are correct for editing and navigation
- **Frontmatter consistency**:
  - Always include frontmatter at the beginning of research documents
  - Keep frontmatter fields consistent across all research documents
  - Update frontmatter when adding follow-up research
  - Use snake_case for multi-word field names (e.g., `last_updated`, `git_commit`)
  - Tags should be relevant to the research topic and components studied

## Final Instructions

1. **Do NOT implement anything** - this command produces a research document, not code
2. **Do NOT create or modify files** outside of `working-notes/`
3. **Stop and ask** when you encounter ambiguities - do not proceed with assumptions
4. The research document is your only deliverable
