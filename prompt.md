# Generate Documentation for This Codebase

You are tasked with generating a documentation system for this codebase, optimized for AI agent consumption. The documentation you produce should enable any AI coding agent to understand the project structure, navigate between components, and implement features with minimal friction.

Read this entire file before beginning. It contains the rules, the interview process, the output structure, and the steps you should follow.

---

## The 10 Writing Rules

Every document you produce must follow these rules. They are empirically grounded — citations are provided for reference, not decoration.

### 1. Layered retrieval — scope context to the task at hand

Create a hierarchy: Root `AGENTS.md` → per-module `AGENTS.md` → architecture docs → guides. Each layer is lean and links to the next instead of inlining it. An agent reads deeper only when the task needs it.

**Why:** Flooding all documentation into context degrades LLM output quality. More documents dilute attention and push signal into low-attention positions. _(Liu et al., TACL 2024; "Long-Context LLMs Meet RAG," ICLR 2025)_

### 2. Keep docs fresh — add "Last verified" dates

Every document gets `Last verified: YYYY-MM-DD` at the top (use today's date). Up-to-dateness is the #1 documentation problem (~39% of defects in a 162-type taxonomy study).

**Why:** Stale docs cause agents to generate confidently wrong code. A wrong doc is worse than no doc. _(Aghajani et al., "Software Documentation Issues Unveiled," ICSE 2019)_

### 3. Critical information at the START or END of a document

Never bury important content in the middle. LLM accuracy follows a U-shaped curve — content in the middle of context gets ~20% lower accuracy than content at the edges.

**Why:** The "lost in the middle" effect is replicated across 6+ model families and 18 frontier models. _(Liu et al., "Lost in the Middle," TACL 2024, arXiv:2307.03172)_

### 4. Curate hard — less is more

- Root `AGENTS.md`: under 200 lines
- Per-module `AGENTS.md`: under 150 lines
- Architecture docs: under 200 lines (300 max for very complex topics)
- Guides: under 150 lines

Never pad to fill space. Shorter is always better if no information is lost. If a doc needs to be longer, split it.

**Exception — READMEs:** User-facing README files are exempt from strict line-count and style constraints. They serve humans first and may be longer. They must still meet the same accuracy bar (no stale claims, no references to retired behavior), but formatting, length, and style are relaxed.

**Why:** Adding documents dilutes attention; retriever accuracy saturates quickly (20→50 docs improved GPT-3.5 only ~1.5%). _(Liu et al., TACL 2024; "Long-Context LLMs Meet RAG," ICLR 2025)_

### 5. Concrete code examples over abstract prose

Show real file paths and real code from the actual codebase. In ablation studies, removing examples caused the largest quality drop; removing parameter descriptions slightly *improved* output.

**Why:** Examples > prose > parameter lists, empirically. _(Chen et al., "When LLMs Meet API Documentation," arXiv:2503.15231)_

### 6. Reference actual in-repo code, not generic patterns

Point to the real implementation. Don't invent "similar" examples or use generic patterns from documentation sites.

**Why:** Naively retrieved "similar" snippets degrade full-function generation quality by up to 15%. _(Gu et al., "What to Retrieve for Effective RACG," arXiv:2503.20589)_

### 7. Specify exact interfaces and explicit requirements

Use real function names, class names, file paths, port numbers, environment variables. Be specific about what exists and what things are called.

**Why:** Providing exact names + structured requirements vs. leaving them implicit swung pass rates ~3×. _(SWE-Bench Pro, arXiv:2509.16941)_

### 8. Don't over-invest in document format/template debates

Document *structure* for agents has zero surviving empirical support as a quality factor. Use descriptive names, keep content clear, and move on. The templates provided here are suggestions for consistency, not magic.

**Why:** Format had no significant effect on architecture comprehension (n=65). _(Ernst & Robillard, Empirical Software Engineering 2023, arXiv:2305.17286)_

### 9. Cite external sources with links

If documentation mentions a wiki page, ticket, channel, or external resource — include the actual URL. An agent cannot follow up on "per the Confluence docs."

### 10. Describe the present, not the past

Document what the code does *now*. Remove references to retired behavior, old approaches, and negations about things that no longer exist. A reader who never knew the old design is only confused by references to it.

---

## Step 0: Interview the User

Before you write anything, you need to understand the system. Ask the user the following questions. Frame them in plain language — don't assume they know documentation jargon. You may ask these in batches (3–5 at a time) to avoid overwhelming them.

### Questions to ask:

**About the product and system:**

1. What does this project do? Describe it like you're explaining it to a new team member on their first day.
2. What's the goal of this system? What problem does it solve for its users?
3. Are there any hard constraints the team never violates? (e.g., "all API calls must be authenticated," "we always use conventional commits")
4. What are the most important qualities of this system? (e.g., "it must be fast," "it must never lose data," "it must stay backwards-compatible")

**About the architecture:**

5. Is this a monorepo with multiple services/packages, or a single application/service?
6. Are there sibling services or repos that aren't in this directory but that an agent might need to look at? Are they checked out locally somewhere, or can they be cloned? (If so, where — or should the agent clone them to `/tmp`?)
7. What databases, caches, or external systems does this project connect to?

**About development workflow:**

8. What are the commands to install dependencies, run the project locally, and run tests?
9. Is there a CI/CD pipeline? What does it check? (linting, tests, type checking, builds, deployments)
10. Is there a local development setup with Docker, docker compose, or similar? What does someone need to do before they can run the project for the first time?

**About external resources:**

11. Where does the team communicate? (Slack channels, specific Jira projects, Confluence spaces, etc.) Would an agent benefit from being able to search these?
12. Are there GitHub organizations, repos, or issue trackers that an agent should know about?
12a. What else can agents reach from this machine: MCP servers, CLIs (`gh`, observability or cloud CLIs), dashboards, shared drives? Before asking, check for yourself: look at `.mcp.json`, `.claude/settings*.json`, and the tools and MCP servers available in your own session, then ask the user to confirm and fill gaps.
13. Is there any existing documentation — READMEs, wikis, architecture diagrams, ADRs — that should be preserved or incorporated?

### How to use the answers:

- Filter aggressively. Not everything the user says belongs in documentation. Only include what an agent needs to write correct code.
- The product/system description becomes the opening paragraph of the root `AGENTS.md`.
- Hard constraints become the "Hard Rules" section.
- Architecture answers inform the service map, dependency graph, and architecture docs.
- Dev workflow answers become the "Local Development" and "Build & Test" sections.
- External resources become the "Resources" section in the root `AGENTS.md` and the `find-missing-context` skill (Step 7a).
- Sibling repos get noted in the root `AGENTS.md` so agents know where to look beyond this directory.

---

## Output Structure

Generate this file structure in the codebase:

```
project-root/
├── AGENTS.md                          # Root agent document (orientation + routing)
├── CLAUDE.md                          # Points to AGENTS.md (for Claude Code compatibility)
├── .claude/skills/find-missing-context/SKILL.md   # Tells agents to search external resources before guessing
├── docs/
│   ├── architecture/
│   │   ├── system-overview.md         # Service/module topology and communication
│   │   └── [topic].md                 # One doc per major architectural concern
│   ├── guides/
│   │   └── [task].md                  # Step-by-step how-to docs with real code
│   ├── specs/
│   │   ├── TEMPLATE.md                # Template for future specs
│   │   ├── todo/                      # Specs not yet implemented
│   │   └── implemented/               # Specs that have been built
│   └── decisions/
│       └── TEMPLATE.md                # Template for architectural decision records
├── [module-a]/AGENTS.md               # Per-module agent document
├── [module-b]/AGENTS.md               # Per-module agent document
└── ...
```

Adapt the structure to the project. A monorepo with services gets per-service `AGENTS.md` files. A single-package library might only need the root `AGENTS.md` + a couple architecture docs. Don't create empty docs to fill slots.

---

## Process

Follow these steps in order (Step 0 comes first — don't skip the interview).

### Step 1: Explore the codebase

Before writing anything, thoroughly understand the project:

- Read package.json / go.mod / Cargo.toml / pyproject.toml (whatever applies)
- Identify all deployable units (services, apps, CLIs)
- Identify all shared libraries/packages
- Understand the build system and dependency graph
- Identify the framework(s) used and their conventions
- Map inter-component communication (HTTP, messaging, shared DB, etc.)
- Find existing docs (README, wiki references, inline comments explaining architecture)
- Cross-reference what you find with what the user told you in Step 0

### Step 2: Create the root AGENTS.md

This is the most important document. It auto-loads for every agent session. Include:

1. **One-paragraph project description** — what this project IS and what it does (not its history)
2. **Hard rules** — non-negotiable constraints (security, framework rules, commit conventions)
3. **Component map** — table of services/modules with directory, purpose, and language
4. **Dependency graph** — if there's a meaningful build/import order, show it (ASCII art or table)
5. **Sibling repos** — if the user identified related repos outside this directory, note them here with clone URLs or local paths so agents know where to look
6. **Pointers to deeper docs** — links to architecture docs, guides, and specs
7. **Documentation rules** — the maintenance rules (see "Maintenance System" below), including the README exemption: user-facing READMEs share the same accuracy bar but are exempt from agent-doc line-length and style limits
8. **Local development** — prerequisites, install steps, how to start the project locally (Docker, infra, etc.)
9. **Build & test commands** — the basics to get running and verify correctness
10. **Resources** — external systems an agent can consult when stuck: Slack channels, Jira projects, Confluence spaces, GitHub orgs/repos, local sibling checkouts. Include actual URLs or paths where possible.

Keep it under 200 lines. This is orientation + routing, not encyclopedic reference.

### Step 3: Create per-module AGENTS.md files

For each service, package, or module that an agent might work in independently, create an `AGENTS.md` in that directory containing:

1. **Purpose** — one sentence on what this module does
2. **Source layout** — directory tree of the key folders/files
3. **Key patterns** — with actual code examples from the module (most important section)
4. **Testing** — how to run tests for this module specifically
5. **Common pitfalls** — things that are non-obvious or that break in surprising ways
6. **Related docs** — links to architecture docs relevant to this module

Keep each under 150 lines. The agent reads this when `cd`'d into the module directory.

**When to create one:** If a module has its own test command, its own build step, or patterns that differ from the rest of the project, it gets its own `AGENTS.md`. A thin wrapper package with 3 files probably doesn't need one.

### Step 4: Create architecture docs

One document per major architectural concern. Common topics:

- System overview (topology, communication patterns)
- Data stores (databases, caches, search indices — schemas and access patterns)
- Authentication/authorization flow
- Messaging/event system
- Build/deploy pipeline
- Domain-specific concepts (the core domain model)

Each doc should have:
- `Last verified: YYYY-MM-DD` at line 1
- ASCII diagrams for topology where helpful
- Tables for structured data
- Concrete names (real services, real ports, real env vars)
- Under 200 lines

### Step 5: Create guides (if applicable)

Guides are for recurring tasks that have non-obvious steps. Only create guides for patterns that:
- Touch multiple files/modules
- Have a specific order of operations
- Have "gotchas" that aren't obvious from the code alone

Each guide should have:
- Numbered steps with real code from the codebase
- Real file paths (not `path/to/file`)
- A "Key rules" section for non-obvious constraints
- Under 150 lines

### Step 6: Create CLAUDE.md

Create a minimal `CLAUDE.md` at the project root:

```markdown
# Claude Code

This repo uses `AGENTS.md` as its root agent document. YOU MUST FIRST READ THE PROJECT ROOT `AGENTS.md`. If you need any other project context, conventions, and navigation in other directories, expect that they will be in `AGENTS.md` instead of `CLAUDE.md`.
```

This redirect exists because Claude Code auto-loads `CLAUDE.md`. The real content lives in `AGENTS.md` so that it works for any agent, not just Claude.

### Step 7: Create templates

Create `docs/specs/TEMPLATE.md` and `docs/decisions/TEMPLATE.md` in the project so future specs and decisions have a starting point. Use the templates provided in this repo as a base:

- `templates/spec.md` → place as `docs/specs/TEMPLATE.md`
- `templates/decision.md` → place as `docs/decisions/TEMPLATE.md`

Adapt the content to fit the project's terminology (e.g., rename "Affected Components" if the project uses "services" or "modules"), but preserve the immutability rules and Open Questions format.

### Step 7a: Create the `find-missing-context` skill

Agents tend to guess rather than search, even when they can reach Slack, the issue tracker, the wiki, and other repos. Create `.claude/skills/find-missing-context/SKILL.md` from `templates/find-missing-context-skill.md` so they have a standing reminder of what's available and when to use it.

- Fill the resource table from the Step 0 answers (questions 6, 7, 11–13) and what you found in Step 1. Include real names **with URLs** (rule 9): issue-tracker project links, wiki space links, the code-host org link, a few example chat channels, and local paths to sibling repos. Look these up with the team's MCP tools rather than guessing them. However, ensure nothing sensitive is stored.
- Keep each row's "reach for it when" **broad**. Describe the kinds of questions a resource answers, not a closed list. The goal is to make agents search more, and a narrow mapping teaches them to rule resources out.
- Keep the "Getting access" section, and list the team's real MCP/CLI pairs in it. MCP tools are often deferred (listed by name only), and agents miss them unless told to search for them. Agents also tend to treat "needs authorization" as "unavailable" instead of starting the login, so the section tells them to prefer the MCP, fall back to the CLI, and authorize whichever one needs it. Keep authorization on demand: agents log in to a resource only when the current question needs it, never to every tool up front.
- Keep the name `find-missing-context`. It matches how an agent describes its own state ("I'm missing context"), which is what makes it connect the skill to the moment. Don't rename it to a tool list like `slack-jira-search` or a vague label like `research`.
- Keep the "Search the web before giving up" step. Agents tend to skip from "internal search found nothing" straight to asking the user or guessing, even though many unexplained behaviors are documented upstream.
- Keep the skill `description` trigger-rich. Name the situations (unexplained behavior, unknown ticket or acronym, external service behavior, before asking the user or assuming), because the description is what makes an agent load the skill.
- In the root `AGENTS.md` Resources section, add one line pointing to this skill and saying "use these before asking the user or guessing".
- Skip this step only if the team has no external resources beyond the repo itself.

### Step 8: Add "Working with Agents" to the root README

If the project has a root `README.md` (or create one if it doesn't), add a "Working with Agents" section near the top. Use `templates/working-with-agents.md` as the base content.

This section tells human developers how to work alongside AI agents in this repo: where to find the design principles, how the spec-first workflow operates, the non-negotiable rules (human review, keeping docs current), and how to use the agent skills.

Adapt the links to match the actual file paths in the project. If the project doesn't use the spec-first workflow, omit that subsection. Add `find-missing-context` (from Step 7a) and any other project skills beyond `update-docs` and `audit-docs` to the skills table.

---

## What NOT to Document

- **Things derivable from reading the code** — don't restate what clear code already says
- **Git history** — `git log` and `git blame` are authoritative
- **Generated API reference** — if there's a typedoc/swagger/godoc setup, don't duplicate it
- **Deployment runbooks** — these belong in ops tooling, not developer docs
- **Frontend implementation details** — if the frontend is in a different repo, just note where it lives and what APIs it consumes
- **Tutorials for the language/framework itself** — link to official docs instead

---

## Maintenance System

Include these instructions in the root `AGENTS.md` under a "Documentation Rules" section so future agent sessions know how to keep docs updated:

1. When code changes, update affected docs and their "Last verified" dates
2. When adding new modules, create an `AGENTS.md` following the existing pattern
3. New features should start as specs in `docs/specs/todo/`
4. Significant architectural decisions should be recorded in `docs/decisions/`
5. A stale doc (>3 months without verification) should be fixed or flagged immediately
6. **README exemption:** user-facing READMEs share the same accuracy bar (no stale info, no retired references) but are exempt from the line-count and style constraints that apply to agent documents

---

## Evaluation Criteria

After generating docs, verify:

- [ ] Root `AGENTS.md` is under 200 lines
- [ ] Every per-module doc is under 150 lines
- [ ] Every architecture doc is under 200 lines
- [ ] Every doc has a "Last verified" date
- [ ] Every doc with code examples uses REAL code from the ACTUAL codebase
- [ ] No doc references retired/removed behavior
- [ ] No orphan links (everything referenced actually exists)
- [ ] An agent dropped into any module directory gets enough context from its `AGENTS.md` to understand what it's looking at
- [ ] The root `AGENTS.md` gives enough orientation that an agent knows where to look for any task
- [ ] The root `AGENTS.md` has a Resources section with external tools/channels
- [ ] `.claude/skills/find-missing-context/SKILL.md` exists, lists the real resources with broad "reach for it when" guidance, and the Resources section points to it
- [ ] Local dev commands are present and accurate (an agent can actually run them)
- [ ] `CLAUDE.md` redirects to `AGENTS.md` with the strong directive wording

---

## Additional Context

For the full research backing these rules (academic citations, empirical evidence, refuted claims, and measurement methodology), see [`research/evidence-and-guidelines.md`](https://github.com/dog-f/spec-driven-llm-development/blob/main/research/evidence-and-guidelines.md). You don't need to read it to generate docs — the rules above are the distilled, actionable output. But it's there if you want to understand *why* each rule exists.
