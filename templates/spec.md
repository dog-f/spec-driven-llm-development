# [Feature Name]

Last verified: YYYY-MM-DD

Do not lose information for the sake of conforming to the template.

## Naming

File must be named with a descriptive kebab-case title: `feature-name.md`. If there is an accompanying ticket, prepend the ticket ID: `PROJ-1234-feature-name.md`.

## Location

- New specs go in `docs/specs/todo/`.
- Once the implementation is complete and merged, move the spec to `docs/specs/implemented/`.

## Immutability

Specs are **append-only after creation**. They capture the design intent at a specific point in time. Do not rewrite or delete original content.

**Exception — Open Questions:** Answers may be added freely without an EDIT marker. If an answer needs correction, strike through the original and add the new answer on the next bullet at the same level. Never delete an answered question.

Open Questions may also include rhetorical Q&A: things that might confuse a reader (human or agent) but don't fit cleanly in any other section. Keep these brief.

```markdown
## Open Questions

- Question 1?
  - ~~Original answer that turned out to be wrong~~
  - Corrected answer
- Question 2?
  - Answer added later
- Question 3?
```

If any other section needs correction, add an inline edit directly below the affected content:

> EDIT (YYYY-MM-DD): Correction or clarification here. Include justification.

---

## Problem

What user or system problem does this solve? Why now?

## Proposal

Concrete description of the solution. Include:
- What changes, at a high level
- How users interact with it (if user-facing)

## Affected Components

| Component | Change | Notes |
|---|---|---|
| component-a | What changes | Why |
| component-b | What changes | Why |

## Interface Changes

### New/Modified API Endpoints

```
POST /resource       — create a resource
GET  /resource/:id   — get a resource by ID
```

### New/Modified Data Schemas

```typescript
const ResourceSchema = {
  resourceId: string,
  name: string,
};
```

### Inter-Component Contract Changes

Describe any changes to data passed between components (HTTP bodies, message payloads).

## Implementation Notes

Key technical decisions, constraints, or non-obvious approaches.

## Open Questions

- Unanswered question?
