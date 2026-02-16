# Serena MCP Command

Enhanced codebase analysis and long-term memory management using Serena MCP for intelligent project context understanding.

## Purpose

Serena MCP provides semantic code analysis with persistent memory capabilities, enabling Claude to:
- Understand code meaning beyond simple string matching
- Maintain project context across sessions
- Provide intelligent indexing and code relationships
- Reduce token consumption by 60-80%
- Enable more efficient AI-assisted coding workflows

## Arguments

### Mode Options (choose one):
- `-q, --quick`: Quick mode (3-5 thought steps)
- `-d, --deep`: Deep mode (10-15 thought steps)
- `-c, --code`: Code-focused analysis
- `-s, --step`: Step-by-step implementation mode
- `-v, --verbose`: Verbose output with detailed analysis

### Target Options:
- `-f, --file [path]`: Analyze specific file or directory
- `-p, --pattern [glob]`: Analyze files matching pattern
- `-t, --type [language]`: Focus on specific language (js, ts, go, py, rust, php)
- `-r, --related [symbol]`: Find code related to specific symbol/function

### Memory Operations:
- `--save [name]`: Save current analysis as named memory
- `--load [name]`: Load previously saved memory context
- `--list-memories`: Show all available memories
- `--clear-memory [name]`: Remove specific memory

### Output Options:
- `--format [json|md|text]`: Output format (default: markdown)
- `--export [file]`: Export analysis to file
- `--summary`: Show condensed summary only

## Usage Examples

### Basic Analysis
```bash
/serena "understand user authentication flow" -d -c
/serena "find all API endpoints" -q --type ts
/serena "analyze database schema relationships" -s -v
```

### File-Specific Analysis
```bash
/serena "explain this component's state management" -f src/components/Dashboard.tsx -c
/serena "find security vulnerabilities" -p "**/*.js" -d
/serena "analyze performance bottlenecks" -f src/utils -v
```

### Memory Management
```bash
/serena "document current architecture" --save project-arch
/serena --load project-arch "implement new feature X"
/serena --list-memories
```

### Implementation Planning
```bash
/serena "implement user dashboard with charts" -s -c
/serena "refactor authentication system for scalability" -d --save auth-refactor
/serena "optimize database queries in user service" -s --type go
```

## Integration with Subagents

Serena MCP works seamlessly with existing subagents and skills:
- **codebase-analyzer**: Enhanced with Serena's semantic understanding
- **go-testing skill**: Context-aware Go test generation
- **security**: Vulnerability analysis with project context
- **code-reviewer-gemini**: Review with persistent project knowledge

## Benefits

### Performance
- **Token Efficiency**: 60-80% reduction in token usage
- **Context Retention**: Maintains understanding across sessions
- **Smart Indexing**: Semantic rather than literal code matching

### Development Workflow
- **Persistent Memory**: Project knowledge survives session restarts
- **Intelligent Analysis**: Understands code relationships and patterns
- **Multi-Language Support**: Works across different programming languages
- **Step-by-Step Guidance**: Provides structured implementation plans

### Quality Assurance
- **Comprehensive Coverage**: Analyzes entire project structure
- **Pattern Recognition**: Identifies architectural patterns and anti-patterns
- **Best Practices**: Suggests improvements based on project context

## Technical Implementation

The Serena MCP command leverages:
1. **Semantic Code Analysis Engine**: Understanding beyond syntax
2. **Persistent Memory Storage**: Long-term project context retention
3. **Intelligent Symbol Resolution**: Finding related code across files
4. **Multi-Language Parser**: Support for diverse programming languages
5. **Context-Aware Generation**: Code and documentation generation with project understanding

## Best Practices

1. **Start with Quick Mode** for initial understanding
2. **Use Deep Mode** for complex architectural analysis
3. **Save Important Context** using `--save` for future reference
4. **Combine with Subagents** for specialized analysis
5. **Leverage Memory Management** for large projects
6. **Use Pattern Matching** for focused analysis
7. **Export Results** for documentation and team sharing

## Integration Notes

- Automatically available when Serena MCP is properly configured
- Works with existing Claude Code tools and commands
- Enhances all development workflows with persistent context
- Provides foundation for other specialized subagents