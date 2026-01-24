# Query Performance (Critical Priority)

## Core Principle

Avoid full table scans. Every query on production tables must use indexes efficiently.

## EXPLAIN Analysis

### Always Analyze Before Deploying

```sql
-- Full analysis with timing and buffer info
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM orders WHERE user_id = 123;

-- For queries you can't run (destructive)
EXPLAIN (COSTS, FORMAT TEXT)
DELETE FROM orders WHERE created_at < '2020-01-01';
```

### Warning Signs in EXPLAIN

| Pattern | Problem | Solution |
|---------|---------|----------|
| `Seq Scan` on large table | Full table scan | Add index on filter column |
| `Rows` estimate way off | Stale statistics | Run `ANALYZE table_name` |
| `Sort` without index | In-memory/disk sort | Add index with ORDER BY columns |
| `Nested Loop` with high rows | Cartesian-like join | Review join conditions, add indexes |
| `Hash Join` on huge tables | Memory pressure | Consider LIMIT or partitioning |

### Good Patterns

```
Index Scan using idx_orders_user_id  -- Using index for lookup
Index Only Scan                       -- Covering index, no table access
Bitmap Index Scan                     -- Multiple index combination
```

## Index Strategy

### Composite Index Rules

```sql
-- Index on (a, b, c) supports:
WHERE a = ?                    -- YES
WHERE a = ? AND b = ?          -- YES
WHERE a = ? AND b = ? AND c = ? -- YES
WHERE a = ? AND c = ?          -- PARTIAL (only uses a)
WHERE b = ?                    -- NO
WHERE b = ? AND c = ?          -- NO

-- Order by selectivity: most selective first
CREATE INDEX idx_orders_status_user
ON orders (status, user_id);  -- status has fewer values
```

### Covering Indexes

```sql
-- Include columns to avoid table lookup
CREATE INDEX idx_users_email_covering
ON users (email) INCLUDE (name, created_at);

-- Query uses Index Only Scan
SELECT name, created_at FROM users WHERE email = 'x@example.com';
```

### Partial Indexes

```sql
-- Index only relevant rows
CREATE INDEX idx_orders_pending
ON orders (created_at)
WHERE status = 'pending';

-- Much smaller, faster for common queries
SELECT * FROM orders WHERE status = 'pending' ORDER BY created_at;
```

### Concurrent Index Creation

```sql
-- CRITICAL: Prevents table locking
CREATE INDEX CONCURRENTLY idx_users_email
ON users (email);

-- May fail if duplicates exist for unique index
CREATE UNIQUE INDEX CONCURRENTLY idx_users_email_unique
ON users (email);
-- Check pg_stat_progress_create_index for status
```

## Anti-Patterns

### Function on Indexed Column

```sql
-- BAD: Can't use index
SELECT * FROM users WHERE LOWER(email) = 'test@example.com';

-- GOOD: Functional index
CREATE INDEX idx_users_email_lower ON users (LOWER(email));
SELECT * FROM users WHERE LOWER(email) = 'test@example.com';

-- BETTER: Store normalized
ALTER TABLE users ADD COLUMN email_normalized VARCHAR(255);
CREATE INDEX idx_users_email_norm ON users (email_normalized);
```

### Large OFFSET Pagination

```sql
-- BAD: Scans and discards 10000 rows
SELECT * FROM posts ORDER BY created_at DESC LIMIT 20 OFFSET 10000;

-- GOOD: Keyset pagination
SELECT * FROM posts
WHERE created_at < '2024-01-01T00:00:00Z'
ORDER BY created_at DESC
LIMIT 20;

-- BETTER: Cursor-based with ID
SELECT * FROM posts
WHERE (created_at, id) < ('2024-01-01T00:00:00Z', 12345)
ORDER BY created_at DESC, id DESC
LIMIT 20;
```

### SELECT *

```sql
-- BAD: Fetches unnecessary data
SELECT * FROM users WHERE id = 1;

-- GOOD: Explicit columns
SELECT id, name, email FROM users WHERE id = 1;
```

### IN with Large Lists

```sql
-- BAD: Query plan bloat
SELECT * FROM users WHERE id IN (1, 2, 3, ... 1000 more);

-- GOOD: Use ANY with array
SELECT * FROM users WHERE id = ANY(ARRAY[1, 2, 3, ...]);

-- BETTER: Temp table for very large lists
CREATE TEMP TABLE lookup_ids (id INTEGER PRIMARY KEY);
INSERT INTO lookup_ids VALUES (1), (2), (3), ...;
SELECT u.* FROM users u JOIN lookup_ids l ON u.id = l.id;
```

## Performance Checklist

- [ ] All WHERE columns have appropriate indexes
- [ ] All JOIN columns have indexes
- [ ] All ORDER BY columns have indexes (in correct order)
- [ ] No function calls on indexed columns in WHERE
- [ ] EXPLAIN shows Index Scan, not Seq Scan
- [ ] Estimated rows close to actual rows
- [ ] Using keyset pagination for large offsets
- [ ] SELECT only needed columns

