# Orion Commerce — Order Platform Backend

Last verified: 2026-08-01

**Orion Commerce** is a headless e-commerce platform that handles order lifecycle management, inventory tracking, and fulfillment orchestration. Merchants integrate via REST APIs and webhooks; the storefront lives in a separate repo (`orion-storefront`) — **this repo is the backend** that processes orders, manages inventory, handles payments, and coordinates fulfillment.

This is a pnpm monorepo with 4 deployable services and 6 shared packages.

## Hard Rules

- Security guardrails in `.github/rules/security.md` are non-negotiable. Review before any code change.
- All Node.js services use the **Nexus** framework for bootstrapping. See `docs/architecture/nexus-framework.md`.
- Conventional commits enforced by commitlint. Format: `type(scope): message`.
- Never modify `.env` or commit credentials. Secrets come from Vault (`make get-secrets`).
- Services communicate via HTTP with JWT auth or via NATS. See `docs/architecture/messaging.md`.
- All monetary values are stored as integers in the smallest currency unit (cents). Never use floats for money.

## Service Map

| Service | Directory | Purpose | Language |
|---|---|---|---|
| order-service | `services/order-service` | Order CRUD, state machine, checkout orchestration | TypeScript |
| inventory-service | `services/inventory-service` | Stock levels, reservations, warehouse sync | TypeScript |
| notification-service | `services/notification-service` | Email, SMS, webhook dispatch for order events | TypeScript |
| gateway | `services/gateway` | Public API routing, merchant auth, rate limiting | Go |

Each service has an `AGENTS.md` with service-specific conventions, source layout, and patterns.

## Package Graph

```
schema (foundation: shared types, Zod schemas, currency utilities)
    ├── events (typed event definitions for inter-service messaging)
    │   ├── order-engine (order state machine, transition rules)
    │   └── fulfillment (shipping provider adapters, label generation)
    ├── pricing (tax calculation, discount rules, promo codes)
    └── merchant-sdk (merchant-facing SDK for webhook verification)
```

See `packages/AGENTS.md` for per-package details or `docs/architecture/package-graph.md` for the full dependency chain.

## Architecture Docs (read as needed)

- `docs/architecture/system-overview.md` — service topology, inter-service communication
- `docs/architecture/order-lifecycle.md` — order creation → payment → fulfillment → delivery
- `docs/architecture/nexus-framework.md` — Nexus module system used by all Node services
- `docs/architecture/data-stores.md` — PostgreSQL tables, Redis key patterns
- `docs/architecture/messaging.md` — NATS subjects, event patterns

## How-To Guides

- `docs/guides/adding-a-route.md` — add a route to order-service (with real code)
- `docs/guides/adding-a-payment-provider.md` — integrate a new payment gateway end-to-end

## Spec-First Workflow

New features start as specs in `docs/specs/todo/`. Use `docs/specs/TEMPLATE.md` as the starting point. Write the spec → get review → merge → then implement. Move to `docs/specs/implemented/` when done.

## Documentation Rules

These docs are optimized for AI agent consumption. **If you change code, update the affected docs.**

1. **Layered retrieval** — Root → per-service → architecture → guides. Read deeper only when needed.
2. **Keep docs fresh** — update "Last verified" dates when touching related code.
3. **Critical info at edges** — start or end of document, never the middle.
4. **Curate hard** — under 200 lines. Shorter is better.
5. **Concrete examples** — real code from this codebase, not abstract prose.
6. **Reference actual code** — not generic patterns.
7. **Exact interfaces** — real names, real paths, real ports.
8. **Don't over-invest in format** — clarity over template conformance.
9. **Cite with links** — actual URLs to external resources.
10. **Describe the present** — not the past.

## Local Development

```bash
make get-secrets                       # pull .env from Vault
docker compose up -d                   # start Postgres, Redis, NATS
make healthz                           # verify all services are up
```

## Build & Test

```bash
pnpm install                           # install all workspace dependencies
pnpm run build                         # build all packages (required before service tests)
pnpm run test                          # test all packages

# Per-service:
cd services/<name> && pnpm test        # run all tests for a service
cd services/<name> && pnpm run dev     # start service in dev mode
```
