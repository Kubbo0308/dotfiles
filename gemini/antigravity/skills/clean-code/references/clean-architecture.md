# Clean Architecture

Architecture that keeps business logic independent of frameworks, databases, and UI.

---

## The Dependency Rule

**Source code dependencies MUST point inward only.**

```
┌──────────────────────────────────────────────────────────────┐
│                  Frameworks & Drivers                         │
│  (Web Framework, Database, External APIs, UI)                │
│  ┌──────────────────────────────────────────────────────┐    │
│  │              Interface Adapters                       │    │
│  │  (Controllers, Presenters, Gateways, Repositories)   │    │
│  │  ┌──────────────────────────────────────────────┐    │    │
│  │  │            Application Layer                  │    │    │
│  │  │  (Use Cases, Application Services)           │    │    │
│  │  │  ┌──────────────────────────────────────┐    │    │    │
│  │  │  │         Domain Layer                  │    │    │    │
│  │  │  │  (Entities, Value Objects,           │    │    │    │
│  │  │  │   Domain Services)                   │    │    │    │
│  │  │  └──────────────────────────────────────┘    │    │    │
│  │  └──────────────────────────────────────────────┘    │    │
│  └──────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────┘

Dependencies: Outer → Inner (NEVER Inner → Outer)
```

**Key Rule**: Inner layers MUST NOT know about outer layers.

---

## The Four Layers

### 1. Domain Layer (Innermost - Most Stable)

Contains enterprise business rules that rarely change.

```typescript
// Entity: Core business object with identity
class Order {
  constructor(
    readonly id: OrderId,
    readonly customerId: CustomerId,
    private items: readonly OrderItem[],
    private status: OrderStatus
  ) {}

  // Business rule: Order total calculation
  getTotal(): Money {
    return this.items.reduce(
      (total, item) => total.add(item.getSubtotal()),
      Money.zero()
    );
  }

  // Business rule: Can only cancel pending orders
  cancel(): Order {
    if (this.status !== OrderStatus.Pending) {
      throw new OrderCannotBeCancelledError(this.id);
    }
    return new Order(this.id, this.customerId, this.items, OrderStatus.Cancelled);
  }
}

// Value Object: Immutable, equality by value
class Money {
  constructor(
    readonly amount: number,
    readonly currency: string
  ) {}

  add(other: Money): Money {
    if (this.currency !== other.currency) {
      throw new CurrencyMismatchError();
    }
    return new Money(this.amount + other.amount, this.currency);
  }

  equals(other: Money): boolean {
    return this.amount === other.amount && this.currency === other.currency;
  }
}
```

**Contains**: Entities, Value Objects, Domain Events, Domain Services

---

### 2. Application Layer (Use Cases)

Contains application-specific business rules.

```typescript
// Use Case: Application-specific orchestration
interface CreateOrderUseCase {
  execute(input: CreateOrderInput): Promise<CreateOrderOutput>;
}

interface CreateOrderInput {
  readonly customerId: string;
  readonly items: readonly { productId: string; quantity: number }[];
}

interface CreateOrderOutput {
  readonly orderId: string;
  readonly total: number;
}

// Implementation depends only on abstractions
class CreateOrderUseCaseImpl implements CreateOrderUseCase {
  constructor(
    private readonly orderRepository: OrderRepository,  // Interface
    private readonly productRepository: ProductRepository,  // Interface
    private readonly eventPublisher: EventPublisher  // Interface
  ) {}

  async execute(input: CreateOrderInput): Promise<CreateOrderOutput> {
    // 1. Validate and get products
    const products = await this.productRepository.findByIds(
      input.items.map(i => i.productId)
    );

    // 2. Create order (domain logic)
    const orderItems = input.items.map(item => {
      const product = products.find(p => p.id === item.productId);
      if (!product) throw new ProductNotFoundError(item.productId);
      return OrderItem.create(product, item.quantity);
    });

    const order = Order.create(input.customerId, orderItems);

    // 3. Persist
    await this.orderRepository.save(order);

    // 4. Publish event
    await this.eventPublisher.publish(new OrderCreatedEvent(order));

    return {
      orderId: order.id.value,
      total: order.getTotal().amount,
    };
  }
}
```

**Contains**: Use Cases, Application Services, DTOs, Port Interfaces

---

### 3. Interface Adapters Layer

Converts data between use cases and external systems.

```typescript
// Controller: Adapts HTTP to Use Case
class OrderController {
  constructor(private readonly createOrderUseCase: CreateOrderUseCase) {}

  async createOrder(req: HttpRequest): Promise<HttpResponse> {
    try {
      // Adapt HTTP request to use case input
      const input: CreateOrderInput = {
        customerId: req.body.customer_id,  // snake_case → camelCase
        items: req.body.items.map((item: any) => ({
          productId: item.product_id,
          quantity: item.qty,
        })),
      };

      const output = await this.createOrderUseCase.execute(input);

      // Adapt use case output to HTTP response
      return {
        status: 201,
        body: {
          order_id: output.orderId,
          total_amount: output.total,
        },
      };
    } catch (error) {
      return this.handleError(error);
    }
  }
}

// Repository Implementation: Adapts Use Case to Database
class PostgresOrderRepository implements OrderRepository {
  constructor(private readonly db: Database) {}

  async save(order: Order): Promise<void> {
    // Adapt domain object to database schema
    await this.db.query(
      'INSERT INTO orders (id, customer_id, status, created_at) VALUES ($1, $2, $3, $4)',
      [order.id.value, order.customerId.value, order.status, new Date()]
    );

    for (const item of order.items) {
      await this.db.query(
        'INSERT INTO order_items (order_id, product_id, quantity, price) VALUES ($1, $2, $3, $4)',
        [order.id.value, item.productId.value, item.quantity, item.price.amount]
      );
    }
  }
}
```

**Contains**: Controllers, Presenters, Gateways, Repository Implementations

---

### 4. Frameworks & Drivers Layer (Outermost)

Glue code for external tools and frameworks.

```typescript
// Express route configuration
const router = express.Router();
router.post('/orders', (req, res) => orderController.createOrder(req, res));

// Database connection setup
const db = new Pool({
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT),
  database: process.env.DB_NAME,
});

// Dependency injection setup
const orderRepository = new PostgresOrderRepository(db);
const productRepository = new PostgresProductRepository(db);
const eventPublisher = new KafkaEventPublisher(kafkaClient);
const createOrderUseCase = new CreateOrderUseCaseImpl(
  orderRepository,
  productRepository,
  eventPublisher
);
const orderController = new OrderController(createOrderUseCase);
```

**Contains**: Framework configs, Database drivers, External service clients

---

## Benefits

| Benefit | Description |
|---------|-------------|
| **Framework Independent** | Business logic doesn't depend on Express, React, etc. |
| **Testable** | Use cases can be tested without UI, DB, or external services |
| **UI Independent** | Can swap web UI for CLI or mobile without changing business logic |
| **Database Independent** | Can swap Postgres for MongoDB without changing business logic |
| **Independent of External Agencies** | Business rules don't know about external world |

---

## Common Mistakes

### ❌ Domain depends on Framework

```typescript
// ❌ BAD: Entity depends on ORM decorator
import { Entity, Column } from 'typeorm';

@Entity()
class Order {
  @Column()
  status: string;
}
```

### ✅ Domain is Pure

```typescript
// ✅ GOOD: Pure domain object
class Order {
  constructor(
    readonly id: OrderId,
    readonly status: OrderStatus
  ) {}
}

// ORM mapping in infrastructure layer
@Entity('orders')
class OrderEntity {
  @Column()
  id: string;

  @Column()
  status: string;

  toDomain(): Order {
    return new Order(new OrderId(this.id), this.status as OrderStatus);
  }
}
```

---

## Quick Reference

| Layer | Contains | Depends On |
|-------|----------|------------|
| Domain | Entities, Value Objects | Nothing |
| Application | Use Cases, Ports | Domain |
| Adapters | Controllers, Repositories | Application, Domain |
| Frameworks | Configs, Drivers | Everything |
