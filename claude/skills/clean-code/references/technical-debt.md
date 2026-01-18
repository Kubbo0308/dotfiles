# Technical Debt

Technical debt represents the implied cost of future rework caused by choosing an easy solution now instead of a better approach.

**Key Insight**: Quality and speed are NOT a trade-off. High internal quality leads to higher development velocity over time.

---

## The Technical Debt Quadrant

Martin Fowler's classification of technical debt:

```
                    Reckless                         Prudent
            ┌─────────────────────────┬─────────────────────────┐
            │                         │                         │
            │  "We don't have time    │  "We must ship now and  │
Deliberate  │   for design"           │   deal with consequences"│
            │                         │                         │
            │  ❌ MUST AVOID          │  ⚠️ Acceptable with plan │
            │                         │                         │
            ├─────────────────────────┼─────────────────────────┤
            │                         │                         │
            │  "What's layering?"     │  "Now we know how we    │
Inadvertent │                         │   should have done it"  │
            │                         │                         │
            │  ❌ Dangerous ignorance │  ✅ Natural learning    │
            │                         │                         │
            └─────────────────────────┴─────────────────────────┘
```

---

## The Four Types

### 1. Deliberate & Reckless (MUST AVOID)

Taking shortcuts while knowing better, without any plan to fix it.

```typescript
// ❌ BAD: "We don't have time for proper error handling"
function processPayment(data: any): any {
  try {
    return gateway.charge(data);
  } catch (e) {
    console.log(e);  // Just log and continue
    return null;
  }
}

// ❌ BAD: "Just cast it, we'll fix later"
const config = JSON.parse(response) as Config;
```

**Consequence**: Accumulates rapidly, leads to system degradation.

---

### 2. Deliberate & Prudent (Acceptable with Plan)

Consciously choosing a simpler solution with a clear plan to address it.

```typescript
// ⚠️ ACCEPTABLE: Documented decision with plan
/**
 * TECH DEBT: Using simple in-memory cache.
 * TODO(JIRA-1234): Replace with Redis when we scale beyond single instance.
 * Decision made: 2024-01-15, Review by: 2024-03-01
 */
class SimpleCache implements Cache {
  private store = new Map<string, CacheEntry>();

  get(key: string): unknown | null {
    const entry = this.store.get(key);
    if (!entry || entry.expiresAt < Date.now()) {
      return null;
    }
    return entry.value;
  }
}
```

**Requirements**:
- Clear documentation of the decision
- Ticket/task to address it
- Review date scheduled
- Stakeholder awareness

---

### 3. Inadvertent & Reckless (Dangerous)

Accumulating debt without realizing it due to lack of knowledge.

```typescript
// ❌ BAD: Developer doesn't know about SQL injection
function getUser(userId: string): User {
  return db.query(`SELECT * FROM users WHERE id = '${userId}'`);
}

// ❌ BAD: Developer doesn't understand async
function loadData() {
  let result;
  fetchData().then(data => {
    result = data;
  });
  return result;  // Always undefined!
}

// ❌ BAD: Developer doesn't know about immutability
function addItem(cart: Cart, item: Item): Cart {
  cart.items.push(item);  // Mutates input!
  return cart;
}
```

**Solution**: Code reviews, training, pair programming, linting rules.

---

### 4. Inadvertent & Prudent (Natural Learning)

Realizing a better approach after gaining more understanding.

```typescript
// Initial implementation (seemed good at the time)
class OrderService {
  async createOrder(customerId: string, items: Item[]): Promise<Order> {
    // All logic in one method
    const customer = await this.db.findCustomer(customerId);
    const validated = this.validateItems(items);
    const total = this.calculateTotal(validated);
    const order = { customer, items: validated, total };
    await this.db.saveOrder(order);
    await this.emailService.sendConfirmation(customer, order);
    return order;
  }
}

// After learning Clean Architecture
// "Now we know how we should have done it"

// ✅ IMPROVED: Separated concerns
class CreateOrderUseCase {
  constructor(
    private readonly orderRepository: OrderRepository,
    private readonly customerRepository: CustomerRepository,
    private readonly notificationService: NotificationService
  ) {}

  async execute(input: CreateOrderInput): Promise<Order> {
    const customer = await this.customerRepository.findById(input.customerId);
    const order = Order.create(customer, input.items);
    await this.orderRepository.save(order);
    await this.notificationService.notifyOrderCreated(order);
    return order;
  }
}
```

**This is the "good" debt**: Natural result of learning. Address through refactoring.

---

## Managing Technical Debt

### 1. Make It Visible

```typescript
// Use consistent markers
// TODO: Minor improvements
// FIXME: Bugs that need fixing
// HACK: Workarounds that should be removed
// TECH_DEBT: Architectural decisions to revisit

/**
 * @deprecated Use NewPaymentGateway instead
 * TECH_DEBT: Legacy integration, remove after migration (JIRA-5678)
 */
class OldPaymentGateway { ... }
```

### 2. Track and Prioritize

| Category | Priority | Action |
|----------|----------|--------|
| Security vulnerabilities | Critical | Fix immediately |
| Performance bottlenecks | High | Plan for next sprint |
| Code duplication | Medium | Include in regular refactoring |
| Outdated dependencies | Medium | Schedule updates |
| Missing documentation | Low | Address opportunistically |

### 3. Pay Down Regularly

- **Boy Scout Rule**: Leave code cleaner than you found it
- **Refactoring Budget**: Allocate 10-20% of each sprint
- **Tech Debt Sprints**: Periodic focused cleanup sprints

---

## The Broken Window Theory

**One piece of neglected code invites more neglect.**

```typescript
// If developers see this:
function processData(d: any): any {
  // TODO: fix this
  return d.x + d.y;
}

// They're more likely to add this:
function handleStuff(s: any): any {
  // TODO: also fix this
  return s.a * s.b;
}
```

**Prevention**:
- Fix issues as soon as they're spotted
- Maintain code quality standards
- Don't let "temporary" solutions become permanent

---

## Quick Reference

| Type | Example | Action |
|------|---------|--------|
| Deliberate Reckless | "No time for design" | MUST avoid |
| Deliberate Prudent | Documented shortcut | Acceptable with plan |
| Inadvertent Reckless | Don't know best practices | Train, review, lint |
| Inadvertent Prudent | Better approach discovered | Refactor when possible |

## Key Takeaway

> "The only way to go fast is to go well."
> — Robert C. Martin

Short-term speed gains from cutting corners are quickly lost to the friction of working with poor quality code.
