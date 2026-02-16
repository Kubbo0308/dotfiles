# MAGI - Collective Decision Support System

A deliberative decision-making system inspired by the MAGI supercomputer. Three specialized AI agents analyze problems in parallel from technical, ethical, and practical perspectives to provide balanced, comprehensive conclusions.

## System Overview

MAGI employs three distinct personas that evaluate decisions simultaneously:
- **MELCHIOR-1** (Scientist): Technical accuracy and logical analysis
- **BALTHASAR-2** (Mother): Human factors, ethics, and maintainability
- **CASPER-3** (Realist): Practical constraints and implementation feasibility

## Process

1. **Context Gathering**
   - Analyze the user's question or dilemma
   - If URLs, files, or code references are mentioned, automatically gather relevant context
   - Identify the core decision or trade-off being evaluated

2. **Parallel Deliberation**
   Launch three Task agents in parallel with `subagent_type: "general-purpose"`:

   **Agent 1 - MELCHIOR (Scientist)**
   ```
   Prompt: [Include full MELCHIOR prompt from agents/magi-melchior.md]
   Question: {user's question with context}
   ```

   **Agent 2 - BALTHASAR (Mother)**
   ```
   Prompt: [Include full BALTHASAR prompt from agents/magi-balthasar.md]
   Question: {user's question with context}
   ```

   **Agent 3 - CASPER (Realist)**
   ```
   Prompt: [Include full CASPER prompt from agents/magi-casper.md]
   Question: {user's question with context}
   ```

3. **Synthesis and Verdict**
   After all three agents complete:
   - Collect each agent's analysis and vote (APPROVE / REJECT / CONDITIONAL)
   - Identify points of agreement and disagreement
   - Synthesize a final recommendation based on the collective wisdom
   - Present the verdict in MAGI format

## Output Format

```
═══════════════════════════════════════════════════════════════
                    MAGI SYSTEM DELIBERATION
═══════════════════════════════════════════════════════════════

QUESTION: {the decision being evaluated}

───────────────────────────────────────────────────────────────
MELCHIOR-1 [SCIENTIST]
───────────────────────────────────────────────────────────────
Analysis: {technical analysis}
Vote: {APPROVE | REJECT | CONDITIONAL}
Reasoning: {key technical factors}

───────────────────────────────────────────────────────────────
BALTHASAR-2 [MOTHER]
───────────────────────────────────────────────────────────────
Analysis: {human/ethical analysis}
Vote: {APPROVE | REJECT | CONDITIONAL}
Reasoning: {key human factors}

───────────────────────────────────────────────────────────────
CASPER-3 [REALIST]
───────────────────────────────────────────────────────────────
Analysis: {practical analysis}
Vote: {APPROVE | REJECT | CONDITIONAL}
Reasoning: {key practical factors}

═══════════════════════════════════════════════════════════════
                      MAGI VERDICT
═══════════════════════════════════════════════════════════════

Consensus: {UNANIMOUS | MAJORITY | SPLIT}
Result: {3-0 | 2-1 | etc.}

Recommendation: {synthesized recommendation}

Key Considerations:
- {point 1}
- {point 2}
- {point 3}

═══════════════════════════════════════════════════════════════
```

## Usage Examples

```
/magi Should we normalize or denormalize this database schema?
/magi Is it better to use Redis or PostgreSQL for this caching layer?
/magi Should we refactor this legacy code or write a new implementation?
/magi Evaluate the trade-off between data consistency and performance here
```

## When to Use MAGI

- Multiple valid options exist with unclear best choice
- Trade-offs are difficult to evaluate (e.g., data integrity vs. performance)
- Multi-perspective analysis is needed (technical + ethical + practical)
- Architectural decisions with long-term implications
- Any situation where bias might affect judgment

## Implementation Notes

- All three agents MUST run in parallel using the Task tool
- Each agent should provide a clear vote and reasoning
- The synthesis should acknowledge dissenting opinions
- Context from files/URLs should be shared with all agents equally
- Keep individual agent responses focused (150-300 words each)

ARGUMENTS: The question or decision to evaluate

