# Database Performance Checklist

## Daily Checks

- [ ] Review slow query log
- [ ] Check active connections count
- [ ] Monitor replication lag (if applicable)
- [ ] Verify backup completion

## Weekly Checks

- [ ] Analyze query patterns and frequency
- [ ] Review index usage statistics
- [ ] Check table bloat levels
- [ ] Monitor disk space usage

## Monthly Checks

- [ ] Full EXPLAIN analysis on critical queries
- [ ] Review and update table statistics
- [ ] Audit unused indexes
- [ ] Evaluate connection pool settings

## Slow Query Detection

### PostgreSQL
```sql
-- Find slow queries
SELECT pid, now() - pg_stat_activity.query_start AS duration, query, state
FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > interval '5 seconds';

-- Top 10 slowest queries (pg_stat_statements)
SELECT query, calls, mean_time, total_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;
```

### MySQL
```sql
-- Enable slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;

-- Find running queries
SELECT * FROM information_schema.processlist
WHERE time > 5 AND command != 'Sleep';
```

## Index Analysis

### PostgreSQL
```sql
-- Unused indexes
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY pg_relation_size(indexrelid) DESC;

-- Missing indexes (sequential scans on large tables)
SELECT schemaname, relname, seq_scan, seq_tup_read,
       idx_scan, idx_tup_fetch
FROM pg_stat_user_tables
WHERE seq_scan > 0
ORDER BY seq_tup_read DESC
LIMIT 20;
```

### MySQL
```sql
-- Unused indexes
SELECT * FROM sys.schema_unused_indexes;

-- Index statistics
SHOW INDEX FROM table_name;
```

## Table Maintenance

### PostgreSQL
```sql
-- Check table bloat
SELECT schemaname, tablename,
       pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size,
       n_dead_tup, n_live_tup,
       round(n_dead_tup::numeric / nullif(n_live_tup, 0) * 100, 2) as dead_ratio
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC
LIMIT 20;

-- Vacuum and analyze
VACUUM ANALYZE table_name;

-- Reindex
REINDEX TABLE table_name;
```

### MySQL
```sql
-- Check table status
SHOW TABLE STATUS LIKE 'table_name';

-- Optimize table
OPTIMIZE TABLE table_name;

-- Analyze table
ANALYZE TABLE table_name;
```

## Connection Pool Settings

### Recommended Settings
| Pool Size | Connections | Use Case |
|-----------|-------------|----------|
| Small | 5-10 | Development |
| Medium | 20-50 | Small production |
| Large | 50-100 | High traffic |

### Formula
```
connections = (core_count * 2) + effective_spindle_count
```

## Performance Tuning Parameters

### PostgreSQL
```ini
# Memory
shared_buffers = 25% of RAM
effective_cache_size = 75% of RAM
work_mem = RAM / max_connections / 4
maintenance_work_mem = 512MB to 2GB

# Checkpoints
checkpoint_completion_target = 0.9
wal_buffers = 64MB

# Query Planning
random_page_cost = 1.1 (SSD) or 4.0 (HDD)
effective_io_concurrency = 200 (SSD) or 2 (HDD)
```

### MySQL
```ini
# Buffer Pool
innodb_buffer_pool_size = 70-80% of RAM
innodb_buffer_pool_instances = 8

# Log Files
innodb_log_file_size = 1-2GB
innodb_log_buffer_size = 64MB

# Connections
max_connections = 500
thread_cache_size = 100
```

## Migration Safety Checklist

- [ ] Test migration on staging first
- [ ] Create backup before migration
- [ ] Prepare rollback script
- [ ] Schedule during low-traffic period
- [ ] Monitor locks during migration
- [ ] Verify data integrity after migration
- [ ] Update application if schema changed

