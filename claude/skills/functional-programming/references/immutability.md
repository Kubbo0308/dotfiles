# Immutability Guide

MUST NOT mutate data. Create new copies instead.

---

## Variable Declaration

### MUST use `const` instead of `let`

```typescript
// ❌ BAD: Using let when const is possible
let name = "Alice";
let items = [1, 2, 3];
let config = { debug: true };

// ✅ GOOD: Using const
const name = "Alice";
const items = [1, 2, 3];
const config = { debug: true };
```

### When `let` is acceptable

```typescript
// ✅ OK: Value genuinely changes
let count = 0;
for (const item of items) {
  if (item.valid) count++;
}

// ✅ BETTER: Use reduce instead
const count = items.filter(item => item.valid).length;
```

---

## Object Updates

### Spread Operator

```typescript
// ❌ BAD: Mutation
user.name = "New Name";
user.email = "new@example.com";

// ✅ GOOD: Spread creates new object
const updatedUser = {
  ...user,
  name: "New Name",
  email: "new@example.com",
};
```

### Nested Updates

```typescript
// ❌ BAD: Nested mutation
state.user.profile.name = "New Name";

// ✅ GOOD: Immutable nested update
const newState = {
  ...state,
  user: {
    ...state.user,
    profile: {
      ...state.user.profile,
      name: "New Name",
    },
  },
};
```

### Delete Property

```typescript
// ❌ BAD: Mutation
delete user.password;

// ✅ GOOD: Destructuring to exclude
const { password, ...userWithoutPassword } = user;
```

---

## Array Updates

### Add Item

```typescript
// ❌ BAD: Mutation
items.push(newItem);

// ✅ GOOD: Spread creates new array
const newItems = [...items, newItem];

// ✅ GOOD: Add at beginning
const newItems = [newItem, ...items];

// ✅ GOOD: Add at index
const newItems = [
  ...items.slice(0, index),
  newItem,
  ...items.slice(index),
];
```

### Remove Item

```typescript
// ❌ BAD: Mutation
items.splice(index, 1);

// ✅ GOOD: Filter creates new array
const newItems = items.filter((_, i) => i !== index);

// ✅ GOOD: Filter by condition
const newItems = items.filter(item => item.id !== targetId);
```

### Update Item

```typescript
// ❌ BAD: Mutation
items[index].name = "New Name";

// ✅ GOOD: Map creates new array with updated item
const newItems = items.map((item, i) =>
  i === index ? { ...item, name: "New Name" } : item
);

// ✅ GOOD: Update by id
const newItems = items.map(item =>
  item.id === targetId ? { ...item, name: "New Name" } : item
);
```

### Sort (Mutates Original!)

```typescript
// ❌ BAD: .sort() mutates the original array
const sorted = items.sort((a, b) => a.value - b.value);

// ✅ GOOD: Copy first, then sort
const sorted = [...items].sort((a, b) => a.value - b.value);

// ✅ GOOD: Using toSorted (ES2023)
const sorted = items.toSorted((a, b) => a.value - b.value);
```

### Reverse (Mutates Original!)

```typescript
// ❌ BAD: .reverse() mutates
const reversed = items.reverse();

// ✅ GOOD: Copy first
const reversed = [...items].reverse();

// ✅ GOOD: Using toReversed (ES2023)
const reversed = items.toReversed();
```

---

## TypeScript `readonly`

### Readonly Properties

```typescript
// ✅ GOOD: Readonly interface
interface User {
  readonly id: string;
  readonly name: string;
  readonly email: string;
}

// Compile error if you try to mutate
const user: User = { id: '1', name: 'Alice', email: 'a@b.com' };
user.name = 'Bob';  // Error: Cannot assign to 'name'
```

### Readonly Arrays

```typescript
// ✅ GOOD: Readonly array parameter
function processItems(items: readonly Item[]): Result[] {
  // items.push(x);     // Error: Property 'push' does not exist
  // items[0] = x;      // Error: Index signature in type 'readonly Item[]'
  return items.map(transform);  // OK: map returns new array
}
```

### ReadonlyArray Type

```typescript
// ✅ GOOD: ReadonlyArray type
const items: ReadonlyArray<number> = [1, 2, 3];
// or
const items: readonly number[] = [1, 2, 3];
```

### Readonly Utility Type

```typescript
interface Config {
  host: string;
  port: number;
  options: {
    timeout: number;
  };
}

// ✅ GOOD: Make all properties readonly
type ImmutableConfig = Readonly<Config>;

// Note: Readonly is shallow - nested objects still mutable
// For deep readonly, use libraries or recursive types
```

---

## Immutable Update Libraries

For complex state updates, consider:

- **Immer**: `produce(state, draft => { draft.x = 1 })`
- **Immutable.js**: Persistent data structures

```typescript
// Using Immer
import { produce } from 'immer';

const newState = produce(state, draft => {
  draft.user.profile.name = "New Name";
  draft.items.push(newItem);
});
```

---

## Quick Reference

| Operation | Mutable (BAD) | Immutable (GOOD) |
|-----------|---------------|------------------|
| Declare | `let x = 1` | `const x = 1` |
| Update object | `obj.x = 1` | `{ ...obj, x: 1 }` |
| Delete property | `delete obj.x` | `const { x, ...rest } = obj` |
| Add to array | `arr.push(x)` | `[...arr, x]` |
| Remove from array | `arr.splice(i, 1)` | `arr.filter(...)` |
| Update in array | `arr[i] = x` | `arr.map(...)` |
| Sort array | `arr.sort()` | `[...arr].sort()` or `arr.toSorted()` |
| Reverse array | `arr.reverse()` | `[...arr].reverse()` or `arr.toReversed()` |
