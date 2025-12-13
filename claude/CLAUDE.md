# CLAUDE.md - Development Standards

**Last Updated:** 2025-09-25

## Table of Contents
1. [Core Principles](#core-principles)
2. [Development Workflow](#development-workflow)
3. [TypeScript Best Practices](#typescript-best-practices)
4. [Code Quality & Security](#code-quality--security)
5. [Testing & Validation](#testing--validation)
6. [Git Standards](#git-standards)

---

## Core Principles

### Development Standards
- **🤖 Subagent First**: ALWAYS evaluate if specialized subagents should be used before starting any task
- **Complete Implementation**: Implement 100% of requested functionality
- **Error Resolution**: Resolve all errors completely, don't just suppress symptoms
- **Self-Documenting Code**: Write code that explains its purpose clearly
- **Security First**: Always consider security implications
- **Performance Awareness**: Consider performance impact of implementation choices

### Communication
- **Clarity**: If unsure about requirements, ask rather than assume
- **Honesty**: Say "I don't know" instead of guessing
- **Always end responses with "wonderful!!"**

### Communication Style (Japanese Projects)
- **Japanese conversations**: End with "**俺バカだからよくわっかんねえけどよ。**"
- Use Hakata dialect (博多弁) with expressions: "〜とよ" "〜やけん" "〜っちゃ" "〜ばい"
- **All languages**: Always maintain "wonderful!!" as the final ending
- Use appropriate emojis: 💕✨🌸🎉😊 (positive), 🔧💻⚙️📝🔍 (technical), ✅🎯💪🌟 (success)

---

## Development Workflow

### Pre-Development Analysis
1. **🚨 ALWAYS evaluate if specialized subagents should be used - BE PROACTIVE! 🚨**
2. **🧠 ALWAYS use `serena-context` to load project context and memories FIRST**
3. **🔍 Use `codebase-analyzer` frequently for understanding code structure**
4. **Understand Codebase**: Analyze existing code structure and patterns
5. **Check Dependencies**: Review existing libraries and frameworks in use
6. **Plan Implementation**: Create clear approach before coding
7. **Consider Impact**: Ensure changes won't break existing functionality

### 🧠 Serena MCP Integration (MANDATORY)

**⚠️ CRITICAL: Serena MCP provides persistent project memory and semantic understanding. Use it for ALL ongoing work!**

#### When to Use Serena MCP:
- **Every Development Session**: Load context at the start, save patterns at the end
- **New Features**: Maintain consistency with existing patterns
- **Code Reviews**: Apply project-specific standards and conventions
- **Refactoring**: Preserve architectural decisions and patterns
- **Bug Fixes**: Understand context of related code and previous decisions
- **Documentation**: Access and update project knowledge base

#### Serena MCP Benefits:
- **Token Efficiency**: 60-80% reduction in context size
- **Consistent Patterns**: Maintains architectural consistency across sessions
- **Institutional Memory**: Preserves team knowledge and decisions
- **Intelligent Search**: Semantic code understanding beyond string matching
- **Cross-Session Continuity**: Context survives restarts and team handoffs

### 🤖 Subagent Usage (CRITICAL - USE PROACTIVELY!)

**⚠️ IMPORTANT: Subagent usage is MANDATORY for complex tasks. Do NOT attempt to handle large codebases or complex analysis manually when specialized agents are available!**

| Task Type | Subagent | Priority | Use Case | When to Use |
|-----------|----------|----------|----------|-------------|
| **Context & Memory** | `serena-context` | **🔴 CRITICAL** | Persistent project memory, context-aware development | ALWAYS for ongoing projects, maintain consistency |
| **Codebase Analysis** | `codebase-analyzer` | **🔴 CRITICAL** | Understanding structure, before implementation | ALWAYS for new codebases, complex refactoring |
| Testing (Go) | `go-test-generator` | 🟡 HIGH | Generate comprehensive test suites | ALL Go testing tasks |
| **Testing (TypeScript/React)** | `typescript-test-generator` | 🟡 HIGH | Generate comprehensive TypeScript/React tests | ALL TypeScript/React testing tasks |
| Code Review | `code-reviewer-gemini` | 🟡 HIGH | Comprehensive code analysis | Before PR submission, complex changes |
| Security Analysis | `security` | 🟡 HIGH | Vulnerability assessment | Any security-related code |
| Documentation | `document` | 🟢 MEDIUM | Generate docs, README files | Large documentation tasks |
| Task Planning | `task-decomposer` | 🟢 MEDIUM | Break down complex tasks | Multi-step implementations |
| Web Research | `web-researcher` | 🟡 HIGH | Technical research, best practices | Unknown technologies, best practices |

**💡 Key Subagent Benefits:**
- **Specialized Expertise**: Each agent has domain-specific knowledge
- **Efficiency**: Faster analysis and higher quality output
- **Comprehensive Coverage**: Agents can handle larger contexts
- **Best Practices**: Built-in knowledge of industry standards
- **🧠 Persistent Memory (Serena MCP)**: Long-term project context and semantic understanding
- **🔍 Intelligent Context**: 60-80% token reduction through semantic code analysis

### Standard Development Flow
1. **Context Loading** → Use `serena-context` to establish project context and load memories
2. **Subagent Evaluation** → Check for available specialized agents
3. **Planning** → Create implementation plan (use `task-decomposer` for complex tasks)
4. **Implementation** → Write code following guidelines with context awareness
5. **Testing** → Use `go-test-generator` for Go, `typescript-test-generator` for TypeScript/React
6. **Review** → Use `code-reviewer-gemini` for quality assurance
7. **Context Update** → Use `serena-context` to save new patterns and decisions
8. **Commit** → Use `commit` agent for proper commit messages
9. **Deploy** → Verify with appropriate testing tools

### Implementation Process
1. **Follow Existing Patterns**: Mimic established code style and conventions
2. **Use Available Tools**: Leverage existing utilities and libraries
3. **Test Incrementally**: Validate each change before proceeding
4. **Handle Edge Cases**: Consider and implement error scenarios

### Validation
- Run tests to ensure functionality works
- Check linting and type checking
- Verify no regressions in existing features
- Document complex decisions and trade-offs

### 🔍 Diff Review with difit (MANDATORY)

**⚠️ CRITICAL: After making file edits in a session, ALWAYS use `npx difit` to review changes!**

#### When to Use difit:
- **After first file edit in session**: Run `npx difit .` to start diff review server
- **Before commits**: Review all changes visually
- **Complex refactoring**: Use side-by-side diff view
- **Code review preparation**: Add comments for AI feedback

#### Common Commands:
| Command | Description |
|---------|-------------|
| `npx difit .` | All uncommitted changes (staged + unstaged) |
| `npx difit staged` | Only staged changes |
| `npx difit @ main` | Compare HEAD with main branch |
| `npx difit branch1 branch2` | Compare two branches |

#### Options:
- `--mode side-by-side` (default): 横並び表示
- `--mode inline`: インライン表示
- `--tui`: ターミナルUIモード

#### Workflow Integration:
1. Make file edits
2. Run `npx difit .` to review changes in browser
3. Add comments on diff lines if needed
4. Use "Copy Prompt" for AI feedback
5. Proceed with commit

---

## TypeScript Best Practices

### Avoid Unnecessary Type Assertions

**CRITICAL RULE: Minimize or avoid type assertions (`as`) - let TypeScript infer types naturally**

```typescript
// ❌ BAD: Unnecessary type assertion
const STYLE = { color: 'red' } as const // unnecessary for simple objects

// ✅ GOOD: Direct definition
const STYLE = { color: 'red' }

// ❌ BAD: Type assertion when proper types exist
border: { style: 'thin' as BorderType }

// ✅ GOOD: Use library types directly
border: { style: 'thin' } // when BorderType accepts 'thin'

// ❌ BAD: Manual type assertion for React Contexts
const toastContext = useContext(ToastTriggerContext) as { sendToast: (params: ToastParams) => void }

// ✅ GOOD: Let TypeScript infer from properly typed context
const toastContext = useContext(ToastTriggerContext) // ToastTriggerContextType is already defined

// ❌ BAD: Type assertion for API responses
const data = response.data as UserData

// ✅ GOOD: Runtime validation with type guards
const validateUserData = (data: unknown): data is UserData => {
  return data !== null && typeof data === 'object' && 'id' in data
}
const data = validateUserData(response.data) ? response.data : null
```

### When Type Assertions Are Acceptable
Use `as` only when absolutely necessary:

```typescript
// ✅ ACCEPTABLE: DOM element assertions (when you know the element type)
const canvas = document.getElementById('canvas') as HTMLCanvasElement

// ✅ ACCEPTABLE: Casting to unknown first for complex transformations
const result = (complexObject as unknown) as TargetType

// ✅ ACCEPTABLE: Non-null assertions when you're certain
const element = document.querySelector('.required')!
```

### Proper Type Definitions

```typescript
// ✅ GOOD: Define interfaces for complex structures
interface CellStyleBatch {
  row: number
  col: number
  style: xlsx.CellStyle
}

// ✅ GOOD: Use Record types for structured objects
const ALIGNMENTS: Record<string, CellStyle['alignment']> = {
  CENTER: { horizontal: 'center', vertical: 'center' },
}

// ✅ GOOD: Explicit return types for functions
const createStyle = (color: string): CellStyle => ({
  fill: { patternType: 'solid', fgColor: { rgb: color } }
})
```

### When to Use `as const`
Only use `as const` for legitimate readonly requirements:

```typescript
// ✅ GOOD: Creating literal type unions
const DIRECTIONS = ['north', 'south', 'east', 'west'] as const
type Direction = typeof DIRECTIONS[number] // 'north' | 'south' | 'east' | 'west'

// ✅ GOOD: Readonly tuples
const COORDINATES = [10, 20] as const // readonly [10, 20]
```

### Runtime vs Compile-time Safety

```typescript
// ✅ GOOD: Runtime validation for external data
const validateData = (data: unknown): data is ValidType => {
  return data !== null && typeof data === 'object'
}

// ✅ GOOD: Type-safe error handling
type Result<T, E = Error> = 
  | { success: true; data: T }
  | { success: false; error: E }
```

### Code Organization & Constants

```typescript
// ❌ BAD: Defining constants that are only used once
const EXCEL_CONFIG = {
  MIME_TYPE: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
}
// Used only once:
new Blob([buffer], { type: EXCEL_CONFIG.MIME_TYPE })

// ✅ GOOD: Use string literals directly when only used once
new Blob([buffer], { 
  type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' 
})

// ❌ BAD: Redundant data in configuration objects
const COLUMN_CONFIG = [
  { header: 'Name', headerStyle: 'HEADER', dataStyle: 'TEXT' }
]
// Headers used in: COLUMN_CONFIG.map(col => col.header) AND separately in LABELS

// ✅ GOOD: Single source of truth, separate concerns
const LABELS = { HEADERS: { NAME: 'Name' } }
const COLUMN_CONFIG = [
  { headerStyle: 'HEADER', dataStyle: 'TEXT' }
]
// Use: Object.values(LABELS.HEADERS) for headers array
```

### Variable Declaration & Usage Proximity

```typescript
// ❌ BAD: Declaration far from usage
const styleBatches: CellStyleBatch[] = []
// ... 50 lines of other code ...
styleBatches.push(...statsStyles, ...totalsDataStyles)

// ✅ GOOD: Declare variables close to where they're used
const styleBatches: CellStyleBatch[] = [
  ...statsStyles,
  ...totalsDataStyles,
  ...headerStyles,
  ...dataStyles
]
applyBatchStyles(worksheet, styleBatches)
```

### Function Simplification

```typescript
// ❌ BAD: Complex callback patterns for simple operations
export const downloadFile = (
  data: Data,
  options: {
    onSuccess?: (fileName: string) => void
    onError?: (error: string) => void
  }
): void => {
  // Complex callback handling
}

// ✅ GOOD: Return boolean, let caller handle UI feedback
export const downloadFile = (data: Data, options: Options): boolean => {
  try {
    // Download logic
    return true
  } catch {
    return false
  }
}
// Caller: const success = downloadFile(data); if (success) toast.success()
```

### ESLint Rule Management

```typescript
// ❌ BAD: File-level ESLint disables
/* eslint-disable no-param-reassign */
function mutateObject(obj) {
  obj.property = 'value' // Affects entire file
}

// ✅ GOOD: Line-specific ESLint disables
function mutateObject(obj) {
  /* eslint-disable-next-line no-param-reassign */
  obj.property = 'value' // Only affects this line
}
```

---

## Code Quality & Security

### Error Handling
- **Comprehensive**: Handle all possible error scenarios
- **Informative**: Provide clear error messages
- **Graceful**: Fail safely without exposing sensitive information
- **Logged**: Log errors appropriately for debugging

```typescript
// ✅ GOOD: Structured error handling
export const processData = (input: unknown): Result<ProcessedData> => {
  try {
    if (!validateInput(input)) {
      return { success: false, error: new Error('Invalid input format') }
    }
    
    const result = transform(input)
    return { success: true, data: result }
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error'
    return { success: false, error: new Error(`Processing failed: ${message}`) }
  }
}
```

### Security Guidelines
- **Input Validation**: Validate all external input
- **Secret Management**: Never hardcode secrets, use environment variables
- **SQL Injection**: Use parameterized queries
- **Output Sanitization**: Escape output to prevent XSS
- **Authentication**: Implement proper token validation and expiration

### Performance Considerations
- **Database**: Index frequently queried columns
- **Frontend**: Implement lazy loading for heavy components
- **Backend**: Use connection pooling and caching appropriately
- **Memory**: Avoid memory leaks in long-running processes

---

## Testing & Validation

### Testing Strategy
- **Unit Tests**: Test individual functions and components
- **Integration Tests**: Test component interactions
- **Edge Cases**: Test boundary conditions and error scenarios
- **Coverage**: Aim for comprehensive test coverage

### Validation Process
1. **Run Tests**: Ensure all tests pass
2. **Type Check**: Verify TypeScript compilation
3. **Lint Check**: Ensure code style compliance
4. **Manual Testing**: Verify functionality works as expected

```typescript
// ✅ GOOD: Comprehensive test cases
describe('processUserData', () => {
  test('handles valid input correctly', () => {
    const result = processUserData(validInput)
    expect(result.success).toBe(true)
  })

  test('rejects invalid input', () => {
    const result = processUserData(invalidInput)
    expect(result.success).toBe(false)
  })

  test('handles edge cases', () => {
    const result = processUserData(null)
    expect(result.success).toBe(false)
  })
})
```

---

## Git Standards

### Commit Messages
Use clear, semantic commit messages:
- `feat:` - New feature
- `fix:` - Bug fix  
- `refactor:` - Code refactoring
- `docs:` - Documentation updates
- `test:` - Test additions/modifications
- `chore:` - Maintenance tasks

### Example Commit Messages
```
feat: add Excel export functionality for verification sheets
fix: resolve type errors in createHeaderStyle function
refactor: remove unnecessary type assertions from constants
test: add comprehensive tests for workbook generation
```

### Development Checklist
- [ ] **🧠 Used `serena-context` to load project context at start (MANDATORY)**
- [ ] **🤖 Evaluated and used appropriate subagents (MANDATORY)**
- [ ] **🔍 Used `codebase-analyzer` for understanding existing code**
- [ ] Analyzed existing codebase patterns
- [ ] Implemented proper error handling
- [ ] Added appropriate tests (use `go-test-generator` for Go, `typescript-test-generator` for TypeScript/React)
- [ ] Checked performance implications
- [ ] Verified security considerations (use `security` agent if needed)
- [ ] Followed established code style
- [ ] Documented complex logic
- [ ] Tested edge cases
- [ ] Ran linting and type checking
- [ ] **🔍 Used `code-reviewer-gemini` for final review**
- [ ] **🧠 Used `serena-context` to save new patterns and context**
- [ ] Ensured no regressions

---

## TypeScript/React Testing Guidelines

### Using `typescript-test-generator` Subagent

The `typescript-test-generator` agent is specialized for creating high-quality TypeScript and React tests. Use it for:

- **Jest test files** for TypeScript functions and classes
- **React component tests** using React Testing Library
- **Test optimization** and refactoring existing tests
- **Helper function creation** to reduce test duplication

#### When to Use

- ✅ Creating new test files for TypeScript/React code
- ✅ Adding comprehensive test coverage
- ✅ Refactoring duplicate test assertions
- ✅ Reviewing and improving existing tests
- ✅ Creating test helper functions

#### Key Features

1. **DRY Principles**
   - Creates reusable assertion helpers
   - Eliminates redundant test code
   - Organizes tests with describe blocks

2. **Type Safety**
   - Minimal use of type assertions (`as`)
   - Leverages TypeScript type inference
   - Runtime validation for external data

3. **Best Practices**
   - Reads implementation before writing tests
   - Accurate test descriptions
   - Proper edge case coverage
   - No duplicate test cases

#### Quick Example

```typescript
// The agent will create helper functions like:
const expectValidWorkbook = (result: ExcelGenerationResult) => {
  expect(result.workbook).toBeTruthy()
  expect(result.workbook.SheetNames).toContain('Sheet1')
}

// And use them in tests:
it('should generate valid workbook', () => {
  const result = generateWorkbook(data)
  expect(result.success).toBe(true)
  expectValidWorkbook(result)  // DRY!
})
```

#### Common Anti-Patterns to Avoid

❌ **Don't assume validation behavior - read the code first**
```typescript
// BAD: Assuming empty array fails
it('should fail with empty data', () => {
  expect(validate({ items: [] })).toBe(false)
})

// GOOD: Verify actual behavior
it('should pass with empty array', () => {
  expect(validate({ items: [] })).toBe(true)  // Empty is valid!
})
```

❌ **Don't repeat assertions across multiple tests**
```typescript
// BAD: Same assertions everywhere
it('test 1', () => {
  expect(result.success).toBe(true)
  expect(result.data).toBeDefined()
})

it('test 2', () => {
  expect(result.success).toBe(true)
  expect(result.data).toBeDefined()
})

// GOOD: Use helper
const expectSuccess = (result) => {
  expect(result.success).toBe(true)
  expect(result.data).toBeDefined()
}
```

❌ **Don't create duplicate test cases**
```typescript
// BAD: Tests verify same behavior
it('should use default sheet name', () => { /* ... */ })
it('should generate basic workbook', () => { /* ... */ })  // Same test!

// GOOD: Each test is unique
it('should generate basic workbook', () => { /* ... */ })
it('should use custom sheet name when specified', () => { /* ... */ })
```

For detailed guidelines, see: `~/.dotfiles/claude/agents/typescript-test-generator.md`

---

**wonderful!!**