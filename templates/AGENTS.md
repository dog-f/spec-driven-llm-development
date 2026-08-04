# [Project Name]

Last verified: YYYY-MM-DD

**[One-paragraph description of what this project IS and what it does. Not its history, not its aspirations — what it does RIGHT NOW. Be specific: mention the domain, the user-facing product, and the role of this codebase within it.]**

[Optional: if this is part of a larger system, state what this repo's boundary is — e.g., "this is the backend; the frontend lives at [repo-link]"]

## Hard Rules

- [Non-negotiable constraint #1 — e.g., security guardrails location]
- [Non-negotiable constraint #2 — e.g., framework requirement]
- [Non-negotiable constraint #3 — e.g., commit conventions]
- [Non-negotiable constraint #4 — e.g., secrets management]
- [Non-negotiable constraint #5 — e.g., communication patterns]

## Service Map / Component Map

| Component | Directory | Purpose | Language |
|---|---|---|---|
| component-a | `path/to/component-a` | What it does | TypeScript |
| component-b | `path/to/component-b` | What it does | Go |

Each component has an `AGENTS.md` with component-specific conventions, source layout, and patterns.

## Dependency Graph (if applicable)

```
foundation-package
    ├── mid-level-package-a
    │   ├── consumer-package-1
    │   └── consumer-package-2
    └── mid-level-package-b
        └── consumer-package-3
```

## Sibling Repos (if applicable)

[Services or packages outside this repository that an agent may need to reference. Include local paths if checked out, or clone URLs if the agent should fetch them to `/tmp`.]

| Repo | Local Path / Clone URL | Purpose |
|---|---|---|
| [frontend-app] | `~/path/to/frontend` or `git@github.com:org/frontend.git` | The UI that consumes this backend's APIs |
| [shared-lib] | `/tmp/shared-lib` (clone if needed) | Shared types/contracts used by multiple services |

## Architecture Docs (read as needed)

- `docs/architecture/system-overview.md` — [one-line description]
- `docs/architecture/[topic].md` — [one-line description]

## How-To Guides

- `docs/guides/[task].md` — [one-line description]

## Spec-First Workflow

New features start as specs in `docs/specs/todo/`. Use `docs/specs/TEMPLATE.md` as the starting point. Write the spec → get review → merge → then implement. Once implementation is complete, move the spec to `docs/specs/implemented/`.

## Documentation Rules

These docs are optimized for AI agent consumption based on empirical research. **If you change code, update the affected docs.** Stale documentation is a defect.

1. **Layered retrieval** — Root `AGENTS.md` → per-module `AGENTS.md` → architecture docs → guides. Read deeper only when needed.
2. **Keep docs fresh** — update "Last verified" dates when you touch related code.
3. **Critical info at edges** — start or end of document, never the middle.
4. **Curate hard** — under 200 lines per doc. Shorter is better if no information is lost.
5. **Concrete examples** — real file paths, real code from this codebase.
6. **Reference actual code** — not generic patterns.
7. **Exact interfaces** — real names, real paths, real ports.
8. **Don't over-invest in format** — clarity matters, template structure doesn't.
9. **Cite with links** — actual URLs to external resources.
10. **Describe the present** — not the past. Remove references to retired behavior.

**README exemption:** User-facing READMEs share the same accuracy bar (no stale claims, no retired references) but are exempt from line-count and style constraints that apply to agent documents.

## Local Development

```bash
[command to install dependencies]
[command to start infrastructure — e.g., docker compose up]
[command to verify everything is running]
```

[Prerequisites: list anything that must be installed or configured before these commands work — e.g., Docker, specific CLI tools, environment variables, auth tokens]

## Build & Test

```bash
[command to build]
[command to run all tests]
[command to run a single component's tests]
[command to start dev mode]
```

## Resources

External systems an agent can consult when the codebase alone doesn't have the answer.

| Resource | URL / Path | What you'll find there |
|---|---|---|
| [Slack channel] | [URL or channel name] | Team discussion, incident context, quick answers |
| [Jira project] | [URL] | Tickets, requirements, acceptance criteria |
| [Confluence space] | [URL] | Architecture docs, onboarding guides, decision history |
| [GitHub org] | [URL] | Related repos, org-wide standards, shared tooling |
| [Other] | [URL or path] | [Description] |

[Remove rows that don't apply. Add rows for any resource the team actually uses.]
