# Order Service

Last verified: 2026-08-01

Manages the full order lifecycle. Handles checkout orchestration, payment processing, state transitions, and refunds. Publishes order events to NATS for downstream consumers (notifications, analytics).

## Source Layout

```
services/order-service/
├── src/
│   ├── modules/              # Nexus modules (database, payments, events)
│   ├── routes/               # Express route handlers (orders, checkout, refunds)
│   ├── models/               # Mongoose models (Order, LineItem, Payment)
│   ├── state-machine/        # Order state definitions and transition guards
│   └── index.ts              # Nexus app bootstrap
├── tests/
│   ├── unit/
│   └── integration/
├── Dockerfile
└── package.json
```

## Key Patterns

### Route Handlers

All routes follow the Nexus controller pattern. The handler receives typed request params and returns a response object:

```typescript
// from src/routes/orders/get-order.ts
export const getOrder = defineRoute({
  method: 'GET',
  path: '/orders/:orderId',
  schema: { params: z.object({ orderId: z.string().uuid() }) },
  handler: async (req, ctx) => {
    const order = await ctx.db.orders.findById(req.params.orderId);
    if (!order) throw new NotFoundError('Order not found');
    return { status: 200, body: order.toJSON() };
  },
});
```

### State Machine Transitions

Order state changes go through the state machine. Transitions are guarded — invalid ones throw:

```typescript
// from src/state-machine/transitions.ts
export const ORDER_TRANSITIONS: TransitionMap = {
  draft:      ['pending'],
  pending:    ['paid', 'cancelled'],
  paid:       ['fulfilling', 'refunded'],
  fulfilling: ['shipped', 'refunded'],
  shipped:    ['delivered', 'returned'],
  delivered:  ['returned'],
};

export function transitionOrder(order: Order, targetState: OrderState): Order {
  const allowed = ORDER_TRANSITIONS[order.state];
  if (!allowed?.includes(targetState)) {
    throw new ConflictError(`Cannot transition from ${order.state} to ${targetState}`);
  }
  return { ...order, state: targetState, updatedAt: new Date() };
}
```

### Event Publishing

After every state transition, the service publishes to NATS:

```typescript
// from src/modules/events-module.ts
await this.nats.publish(`orders.${order.id}.${newState}`, {
  orderId: order.id,
  merchantId: order.merchantId,
  previousState: oldState,
  newState,
  timestamp: Date.now(),
});
```

## Testing

```bash
pnpm test                              # all tests (unit + integration)
pnpm test -- --grep "checkout"         # specific test
```

Integration tests require infrastructure: `docker compose up -d` from root first.

## Common Pitfalls

- **Build packages before running tests** — order-service depends on `@orion/schema` and `@orion/events`. Run `pnpm run build` from root if you get import errors.
- **Idempotency keys** — all checkout and payment endpoints require an `Idempotency-Key` header. The key is stored in Redis with a 24h TTL. Duplicate requests return the cached response.
- **State machine is the authority** — never update `order.state` directly in the database. Always go through `transitionOrder()` to enforce guard conditions.

## Related Docs

- `docs/architecture/order-lifecycle.md` — end-to-end flow from cart to delivery
- `docs/architecture/messaging.md` — NATS subject hierarchy and event schemas
- `docs/guides/adding-a-payment-provider.md` — how to integrate a new payment gateway
