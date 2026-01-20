# Cohesion

Cohesion measures how strongly related the elements within a module are.

**Goal**: HIGH cohesion - all elements contribute to a single, well-defined purpose.

---

## The 7 Levels of Cohesion (Worst to Best)

### 1. Coincidental Cohesion (WORST - MUST AVOID)

Elements are grouped randomly with no meaningful relationship.

```typescript
// ❌ BAD: Unrelated functions grouped together
class Utilities {
  validateEmail(email: string): boolean { ... }
  calculateTax(amount: number): number { ... }
  formatDate(date: Date): string { ... }
  sendNotification(message: string): void { ... }
  compressImage(image: Buffer): Buffer { ... }
}
```

**Problem**: No logical grouping. Changes to one function have no relation to others.

---

### 2. Logical Cohesion (SHOULD AVOID)

Elements perform similar operations but are selected by a control flag.

```typescript
// ❌ BAD: Flag determines which logic to execute
function processData(data: Data, operationType: 'validate' | 'transform' | 'save') {
  switch (operationType) {
    case 'validate':
      return validateData(data);
    case 'transform':
      return transformData(data);
    case 'save':
      return saveData(data);
  }
}

// ✅ GOOD: Separate functions
function validateData(data: Data): ValidationResult { ... }
function transformData(data: Data): TransformedData { ... }
function saveData(data: Data): void { ... }
```

**Problem**: Only one path executes per call. Hard to understand and maintain.

---

### 3. Temporal Cohesion (ACCEPTABLE)

Elements are grouped because they execute at the same time.

```typescript
// ⚠️ ACCEPTABLE: Initialization functions grouped by timing
function initializeApplication(): void {
  loadConfiguration();
  connectToDatabase();
  startLoggingSystem();
  initializeCache();
  registerEventHandlers();
}

// Also acceptable: cleanup functions
function shutdown(): void {
  closeConnections();
  flushLogs();
  saveState();
}
```

**Note**: Acceptable for lifecycle operations (init, cleanup), but keep functions small.

---

### 4. Procedural Cohesion (ACCEPTABLE)

Elements are grouped as steps in a procedure, but don't share data.

```typescript
// ⚠️ ACCEPTABLE: Steps in a process
function processOrder(orderId: string): void {
  const order = fetchOrder(orderId);
  validateOrder(order);
  calculateTotal(order);
  applyDiscounts(order);
  saveOrder(order);
  sendConfirmation(order);
}
```

**Note**: Each step depends on the previous completing. Consider if steps could be separate.

---

### 5. Communicational Cohesion (GOOD)

Elements operate on the same data structure.

```typescript
// ✅ GOOD: All methods operate on the same user data
class UserProfile {
  constructor(private readonly user: User) {}

  getDisplayName(): string {
    return `${this.user.firstName} ${this.user.lastName}`;
  }

  getEmailDomain(): string {
    return this.user.email.split('@')[1];
  }

  isVerified(): boolean {
    return this.user.emailVerified && this.user.phoneVerified;
  }
}
```

---

### 6. Sequential Cohesion (BETTER)

Output of one element is input to the next (pipeline).

```typescript
// ✅ BETTER: Each step's output feeds the next
function processUserData(rawInput: string): ProcessedUser {
  const parsed = parseInput(rawInput);           // string → RawData
  const validated = validateData(parsed);         // RawData → ValidData
  const normalized = normalizeData(validated);    // ValidData → NormalizedData
  const enriched = enrichWithDefaults(normalized); // NormalizedData → ProcessedUser
  return enriched;
}

// Can also be written as pipeline
const processUserData = (rawInput: string): ProcessedUser =>
  pipe(
    parseInput,
    validateData,
    normalizeData,
    enrichWithDefaults
  )(rawInput);
```

---

### 7. Functional Cohesion (BEST - AIM FOR THIS)

All elements contribute to a single, well-defined task.

```typescript
// ✅ BEST: Single purpose - calculate circle area
function calculateCircleArea(radius: number): number {
  return Math.PI * radius * radius;
}

// ✅ BEST: Single purpose - validate email format
function isValidEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

// ✅ BEST: Single purpose - format currency
function formatCurrency(amount: number, currency: string): string {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
  }).format(amount);
}
```

**Characteristics**:
- Does exactly one thing
- Name describes what it does
- Easy to test
- Easy to reuse

---

## Improving Cohesion

### Split Low-Cohesion Classes

```typescript
// ❌ BAD: Low cohesion - does too many things
class OrderService {
  createOrder(data: OrderData): Order { ... }
  sendOrderEmail(order: Order): void { ... }
  generateInvoicePDF(order: Order): Buffer { ... }
  validatePayment(payment: Payment): boolean { ... }
  updateInventory(items: Item[]): void { ... }
}

// ✅ GOOD: High cohesion - each class has single responsibility
class OrderRepository {
  create(data: OrderData): Order { ... }
  findById(id: string): Order | null { ... }
  update(order: Order): Order { ... }
}

class OrderNotificationService {
  sendConfirmation(order: Order): void { ... }
  sendShippingUpdate(order: Order): void { ... }
}

class InvoiceGenerator {
  generate(order: Order): Buffer { ... }
}

class PaymentValidator {
  validate(payment: Payment): ValidationResult { ... }
}

class InventoryService {
  updateStock(items: Item[]): void { ... }
}
```

### Keep Low-Cohesion Functions Small

If cohesion is low, minimize cognitive load by keeping functions very small.

```typescript
// If you must have temporal cohesion, keep it minimal
function initialize(): void {
  initConfig();
  initDatabase();
  initCache();
}
// Each init function should be just a few lines
```

---

## Quick Reference

| Level | Name | Quality | Action |
|-------|------|---------|--------|
| 1 | Coincidental | Worst | MUST refactor |
| 2 | Logical | Bad | SHOULD refactor |
| 3 | Temporal | OK | Keep small |
| 4 | Procedural | OK | Consider splitting |
| 5 | Communicational | Good | Acceptable |
| 6 | Sequential | Better | Good for pipelines |
| 7 | Functional | Best | Aim for this |
