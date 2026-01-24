# Schema Design (High Priority)

## Core Principle

Design schemas for clarity, performance, and maintainability. Make the right thing easy and the wrong thing hard.

## Table Structure

### Primary Keys

```sql
-- Serial (legacy, simple)
CREATE TABLE users (
    id SERIAL PRIMARY KEY
);

-- Identity (SQL standard, preferred)
CREATE TABLE users (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY
);

-- UUID (distributed systems, Supabase default)
CREATE TABLE users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY
);

-- ULID-style (sortable, k-sortable)
CREATE TABLE events (
    id UUID DEFAULT uuid_generate_v7() PRIMARY KEY
);
```

### Foreign Keys

```sql
-- Always define FK constraints
CREATE TABLE orders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id)
        ON DELETE CASCADE    -- or RESTRICT, SET NULL
        ON UPDATE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id)
        ON DELETE RESTRICT   -- Prevent orphaned orders
);

-- CRITICAL: Always index foreign keys
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_product_id ON orders(product_id);
```

### Timestamps

```sql
-- Always use TIMESTAMPTZ for wall clock time
CREATE TABLE events (
    id UUID PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_events_updated_at
    BEFORE UPDATE ON events
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();
```

## Data Types

### Choose Appropriate Types

```sql
-- Numeric
SMALLINT          -- -32K to 32K (counters, flags)
INTEGER           -- -2B to 2B (most IDs, counts)
BIGINT            -- Large numbers (analytics, timestamps)
NUMERIC(p,s)      -- Exact decimal (money: NUMERIC(19,4))
REAL/DOUBLE       -- Approximate (scientific data)

-- String
VARCHAR(n)        -- Variable with limit (email: 255)
TEXT              -- Unlimited (descriptions, content)
CHAR(n)           -- Fixed width (country codes: CHAR(2))

-- Binary
BYTEA             -- Binary data, files

-- JSON
JSONB             -- Binary JSON, indexable (preferred)
JSON              -- Text JSON, preserves formatting

-- Arrays
INTEGER[]         -- Array of integers
TEXT[]            -- Array of strings
```

### JSONB Best Practices

```sql
-- Store structured but flexible data
CREATE TABLE user_preferences (
    user_id UUID PRIMARY KEY REFERENCES users(id),
    settings JSONB DEFAULT '{}' NOT NULL
);

-- Index for containment queries
CREATE INDEX idx_prefs_settings ON user_preferences USING GIN(settings);

-- Query patterns
SELECT * FROM user_preferences
WHERE settings @> '{"theme": "dark"}';  -- Uses GIN index

SELECT * FROM user_preferences
WHERE settings->>'theme' = 'dark';       -- Doesn't use GIN

-- Index specific path for equality
CREATE INDEX idx_prefs_theme ON user_preferences ((settings->>'theme'));
```

## Normalization Guidelines

### When to Normalize (3NF)

```sql
-- Separate entities with their own lifecycle
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE addresses (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    street TEXT,
    city VARCHAR(100),
    country CHAR(2)
);

-- Join for queries
SELECT u.email, a.city
FROM users u
JOIN addresses a ON u.id = a.user_id;
```

### When to Denormalize

```sql
-- Read-heavy, rarely updated data
CREATE TABLE order_items (
    id UUID PRIMARY KEY,
    order_id UUID REFERENCES orders(id),
    product_id UUID REFERENCES products(id),
    -- Denormalized for read performance
    product_name VARCHAR(255) NOT NULL,
    product_price NUMERIC(19,4) NOT NULL,
    quantity INTEGER NOT NULL
);

-- Aggregated data for dashboards
CREATE TABLE user_stats (
    user_id UUID PRIMARY KEY REFERENCES users(id),
    total_orders INTEGER DEFAULT 0,
    total_spent NUMERIC(19,4) DEFAULT 0,
    last_order_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT now()
);
```

## Constraints

### NOT NULL by Default

```sql
-- Prefer NOT NULL with defaults
CREATE TABLE posts (
    id UUID PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL DEFAULT '',
    published BOOLEAN NOT NULL DEFAULT false,
    view_count INTEGER NOT NULL DEFAULT 0
);
```

### Check Constraints

```sql
CREATE TABLE products (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price NUMERIC(19,4) NOT NULL CHECK (price >= 0),
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'active', 'archived')),
    stock INTEGER NOT NULL CHECK (stock >= 0)
);
```

### Unique Constraints

```sql
-- Simple unique
ALTER TABLE users ADD CONSTRAINT users_email_unique UNIQUE (email);

-- Partial unique (soft deletes)
CREATE UNIQUE INDEX users_email_active_unique
ON users (email)
WHERE deleted_at IS NULL;

-- Composite unique
ALTER TABLE org_members
ADD CONSTRAINT org_members_unique UNIQUE (org_id, user_id);
```

## Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Tables | snake_case, plural | `user_accounts` |
| Columns | snake_case | `created_at`, `user_id` |
| Primary Key | `id` | `id` |
| Foreign Key | `{singular_table}_id` | `user_id`, `order_id` |
| Index | `idx_{table}_{columns}` | `idx_users_email` |
| Unique | `{table}_uk_{columns}` | `users_uk_email` |
| Check | `{table}_ck_{column}` | `products_ck_price` |
| Trigger | `trg_{table}_{action}` | `trg_users_updated_at` |

## Migration Safety

### Safe Operations

```sql
-- Add nullable column
ALTER TABLE users ADD COLUMN bio TEXT;

-- Add column with default (PG 11+, instant)
ALTER TABLE users ADD COLUMN active BOOLEAN DEFAULT true;

-- Create index concurrently
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);

-- Add constraint without validation (then validate separately)
ALTER TABLE orders ADD CONSTRAINT orders_user_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
    NOT VALID;
ALTER TABLE orders VALIDATE CONSTRAINT orders_user_fk;
```

### Dangerous Operations

```sql
-- LOCKS TABLE: Avoid in production
ALTER TABLE users ALTER COLUMN email TYPE VARCHAR(500);  -- Rewrites table
ALTER TABLE users ADD COLUMN status VARCHAR(20) NOT NULL; -- Scans table
CREATE INDEX idx_users_email ON users(email);             -- Locks table

-- SAFE ALTERNATIVES
-- For type change: add new column, backfill, swap
-- For NOT NULL: add nullable, backfill, add constraint
-- For index: CREATE INDEX CONCURRENTLY
```

## Checklist

- [ ] Primary keys use appropriate type (UUID for distributed)
- [ ] Foreign keys defined with appropriate actions
- [ ] All FK columns indexed
- [ ] Timestamps use TIMESTAMPTZ
- [ ] NOT NULL with sensible defaults
- [ ] Check constraints for enums and ranges
- [ ] Consistent naming conventions
- [ ] JSONB for flexible structured data
- [ ] Migrations tested on staging with production data size

