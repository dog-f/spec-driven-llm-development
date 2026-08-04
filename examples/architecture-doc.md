# System Overview

Last verified: 2026-08-01

The Orion Commerce backend consists of 4 services that manage the order lifecycle: order processing, inventory management, notifications, and public API access. Services communicate via HTTP (synchronous) and NATS (async events). All Node.js services are built on the Nexus framework.

## Service Topology

```
                    ┌──────────────────────────────────────────────┐
                    │               Public Internet                │
                    └──────────────────────┬───────────────────────┘
                                           │
                                    ┌──────▼──────┐
                                    │   Gateway   │ :80 (Go)
                                    │  (auth,     │
                                    │   routing)  │
                                    └──────┬──────┘
                                           │ HTTP (JWT)
                          ┌────────────────┼────────────────┐
                          │                │                │
                   ┌──────▼──────┐  ┌──────▼──────┐  ┌─────▼───────┐
                   │   Order     │  │  Inventory  │  │ Notification│
                   │   Service   │  │  Service    │  │  Service    │
                   │   :3000     │  │  :3001      │  │  :3002      │
                   └──────┬──────┘  └──────┬──────┘  └─────────────┘
                          │                │
                          │                │
                    ┌─────▼────────────────▼──────────────────────┐
                    │                    NATS                      │
                    │  (order events, inventory updates, webhooks) │
                    └─────────────────────────────────────────────┘
```

## Communication Matrix

| From | To | Protocol | Auth | Purpose |
|---|---|---|---|---|
| Gateway | Order Service | HTTP | JWT (forwarded) | Order CRUD, checkout |
| Gateway | Inventory Service | HTTP | JWT (forwarded) | Stock queries |
| Order Service | Inventory Service | HTTP | Service token | Reserve stock during checkout |
| Order Service | NATS | NATS | Connection string | Publish order state changes |
| Notification Service | NATS | NATS | Connection string | Subscribe to order events, dispatch alerts |
| Inventory Service | NATS | NATS | Connection string | Publish stock level changes |

## Infrastructure Dependencies

| Dependency | Purpose | Connection |
|---|---|---|
| PostgreSQL 15 | Primary data store (orders, inventory, merchants) | `DATABASE_URL` env var |
| Redis 7 | Session cache, rate limiting, idempotency keys | `REDIS_URL` env var |
| NATS 2.10 | Async event bus (JetStream for durability) | `NATS_URL` env var |

## Service Responsibilities

**Order Service** — the core of the platform. Manages order state machine (draft → pending → paid → fulfilling → shipped → delivered), checkout orchestration, payment provider integration, and refund processing.

**Inventory Service** — tracks stock levels per SKU per warehouse. Handles reservations (soft locks during checkout), decrements on fulfillment, and syncs with external warehouse management systems via scheduled imports.

**Notification Service** — event-driven, no direct API. Subscribes to order and inventory events via NATS, dispatches emails (SendGrid), SMS (Twilio), and merchant webhooks. Handles retry logic and delivery tracking.

**Gateway** — Go service, hexagonal architecture. Authenticates merchant API keys, routes to backend services, enforces per-merchant rate limits. The only service exposed to the public internet.

## Key Invariants

- All Node.js services run on their designated port and expose `/health` for readiness checks.
- Gateway is the only ingress point — backend services are not directly reachable from outside the cluster.
- Order state transitions are validated by the state machine — invalid transitions return 409 Conflict.
- Inventory reservations expire after 15 minutes if checkout is not completed (Redis TTL).
- All monetary values are integers in the smallest currency unit. The `@orion/schema` package provides `Money` type utilities.
