# Concurrency & Locking (Medium-High Priority)

## Core Principle

Understand transaction isolation and locking to prevent data corruption and deadlocks.

## Transaction Isolation Levels

### Available Levels

```sql
-- Read Committed (default in Postgres)
-- Sees committed data at statement start
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Repeatable Read
-- Sees snapshot from transaction start
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Serializable
-- Full isolation, may fail with serialization errors
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

### When to Use What

| Level | Use Case | Trade-off |
|-------|----------|-----------|
| Read Committed | Default, most operations | May see changes mid-transaction |
| Repeatable Read | Reporting, batch processing | Higher memory, potential retry |
| Serializable | Financial, critical operations | Most retries, lowest throughput |

## Locking Strategies

### Row-Level Locks

```sql
-- FOR UPDATE: Exclusive lock for modification
SELECT * FROM accounts WHERE id = 1 FOR UPDATE;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;

-- FOR SHARE: Shared lock, prevents modification
SELECT * FROM products WHERE id = 1 FOR SHARE;
-- Others can read, but not update/delete

-- FOR UPDATE SKIP LOCKED: Non-blocking queue processing
SELECT * FROM jobs
WHERE status = 'pending'
ORDER BY created_at
LIMIT 1
FOR UPDATE SKIP LOCKED;

-- FOR UPDATE NOWAIT: Fail immediately if locked
SELECT * FROM accounts WHERE id = 1 FOR UPDATE NOWAIT;
-- Raises error if row is locked
```

### Advisory Locks

```sql
-- Session-level lock (released on disconnect)
SELECT pg_advisory_lock(12345);
-- ... do exclusive work ...
SELECT pg_advisory_unlock(12345);

-- Transaction-level lock (released on commit/rollback)
SELECT pg_advisory_xact_lock(12345);

-- Non-blocking try
SELECT pg_try_advisory_lock(12345);  -- Returns true/false

-- Named locks using hash
SELECT pg_advisory_lock(hashtext('process_user_' || user_id::text));
```

## Deadlock Prevention

### Consistent Lock Ordering

```sql
-- BAD: Potential deadlock
-- Transaction 1: locks A, then tries B
-- Transaction 2: locks B, then tries A

-- GOOD: Always lock in same order
-- Both transactions: lock A, then B
BEGIN;
SELECT * FROM accounts WHERE id = 1 FOR UPDATE;  -- Always lower ID first
SELECT * FROM accounts WHERE id = 2 FOR UPDATE;
-- ... transfer money ...
COMMIT;
```

### Lock Timeout

```sql
-- Set maximum wait time for locks
SET lock_timeout = '5s';

-- Per-transaction
BEGIN;
SET LOCAL lock_timeout = '10s';
SELECT * FROM accounts FOR UPDATE;
COMMIT;
```

### Detecting Deadlocks

```sql
-- Find blocking queries
SELECT
    blocked.pid AS blocked_pid,
    blocked.query AS blocked_query,
    blocking.pid AS blocking_pid,
    blocking.query AS blocking_query
FROM pg_stat_activity blocked
JOIN pg_stat_activity blocking ON blocking.pid = ANY(pg_blocking_pids(blocked.pid))
WHERE blocked.pid != blocking.pid;

-- View all locks
SELECT
    l.locktype,
    l.relation::regclass,
    l.mode,
    l.granted,
    a.query
FROM pg_locks l
JOIN pg_stat_activity a ON l.pid = a.pid
WHERE NOT l.granted;
```

## Optimistic Locking

### Version Column Pattern

```sql
CREATE TABLE documents (
    id UUID PRIMARY KEY,
    content TEXT,
    version INTEGER NOT NULL DEFAULT 1,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Update with version check
UPDATE documents
SET content = 'new content',
    version = version + 1,
    updated_at = now()
WHERE id = '...'
AND version = 5;  -- Expected version

-- Check if update succeeded
-- If 0 rows affected, concurrent modification occurred
```

### Application Implementation

```javascript
async function updateDocument(id, content, expectedVersion) {
  const result = await db.query(`
    UPDATE documents
    SET content = $1, version = version + 1
    WHERE id = $2 AND version = $3
    RETURNING version
  `, [content, id, expectedVersion]);

  if (result.rowCount === 0) {
    throw new Error('Concurrent modification detected');
  }
  return result.rows[0].version;
}
```

## Queue Processing Patterns

### Job Queue with SKIP LOCKED

```sql
-- Enqueue
INSERT INTO jobs (type, payload)
VALUES ('send_email', '{"to": "user@example.com"}');

-- Dequeue (worker)
BEGIN;

SELECT id, type, payload
FROM jobs
WHERE status = 'pending'
ORDER BY created_at
LIMIT 1
FOR UPDATE SKIP LOCKED;

-- Process job...

UPDATE jobs SET status = 'completed' WHERE id = ...;

COMMIT;
```

### Batch Processing

```sql
-- Claim batch of items
UPDATE items
SET processor_id = 'worker-1',
    claimed_at = now()
WHERE id IN (
    SELECT id FROM items
    WHERE processor_id IS NULL
    ORDER BY priority DESC, created_at
    LIMIT 100
    FOR UPDATE SKIP LOCKED
)
RETURNING *;
```

## Anti-Patterns

### Long-Running Transactions

```sql
-- BAD: Holds locks for entire duration
BEGIN;
SELECT * FROM accounts FOR UPDATE;
-- ... HTTP call, user input, sleep ...  DON'T!
COMMIT;

-- GOOD: Keep transactions short
SELECT * FROM accounts WHERE id = 1;  -- Read outside transaction
-- ... do computation ...
BEGIN;
SELECT * FROM accounts WHERE id = 1 FOR UPDATE;  -- Re-read and lock
UPDATE accounts SET balance = new_value WHERE id = 1;
COMMIT;
```

### Excessive Locking

```sql
-- BAD: Locks entire table
LOCK TABLE accounts IN EXCLUSIVE MODE;

-- GOOD: Row-level locks
SELECT * FROM accounts WHERE id = 1 FOR UPDATE;
```

### Ignoring Lock Failures

```javascript
// BAD: No retry on serialization failure
await db.query('UPDATE accounts SET balance = balance - 100');

// GOOD: Retry with backoff
async function transferWithRetry(fromId, toId, amount, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      await db.query('BEGIN ISOLATION LEVEL SERIALIZABLE');
      await db.query('UPDATE accounts SET balance = balance - $1 WHERE id = $2', [amount, fromId]);
      await db.query('UPDATE accounts SET balance = balance + $1 WHERE id = $2', [amount, toId]);
      await db.query('COMMIT');
      return;
    } catch (e) {
      await db.query('ROLLBACK');
      if (e.code === '40001') {  // Serialization failure
        await sleep(Math.pow(2, i) * 100);  // Exponential backoff
        continue;
      }
      throw e;
    }
  }
  throw new Error('Max retries exceeded');
}
```

## Checklist

- [ ] Transactions are as short as possible
- [ ] Locks acquired in consistent order
- [ ] Using appropriate isolation level
- [ ] SKIP LOCKED for queue processing
- [ ] Lock timeout configured
- [ ] Retry logic for serialization failures
- [ ] Monitoring for blocking queries
- [ ] No table-level locks in production

