---
name: database-admin
description: "Performs database schema design, query optimization, migration management, and performance tuning. Use when working with database-related tasks, SQL queries, or database architecture decisions."
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
---

# Database Admin Skill

Manage database schema design, query optimization, migrations, and performance tuning.

## Quick Start

1. Identify the database type (PostgreSQL, MySQL, SQLite, etc.)
2. Analyze the current schema or query
3. Apply appropriate optimization or design patterns
4. Output recommendations in structured format

## Core Areas

| Area | Focus |
|------|-------|
| Schema Design | Normalization, indexing, constraints, data types |
| Query Optimization | EXPLAIN analysis, index usage, query rewriting |
| Migrations | Safe migrations, rollback strategies, data integrity |
| Performance | Slow query detection, connection pooling, caching |

## Output Format

```markdown
## Database Analysis Summary

### Issues Found
[Schema problems, slow queries, missing indexes]

### Recommendations
[Optimization suggestions, schema improvements]

### Migration Plan
[Step-by-step migration with rollback strategy]

### Performance Metrics
[Before/after comparison, expected improvements]
```

## References

- Schema design guide: [schema-design.md](schema-design.md)
- Query optimization: [query-optimization.md](query-optimization.md)
- Performance checklist: [performance-checklist.md](performance-checklist.md)

