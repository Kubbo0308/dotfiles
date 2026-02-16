# /add-feature

## Overview

Creates a new feature according to the contents of the CLAUDE.md file and the current repository coding standards.

## Command Usage

```
/add-feature [FEATURE_NAME]
```

## Steps

1. **Feature Planning Analysis**
   - Read and analyze CLAUDE.md file to understand project requirements and standards
   - Check for existing similar features in `/log/feature/` directory
   - Review current repository coding standards and conventions

2. **Investigation Phase** (if required)
   - Use `context7` MCP tool with multiple sub-agents to gather relevant context
   - Use `brave-search` MCP tool with multiple sub-agents for external research
   - Analyze existing codebase patterns and architecture

3. **Feature Design**
   - Create feature specification based on CLAUDE.md guidelines
   - Plan implementation approach following repository standards
   - Identify required components, files, and dependencies

4. **Orchestrated Implementation**
   - Use orchestrator commands for planning and execution
   - Refer to `~/.claude/commands/orchestrator.md` for detailed orchestrator command information
   - Coordinate feature development through orchestrator workflow

5. **Feature Development**
   - Implement feature according to planned specification
   - Follow established coding standards and patterns
   - Ensure compatibility with existing codebase

6. **Documentation and Logging**
   - Create feature documentation in `/log/feature/` directory
   - Update relevant project documentation
   - Log implementation details and decisions

## MCP Tools Used

- **context7 MCP**: For gathering contextual information about the codebase and requirements (executed by multiple sub-agents)
- **brave-search MCP**: For researching best practices and external resources (executed by multiple sub-agents)

## Sub-Agent Strategy

When using MCP tools, distribute the work across multiple sub-agents:
- **Context Analysis Sub-Agent**: Use context7 to understand existing codebase structure
- **Research Sub-Agent**: Use brave-search for external best practices and solutions
- **Standards Sub-Agent**: Analyze repository coding standards and conventions
- **Feature Planning Sub-Agent**: Coordinate feature design and specification

## Orchestrator Integration

- Execute planning and implementation through orchestrator commands
- Reference `~/.claude/commands/orchestrator.md` for complete orchestrator command documentation
- Coordinate complex feature development workflows using orchestrator patterns

## Dependencies

- **CLAUDE.md**: Project requirements and feature guidelines
- **Repository coding standards**: Established patterns and conventions
- **`/log/feature/` directory**: Feature documentation and history
- **Orchestrator commands**: Available at `~/.claude/commands/orchestrator.md`

## Output

- Fully implemented feature following project standards
- Feature documentation in `/log/feature/[FEATURE_NAME].md`
- Updated project documentation as needed
