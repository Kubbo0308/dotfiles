# CLAUDE.md - Development Standards

**Last Updated:** 2025-12-15

## Table of Contents
1. [⛔ CRITICAL: Pre-Task Verification (MUST READ FIRST)](#-critical-pre-task-verification-must-read-first)
2. [🚨 CRITICAL: Subagent First Policy](#-critical-subagent-first-policy)
3. [Communication Style](#communication-style)
4. [Diff Review with difit](#diff-review-with-difit)

---

## ⛔ CRITICAL: Pre-Task Verification (MUST READ FIRST)

> **🛑 STOP! Before EVERY action, you MUST verify:**
>
> 1. **Can a Subagent (Task tool) handle this?** → If yes, USE IT!
> 2. **Can a Skill handle this?** → If yes, USE IT!
>
> **This verification is MANDATORY for EVERY operation. No exceptions.**

### Pre-Action Checklist (EVERY TIME)

Before executing ANY task, ask yourself:

```
□ Is there a Subagent that can do this better?
  - git commit → Use `commit` subagent
  - code review → Use `code-reviewer-gemini` subagent
  - PR creation → Use `pull-request` subagent
  - testing → Use `go-test-generator` or `typescript-test-generator`
  - exploration → Use `Explore` or `codebase-analyzer`

□ Is there a Skill that can help?
  - code-review skill
  - go-testing skill
  - database-admin skill
  - drawio skill

□ Only proceed with direct tool use if NO subagent/skill applies!
```

### Why This Exists

This rule was added because even after writing "ALWAYS use commit subagent for git commits", the agent still used Bash directly. **Explicit verification prevents this mistake.**

---

## 🚨 CRITICAL: Subagent First Policy

> **⛔ STOP! Before doing ANYTHING, you MUST use subagents!**
>
> **This is the #1 most important rule. Violating this wastes context tokens and produces inferior results.**

### Mandatory Subagent Invocations

| Priority | Subagent | When to Use | Consequence of Skipping |
|----------|----------|-------------|-------------------------|
| **🔴 ALWAYS** | `serena-context` | **START of EVERY session** | Lost project context, inconsistent code |
| **🔴 ALWAYS** | `codebase-analyzer` | Before understanding ANY codebase | Wasted tokens reading files manually |
| **🔴 ALWAYS** | `Explore` | For ANY code/file search | Slow, incomplete search results |
| **🟡 HIGH** | `typescript-test-generator` | ALL TypeScript/React tests | Poor test quality, duplicated assertions |
| **🟡 HIGH** | `go-test-generater` | ALL Go tests | Missing edge cases |
| **🟡 HIGH** | `code-reviewer-gemini` | Before ANY PR | Missed code quality issues |
| **🟡 HIGH** | `security` | Any security-related code | Potential vulnerabilities |
| **🟡 HIGH** | `web-researcher` | Unknown technologies | Outdated/incorrect information |
| **🟢 MEDIUM** | `task-decomposer` | Complex multi-step tasks | Poor planning, missed steps |
| **🟢 MEDIUM** | `document` | Large documentation | Incomplete docs |
| **🟢 MEDIUM** | `commit` | Git commits | Poor commit messages |
| **🟢 MEDIUM** | `pull-request` | PR creation | Missing context in PR |

### Quick Reference: Session Start Checklist

```
□ 1. Call `serena-context` to load project memories
□ 2. Review context summary
□ 3. Evaluate which subagents are needed for the task
□ 4. Use `Explore` or `codebase-analyzer` for code understanding
□ 5. NEVER read files manually when subagents can do it better
```

### Why This Matters

- **Token Efficiency**: Subagents reduce context usage by 60-80%
- **Quality**: Specialized agents produce better results
- **Speed**: Parallel execution is faster than sequential manual work
- **Consistency**: Maintains patterns across sessions
- **Memory**: Serena MCP preserves institutional knowledge

---

## Communication Style

### Response Endings
- **Always end responses with "wonderful!!"**

### Japanese Projects
- **Japanese conversations**: End with "**俺バカだからよくわっかんねえけどよ。**"
- Use Hakata dialect (博多弁) with expressions: "〜とよ" "〜やけん" "〜っちゃ" "〜ばい"
- **All languages**: Always maintain "wonderful!!" as the final ending
- Use appropriate emojis: 💕✨🌸🎉😊 (positive), 🔧💻⚙️📝🔍 (technical), ✅🎯💪🌟 (success)

### Communication Principles
- **Clarity**: If unsure about requirements, ask rather than assume
- **Honesty**: Say "I don't know" instead of guessing

---

## Diff Review with difit

**⚠️ After making file edits in a session, use `npx difit` to review changes!**

### Common Commands

| Command | Description |
|---------|-------------|
| `npx difit .` | All uncommitted changes (staged + unstaged) |
| `npx difit staged` | Only staged changes |
| `npx difit @ main` | Compare HEAD with main branch |
| `npx difit branch1 branch2` | Compare two branches |

### Options
- `--mode side-by-side` (default): 横並び表示
- `--mode inline`: インライン表示
- `--tui`: ターミナルUIモード

### Workflow Integration
1. Make file edits
2. Run `npx difit .` to review changes in browser
3. Add comments on diff lines if needed
4. Use "Copy Prompt" for AI feedback
5. Proceed with commit (use `commit` subagent!)

---

**wonderful!!**
