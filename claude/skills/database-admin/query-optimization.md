# Query Optimization Guide

## EXPLAIN Analysis

### Reading EXPLAIN Output
```sql
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';
```

### Key Metrics to Watch
| Metric | Description | Target |
|--------|-------------|--------|
| Seq Scan | Full table scan | Avoid on large tables |
| Index Scan | Uses index | Preferred for selective queries |
| Rows | Estimated vs actual | Should be close |
| Cost | Execution cost | Lower is better |
| Buffers | Memory usage | Monitor for large queries |

### Warning Signs
- `Seq Scan` on large tables
- Large difference between estimated and actual rows
- `Sort` operations without index
- `Hash Join` on very large datasets
- Nested loops with high row counts

## Index Optimization

### Composite Index Order
```sql
-- Index on (a, b, c) can be used for:
-- WHERE a = ?
-- WHERE a = ? AND b = ?
-- WHERE a = ? AND b = ? AND c = ?
-- But NOT for:
-- WHERE b = ?
-- WHERE c = ?
-- WHERE b = ? AND c = ?

CREATE INDEX idx_orders_status_date ON orders (status, created_at);
```

### Covering Indexes
```sql
-- Include all queried columns to avoid table lookup
CREATE INDEX idx_users_email_name ON users (email) INCLUDE (name, created_at);
```

### Partial Indexes
```sql
-- Index only relevant rows
CREATE INDEX idx_orders_pending ON orders (created_at)
WHERE status = 'pending';
```

## Query Rewriting Patterns

### Avoid SELECT *
```sql
-- Bad
SELECT * FROM users WHERE id = 1;

-- Good
SELECT id, name, email FROM users WHERE id = 1;
```

### Use EXISTS Instead of IN for Subqueries
```sql
-- Slower
SELECT * FROM orders WHERE user_id IN (SELECT id FROM users WHERE active = true);

-- Faster
SELECT * FROM orders o WHERE EXISTS (
    SELECT 1 FROM users u WHERE u.id = o.user_id AND u.active = true
);
```

### Avoid Functions on Indexed Columns
```sql
-- Bad (can't use index)
SELECT * FROM users WHERE LOWER(email) = 'test@example.com';

-- Good (use functional index or store lowercase)
CREATE INDEX idx_users_email_lower ON users (LOWER(email));
-- Or
SELECT * FROM users WHERE email = 'test@example.com';
```

### Pagination Optimization
```sql
-- Bad for large offsets
SELECT * FROM posts ORDER BY created_at DESC LIMIT 20 OFFSET 10000;

-- Good: Keyset pagination
SELECT * FROM posts
WHERE created_at < '2024-01-01'
ORDER BY created_at DESC
LIMIT 20;
```

## JOIN Optimization

### Join Order Matters
- Start with the smallest result set
- Filter early with WHERE clauses
- Use appropriate join types

### JOIN Types Performance
| Type | Use Case |
|------|----------|
| INNER JOIN | Most common, both sides must match |
| LEFT JOIN | Keep all left rows, nullable right |
| EXISTS | Check existence only |
| NOT EXISTS | Check non-existence |

### Avoid Cartesian Products
```sql
-- Always have join conditions
SELECT * FROM a, b WHERE a.id = b.a_id;  -- Implicit join
SELECT * FROM a JOIN b ON a.id = b.a_id; -- Explicit join (preferred)
```

## Common Anti-Patterns

### N+1 Query Problem
```sql
-- Bad: Loop queries
FOR each user IN users:
    SELECT * FROM orders WHERE user_id = user.id;

-- Good: Single query with JOIN
SELECT u.*, o.* FROM users u
LEFT JOIN orders o ON u.id = o.user_id;
```

### Over-fetching
```sql
-- Bad
SELECT * FROM large_table;

-- Good
SELECT needed_columns FROM large_table WHERE condition LIMIT 100;
```

