# Schema Design Guide

## Normalization Principles

### First Normal Form (1NF)
- Eliminate repeating groups
- Create separate tables for related data
- Identify each row with a unique primary key

### Second Normal Form (2NF)
- Meet all 1NF requirements
- Remove partial dependencies on composite keys
- All non-key attributes depend on entire primary key

### Third Normal Form (3NF)
- Meet all 2NF requirements
- Remove transitive dependencies
- Non-key attributes depend only on the primary key

## Index Strategy

### When to Create Indexes
- Columns frequently used in WHERE clauses
- Columns used in JOIN conditions
- Columns used in ORDER BY or GROUP BY
- Foreign key columns

### Index Types
| Type | Use Case |
|------|----------|
| B-tree | Default, range queries, equality |
| Hash | Equality comparisons only |
| GIN | Full-text search, arrays, JSONB |
| GiST | Geometric data, full-text search |
| BRIN | Large tables with natural ordering |

### Avoid Over-indexing
- Each index adds write overhead
- Monitor unused indexes periodically
- Consider composite indexes for multi-column queries

## Data Type Selection

### Numeric Types
```sql
-- Use appropriate size
SMALLINT       -- -32,768 to 32,767
INTEGER        -- -2B to 2B
BIGINT         -- Very large numbers
NUMERIC(p,s)   -- Exact precision (money)
REAL/DOUBLE    -- Approximate (scientific)
```

### String Types
```sql
VARCHAR(n)     -- Variable length with limit
TEXT           -- Unlimited length
CHAR(n)        -- Fixed length (rarely needed)
```

### Date/Time Types
```sql
DATE           -- Date only
TIME           -- Time only
TIMESTAMP      -- Date and time
TIMESTAMPTZ    -- With timezone (preferred)
INTERVAL       -- Duration
```

## Constraints Best Practices

```sql
-- Primary Key
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    -- or UUID: id UUID DEFAULT gen_random_uuid() PRIMARY KEY
);

-- Foreign Key with actions
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Check constraints
CREATE TABLE products (
    price NUMERIC CHECK (price > 0),
    status VARCHAR(20) CHECK (status IN ('active', 'inactive', 'pending'))
);

-- Unique constraints
CREATE TABLE accounts (
    email VARCHAR(255) UNIQUE NOT NULL,
    -- Partial unique
    UNIQUE (org_id, email) WHERE deleted_at IS NULL
);
```

## Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Tables | snake_case, plural | `user_accounts` |
| Columns | snake_case | `created_at` |
| Primary Key | `id` | `id` |
| Foreign Key | `{table}_id` | `user_id` |
| Indexes | `idx_{table}_{columns}` | `idx_users_email` |
| Constraints | `{table}_{type}_{column}` | `users_uk_email` |

