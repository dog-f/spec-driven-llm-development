# [Module/Service Name]

Last verified: YYYY-MM-DD

[One sentence: what this module does and its role in the larger system.]

## Source Layout

```
module-name/
├── src/
│   ├── [key-directory]/        # [purpose]
│   ├── [key-directory]/        # [purpose]
│   └── [key-file]              # [purpose]
├── tests/
│   └── ...
└── [config-file]               # [purpose]
```

## Key Patterns

### [Pattern Name — e.g., "Request Handling", "Data Access", "Event Processing"]

[One sentence explaining the pattern, then a real code example:]

```typescript
// from src/[actual-path]
[actual code from the module — 5-15 lines showing the pattern]
```

### [Pattern Name #2]

```typescript
// from src/[actual-path]
[actual code]
```

## Testing

```bash
pnpm test                    # run all tests
pnpm test -- --grep "name"  # run specific test
```

[Any setup required before tests run — e.g., "build packages first" or "docker compose up"]

## Common Pitfalls

- [Non-obvious thing #1 — e.g., "X must be called before Y because..."]
- [Non-obvious thing #2 — e.g., "Don't use X directly; always go through Y"]
- [Non-obvious thing #3 — e.g., "Tests will fail if Z isn't running"]

## Related Docs

- `docs/architecture/[relevant-doc].md` — [why it's relevant]
- `docs/guides/[relevant-guide].md` — [when to use it]
