# [Decision Title]

Date: YYYY-MM-DD

Do not lose information for the sake of conforming to the template.

## Naming

File must be named with a descriptive kebab-case title: `decision-title.md` (e.g., `use-kafka-for-events.md`).

## Immutability

Decision records are **append-only after creation**. They capture the reasoning at a specific point in time. Do not rewrite or delete original content.

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

If a decision needs correction or superseding, add an inline edit:

> EDIT (YYYY-MM-DD): Correction or clarification here. Include justification.

If fully superseded:

> EDIT (YYYY-MM-DD): Superseded by `new-decision.md`. Reason: ...

---

## Context

What situation or problem prompted this decision? Include relevant constraints.

## Decision

What we decided and why.

## Consequences

What changes as a result — both benefits and trade-offs. Include any follow-up work needed.

## Open Questions

- Unanswered question?
