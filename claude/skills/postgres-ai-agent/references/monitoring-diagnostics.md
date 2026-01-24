# Monitoring & Diagnostics (Low-Medium Priority)

## Core Principle

Monitor proactively. Identify issues before they become outages.

## Essential Metrics

### Connection Monitoring

```sql
-- Current connections by state
SELECT state, count(*)
FROM pg_stat_activity
GROUP BY state;

-- Connections approaching limit
SELECT
    max_conn.setting::int AS max_connections,
    current_conn.count AS current_connections,
    max_conn.setting::int - current_conn.count AS available
FROM
    (SELECT setting FROM pg_settings WHERE name = 'max_connections') max_conn,
    (SELECT count(*) FROM pg_stat_activity) current_conn;

-- Connection age
SELECT
    pid,
    usename,
    application_name,
    now() - backend_start AS connection_age,
    state
FROM pg_stat_activity
ORDER BY connection_age DESC
LIMIT 10;
```

### Query Performance

```sql
-- Enable pg_stat_statements (requires extension)
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Top queries by total time
SELECT
    substring(query, 1, 100) AS query,
    calls,
    round(total_exec_time::numeric, 2) AS total_ms,
    round(mean_exec_time::numeric, 2) AS mean_ms,
    round(stddev_exec_time::numeric, 2) AS stddev_ms,
    rows
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;

-- Queries with high variance (inconsistent performance)
SELECT
    substring(query, 1, 100) AS query,
    calls,
    round(mean_exec_time::numeric, 2) AS mean_ms,
    round(stddev_exec_time::numeric, 2) AS stddev_ms,
    round(stddev_exec_time / nullif(mean_exec_time, 0) * 100, 2) AS cv_percent
FROM pg_stat_statements
WHERE calls > 100
ORDER BY cv_percent DESC
LIMIT 20;

-- Currently running queries
SELECT
    pid,
    now() - query_start AS duration,
    state,
    substring(query, 1, 200) AS query
FROM pg_stat_activity
WHERE state = 'active'
ORDER BY duration DESC;
```

### Table Statistics

```sql
-- Table sizes
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname || '.' || tablename)) AS table_size,
    pg_size_pretty(pg_indexes_size(schemaname || '.' || tablename::regclass)) AS index_size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname || '.' || tablename) DESC;

-- Table bloat (dead tuples)
SELECT
    schemaname,
    relname,
    n_live_tup,
    n_dead_tup,
    round(n_dead_tup::numeric / nullif(n_live_tup + n_dead_tup, 0) * 100, 2) AS dead_ratio,
    last_vacuum,
    last_autovacuum
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC
LIMIT 20;

-- Sequential scans (potential missing indexes)
SELECT
    schemaname,
    relname,
    seq_scan,
    seq_tup_read,
    idx_scan,
    round(seq_tup_read::numeric / nullif(seq_scan, 0), 0) AS avg_rows_per_seq_scan
FROM pg_stat_user_tables
WHERE seq_scan > 100
ORDER BY seq_tup_read DESC
LIMIT 20;
```

### Index Usage

```sql
-- Unused indexes
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan AS times_used,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
AND indexrelname NOT LIKE '%_pkey'
ORDER BY pg_relation_size(indexrelid) DESC;

-- Index efficiency
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch,
    round(idx_tup_fetch::numeric / nullif(idx_tup_read, 0) * 100, 2) AS fetch_ratio
FROM pg_stat_user_indexes
WHERE idx_scan > 0
ORDER BY idx_scan DESC
LIMIT 20;

-- Duplicate indexes
SELECT
    a.indrelid::regclass AS table,
    a.indexrelid::regclass AS index1,
    b.indexrelid::regclass AS index2,
    pg_size_pretty(pg_relation_size(a.indexrelid)) AS size1,
    pg_size_pretty(pg_relation_size(b.indexrelid)) AS size2
FROM pg_index a
JOIN pg_index b ON a.indrelid = b.indrelid
    AND a.indexrelid < b.indexrelid
    AND a.indkey = b.indkey;
```

## Debugging Queries

### EXPLAIN Analysis

```sql
-- Basic explain
EXPLAIN SELECT * FROM orders WHERE user_id = 1;

-- With execution stats
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM orders WHERE user_id = 1;

-- JSON format for tools
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT * FROM orders WHERE user_id = 1;

-- Without actually running (for DELETE/UPDATE)
EXPLAIN (COSTS)
DELETE FROM orders WHERE created_at < '2020-01-01';
```

### Key EXPLAIN Metrics

| Metric | Description | Action |
|--------|-------------|--------|
| `Seq Scan` | Full table scan | Add index |
| `Rows` mismatch | Stale statistics | Run ANALYZE |
| `Sort` without index | Memory/disk sort | Add index |
| `Nested Loop` high rows | Bad join | Review join, add index |
| `Buffers: shared hit` | From cache | Good |
| `Buffers: shared read` | From disk | May need more memory |

### Troubleshooting Lock Issues

```sql
-- View current locks
SELECT
    l.locktype,
    l.relation::regclass,
    l.mode,
    l.granted,
    l.pid,
    a.usename,
    a.query
FROM pg_locks l
JOIN pg_stat_activity a ON l.pid = a.pid
WHERE l.relation IS NOT NULL
ORDER BY l.relation, l.mode;

-- Find blocking queries
SELECT
    blocked.pid AS blocked_pid,
    blocked.query AS blocked_query,
    blocked.wait_event_type,
    blocking.pid AS blocking_pid,
    blocking.query AS blocking_query,
    now() - blocked.query_start AS blocked_duration
FROM pg_stat_activity blocked
JOIN pg_stat_activity blocking
    ON blocking.pid = ANY(pg_blocking_pids(blocked.pid))
ORDER BY blocked_duration DESC;
```

## Alerting Thresholds

### Suggested Alerts

| Metric | Warning | Critical |
|--------|---------|----------|
| Connection usage | 70% | 90% |
| Query duration | 10s | 60s |
| Replication lag | 10s | 60s |
| Dead tuple ratio | 10% | 25% |
| Disk usage | 70% | 85% |
| Cache hit ratio | < 95% | < 90% |

### Cache Hit Ratio

```sql
-- Database cache hit ratio
SELECT
    datname,
    round(
        blks_hit::numeric / nullif(blks_hit + blks_read, 0) * 100,
        2
    ) AS cache_hit_ratio
FROM pg_stat_database
WHERE datname = current_database();

-- Table cache hit ratio
SELECT
    schemaname,
    relname,
    round(
        heap_blks_hit::numeric / nullif(heap_blks_hit + heap_blks_read, 0) * 100,
        2
    ) AS cache_hit_ratio
FROM pg_statio_user_tables
ORDER BY heap_blks_hit + heap_blks_read DESC
LIMIT 20;
```

## Maintenance Operations

### Vacuum and Analyze

```sql
-- Manual vacuum (reclaim space)
VACUUM (VERBOSE) table_name;

-- Full vacuum (rewrites table, locks it)
VACUUM FULL table_name;  -- Use with caution!

-- Analyze (update statistics)
ANALYZE table_name;

-- Combined
VACUUM ANALYZE table_name;

-- Check autovacuum settings
SELECT name, setting
FROM pg_settings
WHERE name LIKE '%autovacuum%';
```

### Reindex

```sql
-- Reindex table (blocks writes)
REINDEX TABLE table_name;

-- Concurrent reindex (Postgres 12+)
REINDEX TABLE CONCURRENTLY table_name;

-- Reindex specific index
REINDEX INDEX CONCURRENTLY idx_users_email;
```

## Supabase-Specific

### Dashboard Queries

```sql
-- Supabase connection info
SELECT * FROM pg_stat_ssl;

-- API request stats (if using PostgREST)
SELECT * FROM pg_stat_statements
WHERE query LIKE '%/* source: PostgREST%'
ORDER BY total_exec_time DESC
LIMIT 20;
```

## Checklist

- [ ] pg_stat_statements enabled
- [ ] Regular review of slow queries
- [ ] Monitoring connection count
- [ ] Index usage tracked
- [ ] Dead tuple ratio acceptable
- [ ] Cache hit ratio > 95%
- [ ] Autovacuum working properly
- [ ] Alerts configured for key metrics

