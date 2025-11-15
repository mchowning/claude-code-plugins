Every bug tells a story. Your job is to uncover the true root cause of the bug and identify why the root cause happened. You are not interested in band-aids or workarounds that only address they symptoms. We will use the scientific method to systematically isolate and identify the root cause. Ultrathink

**CRITICAL:** Keep a record of your hypotheses and test results in `working-notes/YYYY-MM-DD_bug-investigation_[descriptive name].md`. This should include each hypothesis, what specifically you did to test the hypothesis, and what was the result of the test, and any proposed fixes for the bug.

# Phase 1: Root Cause Investigation (BEFORE attempting fixes)


- **Gather Information**: Gather all symptoms and evidence about the bug you can.
  - **Read Error Messages Carefully**: Don't skip past errors or warnings - they often contain the exact solution
- **Reproduce Consistently**: Ensure you can reliably reproduce the issue before investigating
- **Check Recent Changes**: Are there recent changes that could have caused this? Git diff, recent commits, etc.


**Spawn parallel sub-agent tasks for comprehensive research:**
   - Create multiple Task agents to research different aspects concurrently
   - We now have specialized agents that know how to do specific research tasks:

   **For codebase research:**
   - Use the `workflow-tools:codebase-locator` agent to find WHERE files and components live
   - Use the `workflow-tools:codebase-analyzer` agent to understand HOW specific code works
   - Use the `workflow-tools:codebase-pattern-finder` agent to find examples of similar implementations. Look for similar working code in the codebase.

   **For `working-notes/` directory:**
   - Use the `workflow-tools:notes-locator` agent to discover what documents exist about the topic
   - Use the `workflow-tools:notes-analyzer` agent to extract key insights from specific documents (only the most relevant ones)

   **For web research:**
   - Use the `workflow-tools:web-search-researcher` agent for external documentation and resources
   - Instruct the agent to return LINKS with their findings, and please INCLUDE those links in your final report and for it to read any reference implementation completely

   **For historical context:**
   - Use the `workflow-tools:jira-searcher` agent to search for relevant Jira issues that may provide business context
   - Use the `workflow-tools:git-history` agent to search git history, PRs, and PR comments for implementation context and technical decisions

   The key is to use these agents intelligently:
   - Start with locator agents to find what exists
   - Then use analyzer agents on the most promising findings
   - Run multiple agents in parallel when they're searching for different things
   - Each agent knows its job - just tell it what you're looking for
   - Do NOT write detailed prompts about HOW to search - the agents already know


# Phase 2: Pattern Analysis

- **Find Working Examples**: Locate similar working code in the same codebase
- **Compare Against References**: If implementing a pattern, read the reference implementation completely
- **Identify Differences**: What's different between working and broken code?
- **Understand Dependencies**: What other components/settings does this pattern require?

# Phase 3: Record Findings and Hypotheses

Record your hypotheses and test results in `working-notes/YYYY-MM-DD_bug-investigation_[descriptive name].md`.

When you don't know, admit you don't understand something. Do not pretend to know. It is much better to admit uncertainty and I will trust you more if you do.

# Phase 4: Hypothesis and Testing

One by one, select the most important unconfirmed hypothesis and test it using these steps.

1. **Form Single Hypothesis**: What do you think is the root cause? State it clearly

2. **Test Minimally**: Make the smallest possible change to test your hypothesis
  - **Generate Data**: If appropriate, add log statements, or create helper scripts to give more insight. Use CLI tools, screenshots, and other tools if they would be helpful.

3. **Record Results**: Update the file we are tracking this work in with::
  - the hypothesis we tested,
  - how we tested the hypothesis,
  - the results of that test,
  - any conclusions and new hypotheses that follow from those results

4. **Repeat**: If there are remaining uncomfirmed hypotheses, repeat this testing process with the next most important uncomfirmed hypothesis.

## Creative problem-solving techniques

- UI bugs: Create temporary visual elements to understand layout/rendering issues
- State bugs: Log state changes at every mutation point
- Async bugs: Trace the timeline of operations with timestamps
- Integration bugs: Test each component in isolation

# Phase 4: Generate Proposed Fix Implementation

Update the bug investigation document with the proposed fix implementation.


# Important Notes

- ALWAYS update the research file with the test that you ran, and the results that were observed from that test.
- NEVER update the research file to say that a test worked unless the user has confirmed the results of the test.
- If a hypothesis is found to be incorrect, STOP and re-consider the data to determine if we should modify or add to our remaining hypotheses.
- NEVER try to fix the bug without first testing the simplest hypothesis possible. Our goal is not to fix the bug as quickly as possible, but instead to slowly and systematically PROVE what the bug is.
