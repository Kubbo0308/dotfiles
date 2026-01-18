# Declarative Patterns

MUST prefer declarative array methods over imperative loops.

## Array Method Reference

| Instead of | Use | Purpose |
|------------|-----|---------|
| `for` loop with push | `map()` | Transform each element |
| `for` loop with condition + push | `filter()` | Select elements |
| `for` loop accumulating value | `reduce()` | Aggregate to single value |
| `for` loop with early exit | `find()` | Find first match |
| `for` loop checking condition | `some()` | Check if any match |
| `for` loop checking all | `every()` | Check if all match |
| nested `for` loops | `flatMap()` | Flatten and map |

---

## Examples

### map() - Transform Elements

```typescript
// ❌ BAD: Imperative
const names = [];
for (let i = 0; i < users.length; i++) {
  names.push(users[i].name);
}

// ✅ GOOD: Declarative
const names = users.map(user => user.name);
```

### filter() - Select Elements

```typescript
// ❌ BAD: Imperative
const activeUsers = [];
for (let i = 0; i < users.length; i++) {
  if (users[i].isActive) {
    activeUsers.push(users[i]);
  }
}

// ✅ GOOD: Declarative
const activeUsers = users.filter(user => user.isActive);
```

### filter() + map() - Select and Transform

```typescript
// ❌ BAD: Imperative
const activeNames = [];
for (let i = 0; i < users.length; i++) {
  if (users[i].isActive) {
    activeNames.push(users[i].name);
  }
}

// ✅ GOOD: Declarative chain
const activeNames = users
  .filter(user => user.isActive)
  .map(user => user.name);
```

### reduce() - Aggregate Values

```typescript
// ❌ BAD: Imperative
let total = 0;
for (let i = 0; i < items.length; i++) {
  total += items[i].price;
}

// ✅ GOOD: Declarative
const total = items.reduce((sum, item) => sum + item.price, 0);
```

### reduce() - Group By

```typescript
// ❌ BAD: Imperative
const grouped = {};
for (let i = 0; i < items.length; i++) {
  const key = items[i].category;
  if (!grouped[key]) {
    grouped[key] = [];
  }
  grouped[key].push(items[i]);
}

// ✅ GOOD: Declarative
const grouped = items.reduce((acc, item) => ({
  ...acc,
  [item.category]: [...(acc[item.category] || []), item],
}), {});

// ✅ BETTER: Using Object.groupBy (ES2024)
const grouped = Object.groupBy(items, item => item.category);
```

### find() - Find First Match

```typescript
// ❌ BAD: Imperative
let found = null;
for (let i = 0; i < users.length; i++) {
  if (users[i].id === targetId) {
    found = users[i];
    break;
  }
}

// ✅ GOOD: Declarative
const found = users.find(user => user.id === targetId);
```

### some() / every() - Check Conditions

```typescript
// ❌ BAD: Imperative
let hasAdmin = false;
for (let i = 0; i < users.length; i++) {
  if (users[i].role === 'admin') {
    hasAdmin = true;
    break;
  }
}

// ✅ GOOD: Declarative
const hasAdmin = users.some(user => user.role === 'admin');
const allActive = users.every(user => user.isActive);
```

### flatMap() - Flatten and Map

```typescript
// ❌ BAD: Imperative nested loops
const allTags = [];
for (let i = 0; i < posts.length; i++) {
  for (let j = 0; j < posts[i].tags.length; j++) {
    allTags.push(posts[i].tags[j]);
  }
}

// ✅ GOOD: Declarative
const allTags = posts.flatMap(post => post.tags);
```

---

## Chaining Patterns

### Complex Transformations

```typescript
// ✅ GOOD: Readable chain
const result = orders
  .filter(order => order.status === 'completed')
  .filter(order => order.total > 100)
  .map(order => ({
    id: order.id,
    customer: order.customerName,
    amount: order.total,
  }))
  .sort((a, b) => b.amount - a.amount)
  .slice(0, 10);
```

### Extract Predicate Functions

```typescript
// ✅ BETTER: Named predicates for readability
const isCompleted = (order: Order) => order.status === 'completed';
const isHighValue = (order: Order) => order.total > 100;
const toSummary = (order: Order) => ({
  id: order.id,
  customer: order.customerName,
  amount: order.total,
});
const byAmountDesc = (a: Summary, b: Summary) => b.amount - a.amount;

const result = orders
  .filter(isCompleted)
  .filter(isHighValue)
  .map(toSummary)
  .sort(byAmountDesc)
  .slice(0, 10);
```

---

## When Imperative is Acceptable

1. **Performance-critical loops** - When profiling shows `for` is measurably faster
2. **Early termination with side effects** - When you need `break` + mutation
3. **Complex state machines** - When functional approach hurts readability

Always add a comment explaining why imperative was chosen.
