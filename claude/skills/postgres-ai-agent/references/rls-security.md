# Row Level Security (Critical Priority)

## Core Principle

RLS enforces data access at the database level. Never rely solely on application-level checks.

## Basic Setup

### Enable and Force RLS

```sql
-- Enable RLS on table
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- CRITICAL: Force RLS even for table owners
ALTER TABLE orders FORCE ROW LEVEL SECURITY;

-- Without FORCE, table owner bypasses all policies!
```

### Policy Types

```sql
-- USING: Controls which rows can be seen (SELECT, UPDATE, DELETE)
-- WITH CHECK: Controls which rows can be written (INSERT, UPDATE)

CREATE POLICY policy_name ON table_name
    FOR { ALL | SELECT | INSERT | UPDATE | DELETE }
    TO { role_name | PUBLIC }
    USING (condition)           -- Read access
    WITH CHECK (condition);     -- Write access
```

## Common Patterns

### User-Scoped Access

```sql
-- Users can only access their own data
CREATE POLICY user_isolation ON orders
    FOR ALL
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- Supabase auth.uid() function
CREATE OR REPLACE FUNCTION auth.uid()
RETURNS uuid
LANGUAGE sql STABLE
AS $$
  SELECT nullif(
    current_setting('request.jwt.claims', true)::json->>'sub',
    ''
  )::uuid
$$;
```

### Organization-Based Access

```sql
-- Users can access data within their organization
CREATE POLICY org_isolation ON projects
    FOR ALL
    USING (
      org_id IN (
        SELECT org_id FROM org_members
        WHERE user_id = auth.uid()
      )
    );
```

### Role-Based Access

```sql
-- Different policies for different roles
CREATE POLICY viewer_read ON documents
    FOR SELECT
    TO viewer_role
    USING (published = true);

CREATE POLICY editor_all ON documents
    FOR ALL
    TO editor_role
    USING (true)
    WITH CHECK (true);

CREATE POLICY admin_bypass ON documents
    FOR ALL
    TO admin_role
    USING (true)
    WITH CHECK (true);
```

### Hierarchical Access

```sql
-- Manager can see team's data
CREATE POLICY manager_view ON tasks
    FOR SELECT
    USING (
      assignee_id = auth.uid()
      OR
      assignee_id IN (
        SELECT user_id FROM teams
        WHERE manager_id = auth.uid()
      )
    );
```

## Security Considerations

### SECURITY DEFINER Functions

```sql
-- DANGEROUS: Bypasses RLS by default
CREATE FUNCTION get_all_orders()
RETURNS SETOF orders
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT * FROM orders;
$$;

-- SAFE: Explicitly set role
CREATE FUNCTION get_all_orders()
RETURNS SETOF orders
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SET LOCAL ROLE authenticated;  -- Apply RLS
  SELECT * FROM orders;
$$;
```

### Service Role Bypass

```javascript
// Supabase client with service role bypasses RLS
const supabaseAdmin = createClient(url, serviceRoleKey);

// NEVER expose service role key to client
// Use only for admin operations in secure backend
```

### Policy Performance

```sql
-- BAD: Subquery in every row check
CREATE POLICY slow_policy ON orders
    USING (
      user_id IN (SELECT user_id FROM permissions WHERE ...)
    );

-- BETTER: Use security_barrier view or materialized permissions
CREATE MATERIALIZED VIEW user_permissions AS
SELECT DISTINCT user_id, permission_type FROM permissions;

CREATE INDEX idx_user_perms ON user_permissions (user_id);

CREATE POLICY fast_policy ON orders
    USING (
      EXISTS (
        SELECT 1 FROM user_permissions
        WHERE user_id = auth.uid()
        AND permission_type = 'orders_read'
      )
    );
```

## Testing RLS

### Verify Policies Work

```sql
-- Test as specific user
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims = '{"sub": "user-uuid-here"}';

-- Should only return user's orders
SELECT * FROM orders;

-- Reset
RESET ROLE;
```

### Check Policy Definitions

```sql
-- List all policies on a table
SELECT pol.polname, pol.polcmd, pol.polroles::regrole[], pol.polqual, pol.polwithcheck
FROM pg_policy pol
JOIN pg_class cls ON pol.polrelid = cls.oid
WHERE cls.relname = 'orders';

-- Check if RLS is enabled
SELECT relname, relrowsecurity, relforcerowsecurity
FROM pg_class
WHERE relname = 'orders';
```

## Anti-Patterns

### Forgetting WITH CHECK

```sql
-- BAD: User can insert data for other users
CREATE POLICY user_orders ON orders
    FOR ALL
    USING (user_id = auth.uid());
    -- Missing WITH CHECK!

-- GOOD: Prevents inserting/updating with wrong user_id
CREATE POLICY user_orders ON orders
    FOR ALL
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());
```

### Not Forcing RLS

```sql
-- BAD: Table owner bypasses RLS
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
-- Owner can SELECT * FROM orders and see everything

-- GOOD: Force RLS on owner too
ALTER TABLE orders FORCE ROW LEVEL SECURITY;
```

### Public Schema Exposure

```sql
-- BAD: RLS on public schema, anyone can create functions
-- Attacker creates: CREATE FUNCTION public.auth.uid() ...

-- GOOD: Use separate schema for auth functions
CREATE SCHEMA auth;
REVOKE ALL ON SCHEMA auth FROM PUBLIC;
```

## Checklist

- [ ] RLS enabled on all tables with sensitive data
- [ ] RLS forced (FORCE ROW LEVEL SECURITY)
- [ ] Policies cover all operations (SELECT, INSERT, UPDATE, DELETE)
- [ ] WITH CHECK clause for write operations
- [ ] SECURITY DEFINER functions reviewed
- [ ] Service role key not exposed to client
- [ ] Policies tested with different user contexts
- [ ] No performance issues from policy subqueries

