## Working with Agents

**Start here:** Read the [10 Design Principles](https://github.com/dog-f/spec-driven-llm-development/blob/main/research/evidence-and-guidelines.md#4-design-principles-plain-language-summary) behind this repo's documentation — it explains *why* this repo is documented the way it is, backed by empirical research on what actually helps AI agents generate correct code.

Here is the [full research synthesis](https://github.com/dog-f/spec-driven-llm-development/blob/main/research/evidence-and-guidelines.md).

### The Spec-First Workflow

Features are built in two phases:

1. **Spec PR (no code).** Write a spec in `docs/specs/todo/` using the template.
   This PR contains only the spec document. Merge it after review — it is now
   the source of truth for the feature's design.

2. **Implementation PR(s).** With the spec merged, start building. The spec may
   include a "PR Breakdown" section outlining the implementation PRs and their
   dependencies. Each implementation PR references the spec it fulfills.

3. **Move the spec.** Once implementation is complete, move the spec from
   `docs/specs/todo/` to `docs/specs/implemented/` (`/update-docs` does this for you).

This separation ensures the design is reviewed and agreed upon *before* code is
written — whether by a human or an agent. An agent given a merged spec can
implement against a stable target rather than a moving one.

### Non-Negotiable Rules

1. **Human-review all code before it merges.** Agent-generated code must be read
   and understood by a person, not merged on trust. You own what you ship.

2. **Keep the docs current.** When you change code, update the affected `AGENTS.md`
   and `docs/architecture/*` files in the same change. Stale docs cause agents to
   generate confidently wrong code on the next task.

### Agent Skills

This repo ships skills in `.claude/skills/` that agents can invoke:

| Skill | Command | Purpose |
|---|---|---|
| `update-docs` | `/update-docs` | Audit and update all docs affected by your code changes |
| `audit-docs` | `/audit-docs` | Verify all docs against current codebase state to catch drift |
| `find-missing-context` | `/find-missing-context` | Search Slack, tickets, wiki, and other repos before guessing at missing context |

To use: after completing a feature, run `/update-docs`. The skill reads the root
`AGENTS.md` documentation rules and walks through the full update workflow.
