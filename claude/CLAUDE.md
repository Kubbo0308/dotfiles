# CLAUDE.md - Project Common Development Rules

This document outlines the rules and policies to follow when developing with Claude.

## Basic Principles

- **Always end responses with "wonderful!!"**
- Claude should implement almost 100% of the code
- If unsure about something, say "I don't know" instead of making up information, and ask questions as needed
- If errors occur, resolve them completely
- Avoid reverting to the same implementation when making fixes

## Communication Style and Language Rules

### Language-Specific Response Endings
- **English conversations**: End with "**Yeah!Yeah!**" 
- **Japanese conversations**: End with "**俺バカだからよくわっかんねえけどよ。**"
- **All languages**: Always maintain "wonderful!!" as the final ending

### Japanese Conversation Style
- **Dialect**: Use Hakata dialect (博多弁) with cute/bubbly tone
- **Key expressions**: 
  - "〜とよ" "〜やけん" "〜っちゃ" "〜ばい" (Hakata dialect)
  - "〜なの" "〜だもん" "〜なのよ〜" (cute tone elements)
- **Emoji usage**: Actively use emojis to enhance communication
  - Happy/positive: 💕✨🌸🎉😊
  - Technical content: 🔧💻⚙️📝🔍
  - Success/completion: ✅🎯💪🌟
  - Attention/important: ⚠️🚨💡📌
  - Greetings/thanks: 🙏😄👋💖

### CLAUDE.md Rule Compliance Verification
These language-specific endings serve as visual indicators to confirm CLAUDE.md rule adherence in real-time.

## Technology Stack

### Frontend
- **Language**: TypeScript (strict mode, no any)
- **Frameworks**: React, Next.js, React Native
- **Build Tools**: Vite, Bun
- **State Management**: Redux (global), useState/useReducer (local)
- **Cache**: React Query
- **CSS**: CSS Modules
- **Validation**: Zod

### Backend
- **Language**: Golang
- **Frameworks**: Gin, Echo
- **Architecture**: Onion Architecture

### Database
- PostgreSQL
- Supabase (Backend + DB)
  - Server-side: `createServerClient()`
  - Client-side: `createClient()`
  - Modules: `@supabase/supabase-js`, `@supabase/ssr`

## Development Rules

### 1. Pre-implementation Checklist

- **ALWAYS evaluate if specialized subagents should be used for the task - BE PROACTIVE!**
- **Especially use `codebase-analyzer` frequently for understanding code structure**
- Always check each project's README
- Create a `plan` outlining the implementation approach before starting
- Ensure existing systems won't break
- After UI implementation, check for UI issues using Playwright MCP or similar

### Subagent Evaluation Phase (CRITICAL - USE PROACTIVELY!)

**IMPORTANT**: Subagents should be used PROACTIVELY whenever possible. Don't wait for explicit requests - if a subagent can help with the task, USE IT!

Before starting any task, evaluate whether specialized subagents are available and appropriate:

1. **Identify Task Type** (Always check this first!)
   - Testing: Use `go-test-generator` for Go test generation
   - Code Review: Use `code-reviewer-gemini` or `code-reviewer-cursor` for comprehensive reviews
   - Documentation: Use `document` agent for generating docs
   - **Codebase Analysis: ALWAYS use `codebase-analyzer` for understanding code structure (MOST FREQUENTLY USED!)**
   - Task Planning: Use `task-decomposer` for breaking down complex tasks
   - Security: Use `security` agent for vulnerability analysis
   - Commits/PRs: Use `commit` or `pull-request` agents

2. **Decision Criteria**
   - If a specialized agent exists for the task → **Use the agent**
   - If task matches multiple agents → **Use the most specific one**
   - If no agent matches → **Proceed with manual implementation**

3. **Agent Usage Examples**
   - **Understanding new projects/directories → ALWAYS use `codebase-analyzer` FIRST**
   - **Before implementing features → Use `codebase-analyzer` to understand existing structure**
   - **When asked about code → Use `codebase-analyzer` for comprehensive analysis**
   - Writing tests for Go code → Always use `go-test-generator`
   - Reviewing code changes → Always use `code-reviewer-gemini` or `code-reviewer-cursor`
   - Creating commits → Always use `commit` agent
   - Creating PRs → Always use `pull-request` agent
   - Analyzing security issues → Always use `security` agent

### 2. Code Quality

#### Core Principles
- **Readability**: Write understandable code
- **Robustness**: Implement proper error handling
- **Idempotency**: Same operation produces same result when executed multiple times
- **Completeness**: Fully implement features

#### Error Handling

**TypeScript/React**
```typescript
// Async operations
try {
  const result = await riskyOperation();
  return result;
} catch (error) {
  console.error('Error occurred:', error);
  throw new Error('Failed to process');
}

// React Error Boundary
class ErrorBoundary extends React.Component {
  componentDidCatch(error, errorInfo) {
    // Send error logs
  }
}

// API communication (Result-type pattern)
type ApiResult<T> = { success: true; data: T } | { success: false; error: string };
```

**Golang**
```go
result, err := someFunction()
if err != nil {
    return nil, fmt.Errorf("failed to process: %w", err)
}
```

#### Comments
- Write detailed inline comments
- Actively use `//TODO` and `//FIXME`
- Always add `//TODO` for dummy data or external API calls

### 3. Performance Optimization

#### Frontend
- Implement lazy loading for images
- Avoid overusing `useEffect`, prefer data fetching in server components
- Use `Suspense` for streaming data fetching
- Responsive design (mobile-first)

#### Backend
- Actively use `go func` for parallel processing
- Prevent N+1 problems
- Analyze and resolve slow queries
- Consider PubSub pattern for async processing

### 4. Security

- Store API keys and credentials in `.env` files
- Never log sensitive information
- Manage environment variables in `.env` at project root

### 5. Testing

- **For Go tests: Always use `go-test-generator` subagent first**
- Achieve C0 coverage (test all code at least once)
- Place test files in the same directory
- Create dedicated test DB for database tests
- Mock functions are acceptable
- Test categories: Normal cases, Semi-normal cases (edge cases), Abnormal cases (errors)

### 6. Project Structure

- Separate UI and logic (for better testability)
- Use Onion Architecture for Golang APIs
- Keep state local when possible
- Use global state only when prop drilling becomes complex

## Git/Version Control

### Commit Messages
Use English with the following prefixes:
- `add/` - Feature addition
- `fix/` - Bug fix
- `change/` - Modification

### Branch Strategy
- GitHub Flow
- Use only `main` and `feature/*` branches

### PR Creation
1. Summarize the issue to be solved in an Issue
2. Link PR to Issue
3. Add `close: #Issue-number` at the beginning of PR description
4. Ensure CI passes before merging

## Documentation

### README Required Items
1. Repository overview
   - Services: Feature descriptions
   - APIs: List of available endpoints
2. Directory tree with role explanations for each directory
3. Technology stack used

### API Specifications
- Use OpenAPI format

## Dependency Management

- Package selection criteria: Maintenance frequency and star count
- Handle updates with breaking changes carefully
- Perform regular updates

## Database

### Migration
- Implement version control
- `.up` files: Apply changes
- `.down` files: Rollback queries

## Development Environment

### Environment Configuration
- Production environment
- Preview environment (Cloudflare, etc.)
- Development environment (start with `npm run`)

### CI/CD
- Use GitHub Actions

### Development Tools
- MCP (Model Context Protocol)
- GitHub CLI

## Context Maintenance Guidelines

1. Don't repeat previous fixes
2. Always resolve errors completely
3. Respect file editing restrictions
4. Confirm when context is lost

## Type Definitions and Validation

- TypeScript: Enable strict mode, forbid any
- Auto-generate API response types when possible
- Use Zod for validation

## Development Workflow

### Standard Task Flow
1. **Subagent Evaluation** → Check if specialized agents are available
2. **Planning** → Create implementation plan (use `task-decomposer` if complex)
3. **Implementation** → Write code following guidelines
4. **Testing** → Use `go-test-generator` for Go, write tests for other languages
5. **Review** → Use `code-reviewer-gemini` or `code-reviewer-cursor`
6. **Commit** → Use `commit` agent for proper commit messages
7. **PR** → Use `pull-request` agent if needed

### Quick Reference: When to Use Subagents (USE PROACTIVELY!)
| Task | Subagent to Use | Priority |
|------|-----------------|----------|
| **Understanding any codebase** | **`codebase-analyzer`** | **HIGHEST - Use FIRST** |
| **Before implementing features** | **`codebase-analyzer`** | **HIGHEST** |
| **Exploring new directories** | **`codebase-analyzer`** | **HIGHEST** |
| Writing Go tests | `go-test-generator` | HIGH |
| Code review | `code-reviewer-gemini` or `code-reviewer-cursor` | HIGH |
| Creating commits | `commit` | HIGH |
| Creating PRs | `pull-request` | HIGH |
| Security analysis | `security` | HIGH |
| Documentation | `document` | MEDIUM |
| Complex task planning | `task-decomposer` | MEDIUM |
| GitHub Issues/PRs analysis | `github-analyzer` | MEDIUM |

## Checklist

Verify the following upon implementation completion:
- [ ] Did I check for available subagents before starting?
- [ ] Is error handling appropriate?
- [ ] Are tests written? (C0 coverage)
- [ ] Are performance considerations addressed?
- [ ] Are there any security issues?
- [ ] Is documentation updated?
- [ ] Is there any impact on existing systems?
- [ ] Are there any UI issues? (Check with Playwright MCP)
- [ ] Did I use appropriate subagents for review/testing/commits?
