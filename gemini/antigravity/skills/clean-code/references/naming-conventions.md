# Naming Conventions

MUST use clear, intention-revealing names.

---

## Core Principles

### 1. Names Reveal Intent

The name should tell you why it exists, what it does, and how to use it.

```typescript
// ❌ BAD: What is d? What does it represent?
const d = new Date();
const d2 = d.getTime();

// ✅ GOOD: Clear intent
const orderCreatedAt = new Date();
const orderTimestamp = orderCreatedAt.getTime();
```

### 2. Avoid Abbreviations

Spell out words completely. Clarity beats brevity.

```typescript
// ❌ BAD: Cryptic abbreviations
const usr = getUsr();
const cfg = loadCfg();
const btn = document.getElementById('btn');
const txn = processTxn();
const msg = fmt(str);

// ✅ GOOD: Full words
const user = getUser();
const config = loadConfig();
const submitButton = document.getElementById('submit-button');
const transaction = processTransaction();
const formattedMessage = formatMessage(input);
```

### 3. Use Domain Terms

Names should reflect the business domain, not technical implementation.

```typescript
// ❌ BAD: Generic, technical names
const data = fetchData();
const items = getItems();
const info = processInfo();
const result = calculate();

// ✅ GOOD: Domain-specific names
const customerOrder = fetchCustomerOrder();
const invoiceLineItems = getInvoiceLineItems();
const shippingDetails = processShippingDetails();
const orderTotal = calculateOrderTotal();
```

---

## Naming by Type

### Variables and Constants

| Type | Convention | Example |
|------|------------|---------|
| Boolean | is/has/can/should prefix | `isActive`, `hasPermission`, `canEdit`, `shouldRetry` |
| Array/Collection | Plural noun | `users`, `orderItems`, `validationErrors` |
| Count/Number | Noun with context | `userCount`, `maxRetries`, `totalPrice` |
| Date/Time | With temporal context | `createdAt`, `expiresOn`, `lastLoginDate` |
| Object | Singular noun | `currentUser`, `selectedItem`, `paymentMethod` |

```typescript
// ❌ BAD
const flag = true;
const list = [];
const num = 5;
const date = new Date();
const obj = {};

// ✅ GOOD
const isEnabled = true;
const activeUsers = [];
const maxLoginAttempts = 5;
const accountCreatedAt = new Date();
const shippingAddress = {};
```

### Functions and Methods

| Purpose | Convention | Example |
|---------|------------|---------|
| Get value | get + Noun | `getUser()`, `getOrderTotal()` |
| Set value | set + Noun | `setStatus()`, `setUserPreferences()` |
| Check condition | is/has/can + Adjective | `isValid()`, `hasAccess()`, `canProceed()` |
| Perform action | Verb + Noun | `createOrder()`, `sendEmail()`, `validateInput()` |
| Convert | to + Target | `toString()`, `toJson()`, `toDisplayFormat()` |
| Find | find + Criteria | `findById()`, `findByEmail()` |
| Calculate | calculate + What | `calculateTax()`, `calculateDiscount()` |

```typescript
// ❌ BAD: Unclear what function does
function process(x: unknown): unknown { ... }
function handle(data: Data): void { ... }
function do(item: Item): Item { ... }

// ✅ GOOD: Clear action and subject
function validateUserInput(input: UserInput): ValidationResult { ... }
function sendOrderConfirmation(order: Order): void { ... }
function applyDiscountToItem(item: Item, discount: Discount): Item { ... }
```

### Classes and Interfaces

| Type | Convention | Example |
|------|------------|---------|
| Class | PascalCase Noun | `UserService`, `OrderRepository`, `PaymentGateway` |
| Interface | PascalCase Noun/Adjective | `Serializable`, `UserData`, `HttpClient` |
| Abstract | Abstract + Noun | `AbstractRepository`, `AbstractHandler` |
| Enum | PascalCase Singular | `OrderStatus`, `PaymentMethod`, `UserRole` |

```typescript
// ❌ BAD
class Data { ... }
class Manager { ... }
class Helper { ... }
class Utils { ... }

// ✅ GOOD
class CustomerProfile { ... }
class OrderProcessingService { ... }
class PaymentValidationHelper { ... }  // If helper is truly needed
class StringFormatUtils { ... }        // If utils is truly needed
```

---

## Common Anti-Patterns

### 1. Single-Letter Names

```typescript
// ❌ BAD: What is x, y, i, j?
function calc(x: number, y: number): number {
  return x * y;
}

for (let i = 0; i < arr.length; i++) {
  const j = arr[i];
  // ...
}

// ✅ GOOD: Meaningful names
function calculateArea(width: number, height: number): number {
  return width * height;
}

for (const user of users) {
  // ...
}

// Exception: Well-known conventions in limited scope
array.map((item, index) => ...)  // index is acceptable
coordinates.forEach((x, y) => ...)  // x, y for coordinates is OK
```

### 2. Meaningless Suffixes

```typescript
// ❌ BAD: Info, Data, Object add no meaning
class UserInfo { ... }
class UserData { ... }
class UserObject { ... }
interface IUser { ... }  // Hungarian notation

// ✅ GOOD: Specific names
class User { ... }
class UserProfile { ... }
class UserCredentials { ... }
interface User { ... }
```

### 3. Negative Booleans

```typescript
// ❌ BAD: Double negatives are confusing
const isNotEnabled = false;
const disableValidation = true;

if (!isNotEnabled) { ... }  // What does this mean?
if (!disableValidation) { ... }  // Confusing

// ✅ GOOD: Positive names
const isEnabled = true;
const shouldValidate = true;

if (isEnabled) { ... }
if (shouldValidate) { ... }
```

### 4. Context Duplication

```typescript
// ❌ BAD: Redundant context
class User {
  userId: string;
  userName: string;
  userEmail: string;
  getUserAge(): number { ... }
}

// ✅ GOOD: Context is implied by class
class User {
  id: string;
  name: string;
  email: string;
  getAge(): number { ... }
}
```

---

## Naming Checklist

- [ ] Does the name reveal intent?
- [ ] Is it free of abbreviations?
- [ ] Does it use domain vocabulary?
- [ ] Is it the appropriate length? (not too short, not too long)
- [ ] Can someone unfamiliar with the code understand it?
- [ ] Is it consistent with similar names in the codebase?
- [ ] Does it avoid negative boolean names?
- [ ] Is context duplication avoided?

---

## Quick Reference

| Category | Bad | Good |
|----------|-----|------|
| Variable | `d`, `data`, `temp` | `orderDate`, `customerData`, `cachedResult` |
| Boolean | `flag`, `status`, `check` | `isActive`, `hasPermission`, `shouldRetry` |
| Function | `process()`, `handle()`, `do()` | `validateOrder()`, `sendEmail()`, `calculateTax()` |
| Class | `Manager`, `Helper`, `Utils` | `OrderProcessor`, `TaxCalculator`, `EmailSender` |
| Constant | `NUM`, `VAL`, `MAX` | `MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT_MS` |
