# [Architecture Topic]

Last verified: YYYY-MM-DD

[One-paragraph summary of what this document covers and why it matters.]

## [Primary Section — e.g., "Topology", "Data Flow", "Component Interactions"]

[ASCII diagram if helpful:]

```
┌─────────────┐    HTTP     ┌─────────────┐
│  Service A  │ ──────────► │  Service B  │
└─────────────┘             └─────────────┘
       │                           │
       │ publish                   │ subscribe
       ▼                           ▼
┌─────────────────────────────────────────┐
│              Message Broker             │
└─────────────────────────────────────────┘
```

[Explanation of the diagram — what communicates with what, using what protocol, and why.]

## [Supporting Section — e.g., "Data Stores", "Authentication", "Key Decisions"]

| [Column A] | [Column B] | [Column C] |
|---|---|---|
| [Real value] | [Real value] | [Real value] |
| [Real value] | [Real value] | [Real value] |

## [Implementation Details Section — e.g., "Configuration", "Environment Variables"]

[Concrete, specific details — real port numbers, real env var names, real file paths.]

## [Gotchas / Constraints Section (if applicable)]

- [Non-obvious constraint or edge case]
- [Something that will bite you if you don't know about it]
