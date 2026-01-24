---
name: postgres-ai-agent
description: "PostgreSQL best practices for AI agents based on Supabase Agent Skills. Covers query performance, connection management, RLS security, schema design, concurrency, and monitoring."
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - mcp__context7__resolve-library-id
  - mcp__context7__get-library-docs
---

# PostgreSQL Best Practices for AI Agents

Based on [Supabase Agent Skills](https://supabase.com/blog/postgres-best-practices-for-ai-agents) - 30 curated rules across 8 categories.

## Priority Categories

| Priority | Category | Focus |
|----------|----------|-------|
| **Critical** | Query Performance | Avoid full table scans, efficient queries |
| **Critical** | Connection Management | Pooling, lifecycle, resource limits |
| **Critical** | Security & RLS | Row Level Security, access control |
| **High** | Schema Design | Table structure, data types, normalization |
| **Medium-High** | Concurrency & Locking | Transaction isolation, deadlock prevention |
| **Medium** | Data Access Patterns | Pagination, bulk operations |
| **Low-Medium** | Monitoring & Diagnostics | Query analysis, debugging |
| **Low** | Advanced Features | CTEs, window functions, extensions |

## Quick Reference

### Critical Warnings (Agent Must Flag)

1. **Index creation locks tables** - Use `CREATE INDEX CONCURRENTLY`
2. **RLS bypass risks** - Always `FORCE ROW LEVEL SECURITY`
3. **Hidden full table scans** - Check EXPLAIN for `Seq Scan`
4. **Missing FK indexes** - Always index foreign key columns

### Connection Management

```sql
-- Connection pool sizing formula
connections = (core_count * 2) + effective_spindle_count

-- Check active connections
SELECT count(*) FROM pg_stat_activity WHERE state = 'active';

-- Kill long-running queries
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE duration > interval '5 minutes';
```

### Row Level Security (RLS)

```sql
-- Enable and enforce RLS
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders FORCE ROW LEVEL SECURITY;

-- Create user-scoped policy
CREATE POLICY orders_user_policy ON orders
USING (user_id = auth.uid());

-- Admin bypass policy
CREATE POLICY admin_all ON orders
TO admin_role
USING (true);
```

### Query Performance

```sql
-- Always check query plan
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) SELECT ...;

-- Watch for these in EXPLAIN:
-- - Seq Scan on large tables (BAD)
-- - Nested Loop with high rows (BAD)
-- - Sort without index (BAD)
-- - Index Scan (GOOD)
-- - Index Only Scan (BEST)
```

## Output Format

```markdown
## PostgreSQL Analysis

### Issues Found
- [Severity] Description
  - File/Location: path:line
  - Impact: What could go wrong
  - Fix: How to resolve

### Security Concerns
- [ ] RLS enabled and enforced
- [ ] Policies cover all operations (SELECT, INSERT, UPDATE, DELETE)
- [ ] No SECURITY DEFINER functions without explicit policy

### Performance Recommendations
- [ ] Indexes on WHERE columns
- [ ] Indexes on JOIN columns
- [ ] Indexes on FK columns
- [ ] No function calls on indexed columns in WHERE

### Migration Safety
- [ ] CONCURRENTLY for index creation
- [ ] Rollback script prepared
- [ ] Tested on staging
```

## References

- Query performance: [query-performance.md](references/query-performance.md)
- Connection management: [connection-management.md](references/connection-management.md)
- RLS patterns: [rls-security.md](references/rls-security.md)
- Schema design: [schema-design.md](references/schema-design.md)
- Concurrency: [concurrency-locking.md](references/concurrency-locking.md)
- Monitoring: [monitoring-diagnostics.md](references/monitoring-diagnostics.md)

## Integration with Supabase MCP

When using Supabase MCP server, this skill provides the judgment layer while MCP provides execution:

```
Agent + Supabase MCP = Execution capability
Agent + This Skill = Sound judgment
Agent + Both = Production-ready database work
```

