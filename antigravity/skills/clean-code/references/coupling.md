# Coupling

Coupling measures the degree of interdependence between modules.

**Goal**: LOW coupling - modules should be as independent as possible.

---

## The Levels of Coupling (Worst to Best)

### 1. Content Coupling (WORST - MUST AVOID)

One module modifies or depends on the internal implementation of another.

```typescript
// ❌ BAD: Accessing private implementation details
class Database {
  private _connection: Connection | null = null;

  connect(): void {
    this._connection = createConnection();
  }
}

// Another module directly accesses private state
const db = new Database();
db._connection = mockConnection;  // Bypassing public API!
db._connection.query('...');      // Depending on internal structure!
```

**Problem**: Changes to internal implementation break dependent code.

---

### 2. Common Coupling (MUST AVOID)

Multiple modules share global mutable state.

```typescript
// ❌ BAD: Shared global state
const globalState = {
  currentUser: null as User | null,
  settings: {} as Settings,
  cache: new Map<string, unknown>(),
};

// Module A
function login(user: User): void {
  globalState.currentUser = user;
  globalState.settings = user.settings;
}

// Module B
function getUsername(): string {
  return globalState.currentUser?.name ?? 'Guest';
}

// Module C
function clearCache(): void {
  globalState.cache.clear();
}
```

**Problem**: Any module can change shared state, causing unpredictable side effects.

---

### 3. External Coupling (MINIMIZE)

Modules share an external data format, protocol, or interface.

```typescript
// ⚠️ External coupling to specific API format
interface ExternalApiResponse {
  status_code: number;  // External format dictates structure
  result_data: unknown;
  error_message?: string;
}

function processApiResponse(response: ExternalApiResponse): void {
  if (response.status_code === 200) {
    handleSuccess(response.result_data);
  } else {
    handleError(response.error_message);
  }
}
```

**Mitigation**: Create adapters to isolate external formats from internal code.

```typescript
// ✅ BETTER: Adapter isolates external format
interface InternalResult<T> {
  readonly success: boolean;
  readonly data?: T;
  readonly error?: string;
}

function adaptApiResponse<T>(response: ExternalApiResponse): InternalResult<T> {
  return response.status_code === 200
    ? { success: true, data: response.result_data as T }
    : { success: false, error: response.error_message };
}
```

---

### 4. Control Coupling (SHOULD AVOID)

One module passes a control flag to direct another module's behavior.

```typescript
// ❌ BAD: Flag controls internal behavior
function formatOutput(data: Data, asJson: boolean): string {
  if (asJson) {
    return JSON.stringify(data);
  } else {
    return formatAsText(data);
  }
}

// Caller must know internal implementation details
const output = formatOutput(data, true);  // What does true mean?
```

```typescript
// ✅ GOOD: Separate functions with clear names
function formatAsJson(data: Data): string {
  return JSON.stringify(data);
}

function formatAsText(data: Data): string {
  return Object.entries(data)
    .map(([key, value]) => `${key}: ${value}`)
    .join('\n');
}

// Or use strategy pattern
type Formatter = (data: Data) => string;

function formatOutput(data: Data, formatter: Formatter): string {
  return formatter(data);
}
```

---

### 5. Stamp Coupling (ACCEPTABLE)

Modules share a composite data structure, but only use parts of it.

```typescript
// ⚠️ ACCEPTABLE: Passing entire object when only part is needed
interface User {
  id: string;
  name: string;
  email: string;
  address: Address;
  preferences: Preferences;
  // ... many more fields
}

function sendWelcomeEmail(user: User): void {
  // Only uses email and name
  sendEmail({
    to: user.email,
    subject: `Welcome, ${user.name}!`,
    body: '...',
  });
}
```

```typescript
// ✅ BETTER: Pass only what's needed
function sendWelcomeEmail(email: string, name: string): void {
  sendEmail({
    to: email,
    subject: `Welcome, ${name}!`,
    body: '...',
  });
}

// Or define a minimal interface
interface EmailRecipient {
  readonly email: string;
  readonly name: string;
}

function sendWelcomeEmail(recipient: EmailRecipient): void { ... }
```

---

### 6. Data Coupling (GOOD)

Modules communicate by passing only the necessary primitive data or simple objects.

```typescript
// ✅ GOOD: Passing only necessary data
function calculateTotal(price: number, quantity: number): number {
  return price * quantity;
}

function formatPrice(amount: number, currency: string): string {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
  }).format(amount);
}

// Usage
const total = calculateTotal(item.price, item.quantity);
const formatted = formatPrice(total, 'USD');
```

---

### 7. Message Coupling (BEST)

Modules communicate only through messages/events with no direct dependencies.

```typescript
// ✅ BEST: Event-based communication
interface Event<T = unknown> {
  readonly type: string;
  readonly payload: T;
}

type EventHandler<T> = (payload: T) => void;

class EventBus {
  private handlers = new Map<string, EventHandler<unknown>[]>();

  subscribe<T>(eventType: string, handler: EventHandler<T>): void {
    const existing = this.handlers.get(eventType) ?? [];
    this.handlers.set(eventType, [...existing, handler as EventHandler<unknown>]);
  }

  publish<T>(event: Event<T>): void {
    const handlers = this.handlers.get(event.type) ?? [];
    handlers.forEach(handler => handler(event.payload));
  }
}

// Modules don't know about each other
// Order module
eventBus.publish({ type: 'ORDER_CREATED', payload: order });

// Notification module
eventBus.subscribe('ORDER_CREATED', (order) => {
  sendOrderConfirmation(order);
});

// Analytics module
eventBus.subscribe('ORDER_CREATED', (order) => {
  trackConversion(order);
});
```

---

## Reducing Coupling

### 1. Dependency Injection

```typescript
// ❌ BAD: Hard dependency
class UserService {
  private db = new PostgresDatabase();  // Tightly coupled

  getUser(id: string): User {
    return this.db.query('SELECT * FROM users WHERE id = ?', [id]);
  }
}

// ✅ GOOD: Injected dependency
interface Database {
  query<T>(sql: string, params: unknown[]): T;
}

class UserService {
  constructor(private readonly db: Database) {}

  getUser(id: string): User {
    return this.db.query('SELECT * FROM users WHERE id = ?', [id]);
  }
}

// Easy to test and swap implementations
const userService = new UserService(mockDatabase);
```

### 2. Interface Segregation

```typescript
// ❌ BAD: Fat interface creates unnecessary coupling
interface DataService {
  create(data: Data): Data;
  read(id: string): Data;
  update(id: string, data: Data): Data;
  delete(id: string): void;
  export(format: string): Buffer;
  import(file: Buffer): void;
  validate(data: Data): boolean;
}

// ✅ GOOD: Segregated interfaces
interface DataReader {
  read(id: string): Data;
}

interface DataWriter {
  create(data: Data): Data;
  update(id: string, data: Data): Data;
  delete(id: string): void;
}

interface DataValidator {
  validate(data: Data): boolean;
}
```

---

## Quick Reference

| Level | Name | Quality | Action |
|-------|------|---------|--------|
| 1 | Content | Worst | MUST eliminate |
| 2 | Common | Very Bad | MUST eliminate |
| 3 | External | Bad | Minimize, use adapters |
| 4 | Control | Poor | SHOULD refactor |
| 5 | Stamp | OK | Consider narrowing |
| 6 | Data | Good | Aim for this |
| 7 | Message | Best | Ideal for decoupling |
