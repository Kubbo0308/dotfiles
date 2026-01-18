# Pure Functions

MUST write pure functions whenever possible.

## Definition

A pure function:
1. **Deterministic**: Returns the same output for the same input
2. **No Side Effects**: Does not modify external state, perform I/O, or mutate inputs

---

## Examples

### Deterministic Output

```typescript
// ❌ IMPURE: Different output for same input
function getTimestamp(): number {
  return Date.now();
}

// ❌ IMPURE: Depends on external state
let multiplier = 2;
function multiply(x: number): number {
  return x * multiplier;
}

// ✅ PURE: Same input always produces same output
function add(a: number, b: number): number {
  return a + b;
}

function multiply(x: number, multiplier: number): number {
  return x * multiplier;
}
```

### No External State Mutation

```typescript
// ❌ IMPURE: Mutates external state
let total = 0;
function addToTotal(value: number): number {
  total += value;  // Side effect!
  return total;
}

// ✅ PURE: Returns new value without side effects
function addToTotal(currentTotal: number, value: number): number {
  return currentTotal + value;
}
```

### No Input Mutation

```typescript
// ❌ IMPURE: Mutates input array
function sortUsers(users: User[]): User[] {
  return users.sort((a, b) => a.name.localeCompare(b.name));
  // .sort() mutates the original array!
}

// ✅ PURE: Returns new sorted array
function sortUsers(users: readonly User[]): User[] {
  return [...users].sort((a, b) => a.name.localeCompare(b.name));
}

// ❌ IMPURE: Mutates input object
function updateUser(user: User, name: string): User {
  user.name = name;  // Mutation!
  return user;
}

// ✅ PURE: Returns new object
function updateUser(user: User, name: string): User {
  return { ...user, name };
}
```

### No I/O Operations

```typescript
// ❌ IMPURE: Performs I/O
function logAndDouble(x: number): number {
  console.log(`Doubling ${x}`);  // Side effect!
  return x * 2;
}

// ✅ PURE: No I/O
function double(x: number): number {
  return x * 2;
}

// Handle I/O separately
const value = 5;
console.log(`Doubling ${value}`);  // I/O at boundary
const result = double(value);       // Pure computation
```

---

## Handling Impure Operations

### Push Impurity to the Edges

```typescript
// ✅ GOOD: Pure core, impure shell
// Pure business logic
function calculateDiscount(price: number, discountPercent: number): number {
  return price * (1 - discountPercent / 100);
}

function formatPrice(price: number): string {
  return `$${price.toFixed(2)}`;
}

// Impure boundary (I/O)
async function processOrder(orderId: string): Promise<void> {
  const order = await fetchOrder(orderId);           // Impure: I/O
  const discountedPrice = calculateDiscount(         // Pure
    order.price,
    order.discount
  );
  const formatted = formatPrice(discountedPrice);    // Pure
  await saveOrder({ ...order, finalPrice: discountedPrice }); // Impure: I/O
  console.log(`Order processed: ${formatted}`);      // Impure: I/O
}
```

### Dependency Injection for Testability

```typescript
// ❌ BAD: Hard to test
function getUser(id: string): User {
  return database.query(`SELECT * FROM users WHERE id = ${id}`);
}

// ✅ GOOD: Inject dependency
function getUser(
  id: string,
  query: (sql: string) => User
): User {
  return query(`SELECT * FROM users WHERE id = ${id}`);
}

// Easy to test with mock
const mockQuery = (sql: string) => ({ id: '1', name: 'Test' });
const user = getUser('1', mockQuery);
```

---

## Benefits of Pure Functions

| Benefit | Description |
|---------|-------------|
| **Testable** | No mocking needed, just input → output |
| **Cacheable** | Same input = same output, safe to memoize |
| **Parallelizable** | No shared state, safe to run concurrently |
| **Predictable** | Easy to reason about behavior |
| **Composable** | Can chain/combine safely |

---

## Quick Checklist

- [ ] Does the function return a value? (not `void` unless necessary)
- [ ] Is the return value determined solely by inputs?
- [ ] Does it avoid modifying inputs?
- [ ] Does it avoid modifying external state?
- [ ] Does it avoid I/O (console, network, file)?
- [ ] Can you call it multiple times with same input safely?
