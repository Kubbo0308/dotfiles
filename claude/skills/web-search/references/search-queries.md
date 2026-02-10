# Effective Search Query Patterns

## Site-Specific Searches

```bash
# X (Twitter)
WebSearch: "site:x.com {topic}"
WebSearch: "site:twitter.com {topic}"

# GitHub
WebSearch: "site:github.com {topic} {language}"

# Stack Overflow
WebSearch: "site:stackoverflow.com {error message}"

# Official docs
WebSearch: "site:{domain}.dev {topic}"
WebSearch: "site:{domain}.io docs {topic}"
```

## Technical Searches

```bash
# With year for recency
WebSearch: "{framework} best practices 2025"

# Error debugging
WebSearch: "{exact error message}"

# Version-specific
WebSearch: "{library} v{version} breaking changes"

# Comparison
WebSearch: "{tool A} vs {tool B} 2025"
```

## X (Twitter) Specific

```bash
# Official announcements
WebSearch: "site:x.com from:{official_account} {topic}"

# Developer discussions
WebSearch: "site:x.com {framework} developers {topic}"

# Release feedback
WebSearch: "site:x.com {library} {version} feedback"
```

## Search Operators

| Operator | Usage | Example |
|----------|-------|---------|
| `site:` | Limit to domain | `site:x.com react` |
| `"exact"` | Exact phrase | `"TypeError: undefined"` |
| `OR` | Either term | `react OR vue` |
| `-term` | Exclude | `javascript -jquery` |
| `after:` | Date filter | `after:2024-01-01` |

## Multi-Source Strategy

1. **Start broad**: WebSearch for general info
2. **Check X**: Real-time community insights
3. **Verify**: Official docs via Context7 or site-specific search
4. **Deep dive**: GitHub issues/discussions for edge cases

