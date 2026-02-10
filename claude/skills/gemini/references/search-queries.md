# Effective Search Patterns with Gemini CLI

Gemini CLI has **built-in Google Search grounding** - no `WebSearch:` prefix needed.

## Technical Documentation

```bash
gemini -p "React hooks best practices 2026"
gemini -p "Go error handling patterns idiomatic"
gemini -p "TypeScript 5.x strict mode migration guide"
gemini -p "nix-darwin configuration options reference"
```

## Error Debugging

```bash
# Use exact error messages
gemini -p "TypeError cannot read property of undefined JavaScript"
gemini -p "ECONNREFUSED 127.0.0.1:5432 postgres connection"
gemini -p "nix-darwin activate-system fails on boot macOS"
```

## Framework & Library Research

```bash
gemini -p "Next.js 15 app router migration guide 2026"
gemini -p "Tailwind CSS v4 breaking changes from v3"
gemini -p "OpenAI API rate limits and pricing 2026"
```

## X (Twitter) / Social Search

```bash
gemini -p "site:x.com react team announcement 2026"
gemini -p "site:x.com typescript 5.x developer feedback"
gemini -p "site:x.com vercel next.js release"
```

**IMPORTANT**: Always verify X results with official sources.
See `web-search` skill for full verification guidelines.

## Site-Specific Patterns

```bash
# GitHub issues/discussions
gemini -p "site:github.com nix-darwin activate-system issue"

# Stack Overflow
gemini -p "site:stackoverflow.com React useEffect cleanup async"

# Official docs
gemini -p "site:react.dev concurrent features guide"
```

## Combining Stdin + Search

```bash
# Pass code context with search query
cat src/api.ts | gemini -p "what are best practices for this pattern? search for latest recommendations"

# Error log analysis with web search
npm test 2>&1 | gemini -p "explain and find solutions for these failures"
```

## JSON Output for Parsing

```bash
# Get structured results
gemini -p "compare React vs Vue vs Svelte performance 2026" -o json

# Stream results
gemini -p "latest Node.js security advisories" -o stream-json
```

## Multi-Source Strategy

For comprehensive research, combine approaches:

1. `gemini -p "topic"` - General search with Google grounding
2. `gemini -p "site:github.com topic"` - Code & issues
3. `gemini -p "site:x.com topic"` - Community pulse
4. Cross-reference findings across sources
