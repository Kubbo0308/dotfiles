# Effective Search Query Patterns

## Technical Documentation

```bash
gemini -p "WebSearch: React hooks best practices 2026"
gemini -p "WebSearch: Go error handling patterns idiomatic"
gemini -p "WebSearch: TypeScript 5.x strict mode migration guide"
```

## Error Debugging

```bash
# Use exact error messages
gemini -p "WebSearch: TypeError cannot read property of undefined JavaScript"
gemini -p "WebSearch: ECONNREFUSED 127.0.0.1:5432 postgres"
gemini -p "WebSearch: nix-darwin activate-system fails on boot macOS"
```

## Framework & Library Research

```bash
gemini -p "WebSearch: Next.js 15 app router migration guide 2026"
gemini -p "WebSearch: Tailwind CSS v4 breaking changes"
gemini -p "WebSearch: OpenAI API rate limits pricing 2026"
```

## X (Twitter) Search

**IMPORTANT: Always verify X results with official sources.**

```bash
# Developer announcements
gemini -p "WebSearch: site:x.com react team announcement 2026"

# Community feedback
gemini -p "WebSearch: site:x.com typescript 5.x developer feedback"

# Release news
gemini -p "WebSearch: site:x.com vercel next.js release"
```

### Verification Required

X results MUST be cross-referenced because:
- Unverified accounts can post misleading info
- Outdated tweets may appear in results
- Context may be missing from short posts

See `web-search` skill for full verification guidelines.

## Site-Specific Patterns

```bash
# GitHub
gemini -p "WebSearch: site:github.com nix-darwin activate-system issue"

# Stack Overflow
gemini -p "WebSearch: site:stackoverflow.com React useEffect cleanup async"

# Official docs
gemini -p "WebSearch: site:reactjs.org concurrent features guide"
```

## Search Operators

| Operator | Example | Purpose |
|----------|---------|---------|
| `site:` | `site:x.com query` | Limit to specific site |
| `"exact"` | `"exact error message"` | Exact phrase match |
| `OR` | `React OR Vue performance` | Either term |
| `-` | `JavaScript -jQuery` | Exclude term |
| `after:` | `after:2025 query` | Recent results only |

## Multi-Source Strategy

For comprehensive research, combine sources:

1. `gemini -p "WebSearch: topic"` - General web
2. `gemini -p "WebSearch: site:github.com topic"` - Code & issues
3. `gemini -p "WebSearch: site:x.com topic"` - Community pulse
4. Cross-reference findings across sources
