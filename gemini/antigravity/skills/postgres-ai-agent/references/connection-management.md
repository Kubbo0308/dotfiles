# Connection Management (Critical Priority)

## Core Principle

Database connections are expensive resources. Pool them, limit them, and clean them up.

## Connection Pooling

### Pool Sizing Formula

```
optimal_connections = (core_count * 2) + effective_spindle_count

Example: 4 cores, SSD
= (4 * 2) + 1 = 9 connections per pool
```

### Pool Configuration

```ini
# PgBouncer (recommended for Supabase)
[pgbouncer]
pool_mode = transaction          # Best for web apps
max_client_conn = 1000           # Client connections
default_pool_size = 20           # Connections per user/db pair
reserve_pool_size = 5            # Emergency connections
reserve_pool_timeout = 3         # Seconds before using reserve

# Application-level (Node.js pg)
const pool = new Pool({
  max: 20,                       # Maximum connections
  idleTimeoutMillis: 30000,      # Close idle after 30s
  connectionTimeoutMillis: 2000, # Fail fast on connection
});
```

### Supabase-Specific

```javascript
// Use transaction pooler for serverless
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY,
  {
    db: {
      schema: 'public',
    },
    auth: {
      persistSession: false, // Serverless
    },
  }
);

// Use session pooler for migrations
// Connection string: postgresql://...pooler.supabase.com:5432/postgres?pgbouncer=true
```

## Connection Lifecycle

### Proper Resource Cleanup

```javascript
// Node.js pattern
const client = await pool.connect();
try {
  await client.query('BEGIN');
  await client.query('INSERT INTO ...');
  await client.query('COMMIT');
} catch (e) {
  await client.query('ROLLBACK');
  throw e;
} finally {
  client.release(); // ALWAYS release back to pool
}
```

```python
# Python pattern
with psycopg2.connect(...) as conn:
    with conn.cursor() as cur:
        cur.execute('SELECT ...')
        # Auto-commits on success, rollback on exception
# Connection auto-closed
```

```go
// Go pattern
conn, err := pool.Acquire(ctx)
if err != nil {
    return err
}
defer conn.Release() // ALWAYS defer release

tx, err := conn.Begin(ctx)
if err != nil {
    return err
}
defer tx.Rollback(ctx) // Safe: no-op if committed

// ... work ...
return tx.Commit(ctx)
```

## Resource Limits

### Connection Monitoring

```sql
-- Current connection count
SELECT count(*) FROM pg_stat_activity;

-- Connections by state
SELECT state, count(*)
FROM pg_stat_activity
GROUP BY state;

-- Connections by application
SELECT application_name, count(*)
FROM pg_stat_activity
WHERE application_name != ''
GROUP BY application_name;

-- Long-running queries
SELECT pid, now() - query_start AS duration, query
FROM pg_stat_activity
WHERE state = 'active'
  AND now() - query_start > interval '5 seconds'
ORDER BY duration DESC;
```

### Terminating Problem Connections

```sql
-- Cancel a query (graceful)
SELECT pg_cancel_backend(pid);

-- Terminate connection (forceful)
SELECT pg_terminate_backend(pid);

-- Kill all connections to a database (for maintenance)
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'mydb'
  AND pid != pg_backend_pid();
```

### Statement Timeout

```sql
-- Per-session timeout
SET statement_timeout = '30s';

-- Per-transaction timeout
BEGIN;
SET LOCAL statement_timeout = '10s';
SELECT slow_function();
COMMIT;

-- Per-role default
ALTER ROLE web_user SET statement_timeout = '30s';
```

## Serverless Considerations

### Cold Start Mitigation

```javascript
// Pre-warm connection pool
const pool = new Pool({ min: 2, max: 10 });

// Keep-alive query
setInterval(async () => {
  try {
    await pool.query('SELECT 1');
  } catch (e) {
    console.error('Keep-alive failed:', e);
  }
}, 60000);
```

### Connection Limits for Serverless

```
Edge Functions: Use transaction pooler
- Short-lived connections
- Pool mode: transaction
- No prepared statements

Long-running: Use session pooler
- Migrations, batch jobs
- Pool mode: session
- Prepared statements OK
```

## Anti-Patterns

### Connection per Request

```javascript
// BAD: Creates new connection every request
app.get('/users', async (req, res) => {
  const client = new Client(connectionString);
  await client.connect();
  const result = await client.query('SELECT * FROM users');
  await client.end();
  res.json(result.rows);
});

// GOOD: Use connection pool
const pool = new Pool(connectionString);
app.get('/users', async (req, res) => {
  const result = await pool.query('SELECT * FROM users');
  res.json(result.rows);
});
```

### Leaked Connections

```javascript
// BAD: Connection never released on error
const client = await pool.connect();
const result = await client.query('SELECT ...'); // May throw!
client.release();

// GOOD: Always release in finally
const client = await pool.connect();
try {
  return await client.query('SELECT ...');
} finally {
  client.release();
}
```

## Checklist

- [ ] Using connection pooling (not direct connections)
- [ ] Pool size matches server resources
- [ ] Connections always released (try/finally)
- [ ] Statement timeout configured
- [ ] Monitoring connection count
- [ ] Serverless uses transaction pooler
- [ ] Migrations use session pooler

