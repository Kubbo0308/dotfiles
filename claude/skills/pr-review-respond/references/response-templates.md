# Response Templates Reference

Templates for replying to review comments before resolving threads.

## Dismiss Templates

### False Positive (Bot/Linter)

```markdown
This is a false positive. [Specific reason]:

- [Evidence: e.g., "The variable `x` is used in `test_file.go:25`"]
- [Reference: e.g., "Per project convention in `.golangci.yml`, this rule is disabled"]

Resolving this thread.
```

### Already Handled

```markdown
This is already handled by [specific location]:

- `path/to/file.go:XX` - [description of existing handling]

The [check/validation/error handling] covers this case because [reason].

Resolving this thread.
```

### Intentional Design Decision

```markdown
This is intentional. [Brief explanation]:

- **Reason**: [Why this approach was chosen]
- **Alternative considered**: [What the reviewer suggested and why it wasn't used]
- **Reference**: [Link to ADR, design doc, or convention if applicable]

Resolving this thread.
```

### Style Preference (Not Project Convention)

```markdown
Thank you for the suggestion. This follows the project's established convention:

- [Reference to project style guide, existing patterns, or linter config]
- [Example of same pattern used elsewhere in codebase]

Resolving this thread.
```

### Outdated Comment

```markdown
This was addressed in a subsequent commit:

- Commit: `abc1234` - [commit message]
- The code at this location has been updated since this review.

Resolving this thread.
```

### Question Response

```markdown
Good question! [Direct answer]:

- [Explanation with context]
- [Reference if applicable]

Resolving this thread.
```

### Nit (Trivial, Not Fixing)

```markdown
Noted, but keeping as-is for now:

- [Reason: e.g., "Consistent with surrounding code style", "Minimal impact"]
- Will consider in a future cleanup if needed.

Resolving this thread.
```

## Fix Acknowledgment Templates

### Before Fixing

```markdown
Valid point. Fixing this now:

- [Brief description of what will be changed]
```

### After Fixing (Reply Before Resolving)

```markdown
Fixed in commit `abc1234`:

- [Description of the fix applied]

Resolving this thread.
```

## Batch Summary Template

For PR-level comment summarizing all actions:

```markdown
## Review Feedback Response

Addressed all review comments:

### Dismissed (with reasoning)
| # | Reviewer | Reason |
|---|----------|--------|
| 1 | @reviewer | False positive - [brief reason] |
| 2 | @bot | Already handled in `file.go:XX` |

### Fixed
| # | Reviewer | Fix |
|---|----------|-----|
| 1 | @reviewer | Added nil check in `handler.go:42` |
| 2 | @reviewer | Improved error message in `service.go:15` |

All threads resolved. Requesting re-review.
```

## Tone Guidelines

| Do | Don't |
|----|-------|
| Be concise and specific | Write lengthy justifications |
| Reference code/docs as evidence | Make vague claims |
| Acknowledge the reviewer's perspective | Be dismissive or condescending |
| Use neutral, professional tone | Use emotional language |
| Thank for valid catches | Apologize excessively |

## Language

- Write responses in **English** (GitHub convention)
- Keep responses under 5 lines for dismissals
- Include code references with `path:line` format
- Use backticks for code, file paths, and variable names
