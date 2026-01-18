# Data Interfaces

MUST define data structures with interfaces/types.

---

## Basic Interface Definition

```typescript
// ❌ BAD: Inline object types
function processUser(user: { name: string; email: string }) { ... }
function getConfig(): { host: string; port: number } { ... }

// ❌ BAD: Using any
function processUser(user: any) { ... }

// ✅ GOOD: Explicit interface definitions
interface User {
  readonly id: string;
  readonly name: string;
  readonly email: string;
  readonly createdAt: Date;
}

interface Config {
  readonly host: string;
  readonly port: number;
}

function processUser(user: User): ProcessedUser { ... }
function getConfig(): Config { ... }
```

---

## Readonly by Default

SHOULD use `readonly` for immutable data.

```typescript
// ✅ GOOD: Readonly interface
interface User {
  readonly id: string;
  readonly name: string;
  readonly email: string;
}

// ✅ GOOD: Readonly arrays
interface State {
  readonly items: readonly Item[];
  readonly selectedId: string | null;
  readonly isLoading: boolean;
}

// ✅ GOOD: Nested readonly
interface Order {
  readonly id: string;
  readonly customer: {
    readonly id: string;
    readonly name: string;
  };
  readonly items: readonly OrderItem[];
}
```

---

## Discriminated Unions

SHOULD use discriminated unions for type-safe pattern matching.

```typescript
// ❌ BAD: Type assertions
function handleResponse(response: any) {
  if (response.success) {
    return (response as SuccessResponse).data;
  }
  throw new Error((response as ErrorResponse).message);
}

// ✅ GOOD: Discriminated union
type ApiResponse<T> =
  | { readonly type: 'success'; readonly data: T }
  | { readonly type: 'error'; readonly message: string };

function handleResponse<T>(response: ApiResponse<T>): T {
  switch (response.type) {
    case 'success':
      return response.data;  // TypeScript knows this is T
    case 'error':
      throw new Error(response.message);  // TypeScript knows this is string
  }
}
```

### More Discriminated Union Examples

```typescript
// State machine
type ConnectionState =
  | { readonly status: 'disconnected' }
  | { readonly status: 'connecting'; readonly attempt: number }
  | { readonly status: 'connected'; readonly socket: WebSocket }
  | { readonly status: 'error'; readonly error: Error };

function getStatusMessage(state: ConnectionState): string {
  switch (state.status) {
    case 'disconnected':
      return 'Not connected';
    case 'connecting':
      return `Connecting... (attempt ${state.attempt})`;
    case 'connected':
      return 'Connected';
    case 'error':
      return `Error: ${state.error.message}`;
  }
}

// Action types (Redux-style)
type UserAction =
  | { readonly type: 'USER_LOGIN'; readonly payload: { userId: string } }
  | { readonly type: 'USER_LOGOUT' }
  | { readonly type: 'USER_UPDATE'; readonly payload: Partial<User> };
```

---

## Function Parameter Objects

SHOULD use interfaces for functions with 3+ parameters.

```typescript
// ❌ BAD: Too many parameters
function createUser(
  name: string,
  email: string,
  age: number,
  address: string,
  phone: string,
  role: string
) { ... }

// ✅ GOOD: Parameter object with interface
interface CreateUserInput {
  readonly name: string;
  readonly email: string;
  readonly age: number;
  readonly address?: string;
  readonly phone?: string;
  readonly role: UserRole;
}

function createUser(input: CreateUserInput): User { ... }

// Usage is clearer
createUser({
  name: 'Alice',
  email: 'alice@example.com',
  age: 30,
  role: 'admin',
});
```

---

## Type Composition

### Intersection Types

```typescript
interface Timestamped {
  readonly createdAt: Date;
  readonly updatedAt: Date;
}

interface Identifiable {
  readonly id: string;
}

// Combine types
type Entity = Identifiable & Timestamped;

interface User extends Entity {
  readonly name: string;
  readonly email: string;
}
```

### Utility Types

```typescript
interface User {
  readonly id: string;
  readonly name: string;
  readonly email: string;
  readonly password: string;
}

// Pick specific fields
type PublicUser = Pick<User, 'id' | 'name'>;

// Omit fields
type UserWithoutPassword = Omit<User, 'password'>;

// Make all optional
type PartialUser = Partial<User>;

// Make all required
type RequiredUser = Required<PartialUser>;

// Make all readonly
type ImmutableUser = Readonly<User>;
```

---

## Domain Types (Value Objects)

SHOULD create specific types for domain concepts.

```typescript
// ❌ BAD: Primitive obsession
function sendEmail(to: string, from: string, subject: string) { ... }
// Easy to mix up parameters!

// ✅ GOOD: Domain types
type EmailAddress = string & { readonly __brand: 'EmailAddress' };
type Subject = string & { readonly __brand: 'Subject' };

function createEmailAddress(email: string): EmailAddress {
  if (!isValidEmail(email)) {
    throw new Error('Invalid email');
  }
  return email as EmailAddress;
}

function sendEmail(
  to: EmailAddress,
  from: EmailAddress,
  subject: Subject
) { ... }

// Type system prevents mixing up parameters
const to = createEmailAddress('to@example.com');
const from = createEmailAddress('from@example.com');
```

---

## Quick Checklist

- [ ] Are data structures defined with explicit interfaces?
- [ ] Are properties marked as `readonly` where appropriate?
- [ ] Are arrays marked as `readonly` where appropriate?
- [ ] Are discriminated unions used instead of type assertions?
- [ ] Are parameter objects used for 3+ parameters?
- [ ] Are domain-specific types used instead of primitives?
