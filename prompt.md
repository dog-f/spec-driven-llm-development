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

Every document gets `Last verified: YYYY-MM-DD` on the line after its title (line 3, as in the templates; use today's date), but only after you have checked its claims; the date is a certificate, not a timestamp. `CLAUDE.md` gets no date, and decision records use their own `Date:` line instead. When you edit a section of a README, re-check and re-date the whole README. Up-to-dateness is the #1 documentation problem (~39% of defects in a 162-type taxonomy study).

The date certifies every claim checkable from the repo and any local checkout of a sibling repo. A claim about a system you can't read (repository settings, a deployment UI, a registry, infrastructure owned elsewhere) doesn't hold the date back. Mark it inline instead: `*(External: <where it lives>; not verifiable from this repo.)*`. Before marking, check whatever local copy exists; an external claim you can check and find wrong is a fix, not a marker. If the user allowed it in Step 0 (question 13a), also search the resources they named, read-only, before marking: one or two targeted searches per claim, not a survey of the space. When a source confirms the claim, keep the marker and put the source's URL in it (`*(External: <URL>.)*`). When a source adds a fact the claim needs (a rollout order, an owner, a limit), add it with the same marker. When a source disagrees with the code, the code wins: write what the code shows and list the conflict under **Needs a person** in your report. Without that permission, mark and move on.

**Surface what you couldn't verify.** Every claim in a doc is either verified against the repo or carries a marker: `*(External: …)*` for a system you can't read, or "not confirmed from the repo" for a reason or behavior you couldn't trace. Don't hedge in the doc itself ("probably", "likely", "should"); an agent acts on a hedged claim as if it were true, so a doc states what's verified and marks what isn't. Every marker, and every place you chose between conflicting sources, goes under **Needs a person** in your report (see the end of this file).

**Why:** Stale docs cause agents to generate confidently wrong code. A wrong doc is worse than no doc. _(Aghajani et al., "Software Documentation Issues Unveiled," ICSE 2019)_

### 3. Critical information at the START or END of a document

Never bury important content in the middle. LLM accuracy follows a U-shaped curve — content in the middle of context gets ~20% lower accuracy than content at the edges.

**Why:** The "lost in the middle" effect is replicated across 6+ model families and 18 frontier models. _(Liu et al., "Lost in the Middle," TACL 2024, arXiv:2307.03172)_

### 4. Curate hard — less is more

- Root `AGENTS.md`: under 200 lines
- Per-module `AGENTS.md`: under 150 lines
- Architecture docs: under 200 lines (300 max for very complex topics)
- Guides: under 150 lines

These are caps on a single doc, not targets, and they never limit how many docs exist. A doc well under its cap that leaves out part of its topic is a loss, not a saving. Never pad to fill space, and never drop a topic to save lines: a subsystem that needs its own doc gets one (see Step 4). Shorter is always better if no information is lost.

**What "no information lost" means.** Preserve the big picture: what each part is for, how the parts connect, the rules and why they exist, non-obvious behavior and its consequences, and where to look next. An agent should be able to plan a change without rereading several files to rebuild that picture. It does not mean recording every fact about the code. Leave out what one search or one file read recovers (line numbers, exhaustive call-site lists, full copies of config or workflow files, file-by-file listings) and point to the file or symbol instead.

**Over budget? Condense before you split.** Remove repeats, keep each fact in one owning doc with pointers from the others, and cut detail the code already shows. Split only when what remains still doesn't fit.

**Condensing never drops a condition.** This applies equally when you write from code and when you shorten existing text. When you summarize code or text, keep every "only when" and "unless", every "change X and Y together", every "after changing X, run Y", and every "because". When you replace a worked example with a different one, carry over the old example's failure modes and exact error messages, or keep both.

**Exception — READMEs:** User-facing README files are exempt from strict line-count and style constraints. They serve humans first and may be longer. They must still meet the same accuracy bar (no stale claims, no references to retired behavior), but formatting, length, and style are relaxed.

**Why:** Adding documents dilutes attention; retriever accuracy saturates quickly (20→50 docs improved GPT-3.5 only ~1.5%). _(Liu et al., TACL 2024; "Long-Context LLMs Meet RAG," ICLR 2025)_

### 5. Concrete code examples over abstract prose

Show real file paths and real code from the actual codebase. In ablation studies, removing examples caused the largest quality drop; removing parameter descriptions slightly *improved* output.

**Why:** Examples > prose > parameter lists, empirically. _(Chen et al., "When LLMs Meet API Documentation," arXiv:2503.15231)_

### 6. Reference actual in-repo code, not generic patterns

Point to the real implementation. Don't invent "similar" examples or use generic patterns from documentation sites.

**Why:** Naively retrieved "similar" snippets degrade full-function generation quality by up to 15%. _(Gu et al., "What to Retrieve for Effective RACG," arXiv:2503.20589)_

### 7. Specify exact interfaces and explicit requirements

Use real function names, class names, file paths, port numbers, environment variables. Be specific about what exists and what things are called. "Exact interfaces" also covers:

- numeric limits: retention, TTLs, size caps, timeouts, retry counts;
- payload types that cross a boundary (HTTP bodies, queue messages, compiler output read by a runtime) and the invariants both sides rely on;
- config flags whose values differ by environment or region;
- CI secrets and repository variables that a workflow needs;
- config values that carry a TODO, ticket, or region comment (the comment usually states the reason or the condition: keep both);
- the shape of operator-entered values such as base URLs (whether a path suffix like `/v1` is required or forbidden).

Cite a file and a symbol, never a line number: line numbers drift with every edit. Write every pointer to another doc or file in the repo as a relative markdown link (`[messaging.md](messaging.md)`), not bare backticks, so humans can click it and link checks can verify it. All paths are repo-relative. Never write a home directory or other absolute path, even when the interview answers use one; write sibling repos as relative paths (`../other-repo`).

**Why:** Providing exact names + structured requirements vs. leaving them implicit swung pass rates ~3×. _(SWE-Bench Pro, arXiv:2509.16941)_

### 8. Don't over-invest in document format/template debates

Document *structure* for agents has zero surviving empirical support as a quality factor. Use descriptive names, keep content clear, and move on. The templates provided here are suggestions for consistency, not magic.

**Why:** Format had no significant effect on architecture comprehension (n=65). _(Ernst & Robillard, Empirical Software Engineering 2023, arXiv:2305.17286)_

### 9. Cite external sources with links

If documentation mentions a wiki page, ticket, channel, or external resource — include the actual URL. An agent cannot follow up on "per the Confluence docs."

### 10. Describe the present, not the past

Document what the code does *now*. Remove references to retired behavior, old approaches, and negations about things that no longer exist. A reader who never knew the old design is only confused by references to it.

Two kinds of content look historical but are present-tense, so keep them:

- **Negative facts that block a likely wrong assumption** ("the gateway does not cache responses", "this route has no internal twin, unlike its neighbors"). They describe the system as it is.
- **Known-limitations registers.** A list of what the system currently cannot do, or does wrong, is current state.

### Accuracy checks while writing

These apply to every rule above.

- **Enumerate before you generalize.** Before writing "every", "all", "each", "only", or "N of", list the members from their source of truth (a file glob, a route table, a registry, a config list) and check each one. For counts, count the registrations themselves (e.g. the `app.get`/`app.post` calls in a router), not lines or files. Over-generalized claims are the most common error in generated docs. Before you finish, grep your drafts for these words and for "never", "none", and "always", and re-check each claim. Table cells and section openers count: a matrix of which component uses which store or client must be rebuilt from each component's own registration calls, not inferred.
- **Document only reachable behavior.** Before describing a branch, response, or option, confirm the code path is wired up (something calls it, a route mounts it, a config sets it). Read an argument's implementation before describing its values.
- **Present is not used.** A client in a config list, a module or cache in the bootstrap, a dependency in a manifest, a copied class, or an exported function is not "used" until you find both its registration and a live call site that some route, job, or consumer reaches. When either is missing, document it as a negative fact ("configured but never called") rather than describing what it would do. For a package dependency, registration means an import from source: a dependency nothing imports is a negative fact. Check every manifest this way, services as well as packages. Test fixtures count as reachable only if a test that is not skipped reads them.
- **Read where a value is assigned before saying what it carries.** Describe a field, status, or flag from the code that writes it, not from its name or type.
- **Read a tool's implementation before giving example values.** For lint, commit, build, or codegen plugins, check how they derive values (e.g. a scope list built from package names) before writing an example an agent will copy.
- **Specs and existing docs are leads, not truth.** Verify every behavioral claim you take from a spec against the code that produces or consumes the result. Work a spec plans in a sibling repo (a new caller, a new route) exists only once you find it in that repo.
- **Check every pointer.** Open each "see X" target and confirm the fact is there; grep each symbol you cite. When a doc defers a topic to another doc, confirm that doc actually covers it.
- **One owner per contract.** A payload shape, argument list, header list, cache-key table, or env-var table lives in one doc, like a code snippet; other docs link to it with a one-line summary. After writing module docs, cross-check each against the architecture tables it overlaps and fix disagreements.
- **Find defects by reasoning, not only by markers.** For each computed value (a score, threshold, cap, flag, or status), check that what its consumers assume about it holds: units, ranges, defaults, and what happens on error. TODO and FIXME comments are a start, not the search.
- **Record defects you find.** When you find a live bug or security gap while reading code (a missing permission check, an auth bypass, credentials echoed in a response), write it as a known limitation in the doc that owns that area, with the file and symbol, **and** list it under **Needs a person** in your report. Don't silently document the buggy behavior as intended. A defect that spans areas lives in one Known limitations section; the others link to it.
- **Cross-check the interview against the code.** When an answer from Step 0 disagrees with the code (a count, a command, a port), use the code, and list the mismatch under **Needs a person** in your report. Don't silently pick one.
- **Each pitfall states its consequence and the action.** "X breaks" is incomplete; "X makes Y fail at startup; do Z" is a pitfall.
- **Each code snippet lives in one doc.** Other docs point to it rather than copy it.

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
13a. May I search the external resources from questions 11–13 while writing, read-only, to check claims the repo can't? It makes the docs more accurate on deployment, infrastructure, and other systems owned elsewhere, but costs extra tokens. I would only search for claims I'd otherwise mark as external, and never post, comment, edit, or change anything there. Which resources may I use? (The default is no: those claims are marked external and left for a person to check.)

### How to use the answers:

- Filter aggressively. Not everything the user says belongs in documentation. Only include what an agent needs to write correct code.
- The product/system description becomes the opening paragraph of the root `AGENTS.md`.
- Hard constraints become the "Hard Rules" section. Also derive hard rules from the repo itself: `.gitignore` (files never to commit, such as `.env`), git hooks, CI gates, and security or rules files.
- Architecture answers inform the service map, dependency graph, and architecture docs.
- Dev workflow answers become the "Local Development" and "Build & Test" sections.
- External resources become the "Resources" section in the root `AGENTS.md` and the `find-missing-context` skill (Step 7a).
- The answer to 13a decides whether you search those resources while writing (see "Last verified" in the rules). Record the allowed resources at the top of your notes and use only those; if a tool for one isn't available in your session, list it under **Needs a person** instead of working around it.
- Sibling repos get noted in the root `AGENTS.md` so agents know where to look beyond this directory.

---

## Output Structure

Generate this file structure in the codebase:

```
project-root/
├── AGENTS.md                          # Root agent document (orientation + routing)
├── CLAUDE.md                          # Points to AGENTS.md (for Claude Code compatibility)
├── .claude/skills/find-missing-context/SKILL.md   # Tells agents to search external resources before guessing
├── .claude/skills/update-docs/, audit-docs/       # Doc-maintenance skills, adapted to this repo (Step 7b)
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

**Plan, then work one doc at a time.** First write a short list of every doc you will produce (module docs, every topic doc that meets a Step 4 trigger, every guide from Step 5), so none is dropped later. Build the list from directory listings, manifests, config files, and spec titles; don't read source code to make it. Then take them one at a time: read what that doc needs, write it, then move to the next. Don't survey a whole area before writing anything: reading for many docs at once fills your context, so every later step gets slower and more expensive, and nothing is saved if you run out of budget. If you split the work among helpers, give each a short list of docs and the same rule.

**Log progress as you go.** Write your doc list to `.docgen-progress.log` at the repo root (the list will change as you go; that's fine), then append one timestamped line each time a doc is written, e.g. `echo "$(date +%H:%M) written: services/orders/AGENTS.md" >> .docgen-progress.log`. Helpers append to the same file. Before you start writing, tell the user they can watch progress with `tail -f .docgen-progress.log` (and, if this generator repo's `scripts/watch-generation.sh` is available, that it also shows tokens used). Aim to write your first doc within about 15 minutes and keep a steady pace after that; a long gap means you are reading instead of writing. Delete the file when you finish.

### Step 1: Get oriented

Get the shape of the project before planning, from manifests, directory listings, config, and CI files rather than source code. Deeper reading happens one doc at a time, when you write the doc that needs it:

- Read package.json / go.mod / Cargo.toml / pyproject.toml (whatever applies)
- Identify all deployable units (services, apps, CLIs)
- Identify all shared libraries/packages
- Note the build system and dependency graph (from manifests and build config)
- Identify the framework(s) used
- Note which components talk to each other and how (HTTP, messaging, shared DB), from config and client setup; the details come when you write those docs
- Find existing docs (README, wiki references, inline comments explaining architecture)
- List the specs in `docs/specs/implemented/` (and `todo/` specs whose code may exist). When you write the doc a spec covers, read that spec, verify it against the code, and fold the live parts into the doc. Never edit a spec; list the stale ones under **Needs a person**.
- Run `which gh aws op` plus any observability or cloud CLIs the code or CI mentions, to learn what an agent can reach (Step 0 question 12a)
- Read the CI workflows for rules that doc edits trigger (for example, a changeset or version bump required for any change inside a published package), and satisfy them in the same change
- Cross-reference what you find with what the user told you in Step 0

### Step 1b: Inventory existing docs before replacing any

If the repo already has agent docs, architecture docs, guides, or ADRs, account for them before you create, replace, or delete anything:

1. For each existing doc, list its facts that the code can't give back: rationale, production-only gotchas, cross-file invariants, known limitations, external links.
2. Give each fact a fate: **kept** (same doc), **moved** (to a named successor doc), or **dropped** (verified stale against code, with the evidence).
3. Treat content added since the docs were last generated (`git log` on the doc paths) as high-signal; someone added it because it was missing.
4. Demoting a doc moves every fact: when a module loses its own `AGENTS.md` (folded into an index or a topic doc), each of its pitfalls, commands, and rules must appear in the named successor. In your report, list each folded module or guide with its test commands, pitfalls, and rules and the successor file that now holds each one.
5. When READMEs, specs, or other docs link to agent docs that don't exist (for example after a deletion), either create the doc at that path or update every inbound link; never leave a README pointing at a missing or renamed doc.
6. Never delete a doc that has no named successor. Never rewrite or delete an existing decision record or spec (they are append-only).

Include the inventory, with its dropped facts and their evidence, in your report to the user, and list each dropped fact under **Needs a person** so someone can confirm it was safe to drop.

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
10. **Resources** — external systems an agent can consult when stuck: Slack channels, Jira projects, Confluence spaces, GitHub orgs/repos, local sibling checkouts. Include actual URLs or paths where possible. Mine the repo's own docs, specs, and CI config for channel, project, and space names before asking. Link a Slack channel as `https://<workspace>.slack.com/archives/<channel-id>` when you can resolve the ID; otherwise give the channel name with its ID.

Keep it under 200 lines. This is orientation + routing, not encyclopedic reference.

### Step 3: Create per-module AGENTS.md files

For each service, package, or module that an agent might work in independently, create an `AGENTS.md` in that directory containing:

1. **Purpose** — one sentence on what this module does
2. **Source layout** — directory tree of the key folders/files
3. **Key patterns** — with actual code examples from the module (most important section)
4. **Testing** — how to run tests for this module specifically, plus any destructive side effect (what the suite wipes, flushes, or deletes, and which env var or config decides where it points)
5. **Common pitfalls** — things that are non-obvious or that break in surprising ways
6. **Related docs** — links to architecture docs relevant to this module

Keep each under 150 lines. The agent reads this when `cd`'d into the module directory.

**When to create one:** Every deployable unit (service, app, CLI) gets its own `AGENTS.md`. Libraries and packages are listed in one index doc per directory (e.g. `packages/AGENTS.md`). A package also gets its own `AGENTS.md` when **any** of these holds:

- it has its own test layout or fixture recipe (how to add a case, where cases live, what runs them);
- it has a build pipeline beyond plain `tsc` (bundlers, generated artifacts, WASM, post-build steps);
- it defines a runtime contract other components must honor (a wire format, an execution or scheduling semantics, a plugin interface), not merely exported functions; in a monorepo nearly every package is imported by something, so being imported is not enough;
- it is a security boundary (sandboxing, auth, untrusted input);
- its pitfalls need a code example.

Topic docs don't replace a package doc: an architecture doc explains how a subsystem works across components, while the package `AGENTS.md` tells an agent working inside the package how to change and test it. When unsure, write the package doc. Don't write one for a vendored fork or a types-only package; give them an index entry. Rules shared by every package (changesets, test flags, build tool) live once in the index doc, not repeated in each package doc.

### Step 4: Create architecture docs

One document per major architectural concern. Common topics:

- System overview (topology, communication patterns)
- Data stores (databases, caches, search indices — schemas and access patterns)
- Authentication/authorization flow
- Messaging/event system
- Build/deploy pipeline
- Domain-specific concepts (the core domain model)

That list is a floor, not a menu. Cross-cutting concerns (authentication between services, messaging, data stores, the service framework) keep their own topic docs even when every service also has its own `AGENTS.md`; service docs link to them rather than splitting their content. Also write a topic doc for every feature subsystem that meets **any** of these triggers:

- it spans two or more deployable units;
- it has a dedicated source directory with 8 or more files;
- it has 5 or more dedicated test files;
- it has its own config block or environment variables;
- it has a spec in `docs/specs/implemented/`;
- it is a core domain concept with its own states, types, or rules (port or message types, scheduling semantics, a lifecycle), even when it has no dedicated directory. Such a doc states every state, every numbered rule, and the test suite that pins them; a table row in another doc is not enough.

A subsystem that meets a trigger but is covered only by a few lines in a module doc is the most common way generated docs lose depth.

While writing each topic doc, look for what is currently broken or unsupported in that area (skipped or failing tests, TODO/FIXME comments, unhandled cases, inconsistencies between components) and end the doc with a **Known limitations** section when you find any. Don't rely only on registers that already exist.

Each doc should have:
- `Last verified: YYYY-MM-DD` on the line after the title (rule 2)
- ASCII diagrams for topology where helpful
- Tables for structured data
- Concrete names (real services, real ports, real env vars)
- Under 200 lines

### Step 5: Create guides (if applicable)

Guides are for recurring tasks that have non-obvious steps. Only create guides for patterns that:
- Touch multiple files/modules
- Have a specific order of operations
- Have "gotchas" that aren't obvious from the code alone

Mine for them from code, not only from the interview:
- Look for cross-file invariants in Dockerfiles, deploy manifests, and CI workflows: a path, port, user, group, or flag that must match in another file, and the error when it doesn't. When there is more than one, write a guide for modifying them.
- In that guide, try to give each non-default setting in those files (a build flag, a file mode, a user or group switch, a port, an umask, the order of two steps) its reason and what breaks if someone removes, reorders, or changes it. State a reason only when the repo shows it: a comment, a value that must match another file, or a relation visible in the files (a binary built in one stage and copied into an image with a different base; a file read by a process that runs as a non-root user). Quote an error message only if it appears in the repo. Don't build or run anything to find out. When the repo doesn't show the reason, don't supply one: write "keep it; reason not confirmed from the repo" so no one removes it casually, and list the setting under **Needs a person** with "build and run the image" as what would confirm it.
- Don't read every service's files to do this. Work from one or two, but treat every value you take from them (a version, start command, user, port, CI gate) as a field to check: before stating it as true for all services, grep that one field across the others (e.g. `grep -H '^USER' services/*/Dockerfile`); where they differ, say which services differ.
- When components call each other over HTTP or queues, write a guide for adding a field or parameter across that boundary: where the schema lives on each side, which side deploys first, and how to keep it backward compatible.

Each guide should have:
- Numbered steps with real code from the codebase
- Real file paths (not `path/to/file`)
- A "Key rules" section for non-obvious constraints that repeats every "never" or "must" stated in the steps
- A "Symptoms" section: the errors or behaviors a reader is likely to hit when a step goes wrong, quoted exactly, and what each one means
- Under 150 lines

### Step 6: Create CLAUDE.md

Create a minimal `CLAUDE.md` at the project root:

```markdown
# Claude Code

This repo uses `AGENTS.md` as its root agent document. YOU MUST FIRST READ THE PROJECT ROOT `AGENTS.md`. If you need any other project context, conventions, and navigation in other directories, expect that they will be in `AGENTS.md` instead of `CLAUDE.md`.
```

This redirect exists because Claude Code auto-loads `CLAUDE.md`. The real content lives in `AGENTS.md` so that it works for any agent, not just Claude.

Never overwrite a `CLAUDE.md` that is a symlink target or has frontmatter: it is someone else's config (for example an editor rule), so leave it byte-for-byte unchanged. If a module already has its own `CLAUDE.md`, keep it: move its content into that module's `AGENTS.md` (or keep it in place if other files symlink to or include it), and leave a redirect. Check for symlinks and editor rules (`.cursor/`, `.github/`) that point at it before changing the file.

### Step 7: Create templates

Create `docs/specs/TEMPLATE.md` and `docs/decisions/TEMPLATE.md` in the project so future specs and decisions have a starting point. Use the templates provided in this repo as a base:

- `templates/spec.md` → place as `docs/specs/TEMPLATE.md`
- `templates/decision.md` → place as `docs/decisions/TEMPLATE.md`

Adapt the content to fit the project's terminology (e.g., rename "Affected Components" if the project uses "services" or "modules"), but preserve the immutability rules and Open Questions format.

Also create `docs/decisions/document-driven-development.md` from `templates/decision.md`: a decision record that the repo adopts this documentation system. Its Decision section must state the 10 design principles from "The 10 Writing Rules" above in plain language, each with a one-line reason, under a `## Design principles` heading, so the target repo holds the rationale itself. The `update-docs` and `audit-docs` skills point to it by that name, and the README's "Working with Agents" section links to its `#design-principles` anchor.

Never link any generated file to this generator repo or its hosting URL (its research doc, README, or prompt). The target repo's docs must stand on their own; summarize what they need instead of linking out.

When you instantiate any template, replace every placeholder with this project's real values (its real ticket key in place of the template's `PROJ-1234`; its paths and names), and remove its instructions to the author (naming and location rules, "Do not lose information for the sake of conforming to the template") from the instance; keep them only in `TEMPLATE.md`. Existing decision records and specs are append-only: never rewrite or delete them.

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

### Step 7b: Install and adapt the maintenance skills

Copy `skills/update-docs/` and `skills/audit-docs/` from this repo into `.claude/skills/update-docs/` and `.claude/skills/audit-docs/`. Then adapt each one to this repo rather than leaving it generic:

- add a short routing table: which kinds of change touch which docs here (e.g. a new route → that service's `AGENTS.md` and the matching architecture doc);
- list the directories the skills must skip (vendored code, forks, generated files, tooling boilerplate);
- add a `Last verified` date.

### Step 8: Add "Working with Agents" to the root README

If the project has a root `README.md` (or create one if it doesn't), add a "Working with Agents" section after the README's setup and run instructions (a newcomer needs to get the project running first). Use `templates/working-with-agents.md` as the base content.

This section tells human developers how to work alongside AI agents in this repo: where to find the design principles, how the spec-first workflow operates, the non-negotiable rules (human review, keeping docs current), and how to use the agent skills.

Adapt the links to match the actual file paths in the project. If the project doesn't use the spec-first workflow, omit that subsection. If the README already states a team policy that the template contradicts (for example "specs are optional"), keep the team's wording and list the conflict under **Needs a person**; don't overwrite it.

Then fix READMEs that link to agent docs you didn't create or that you renamed: grep the READMEs for `AGENTS.md` and `docs/` links and check only those targets. Audit the rest of the root README for accuracy (rule 2 applies to READMEs too): check every command, path, port, and link against the code, and fix or flag what's wrong. Add `find-missing-context` (from Step 7a) and any other project skills beyond `update-docs` and `audit-docs` to the skills table.

---

## What NOT to Document

- **Things derivable from reading the code** — don't restate what clear code already says
- **Git history** — `git log` and `git blame` are authoritative
- **Generated API reference** — if there's a typedoc/swagger/godoc setup, don't duplicate it
- **Deployment runbooks** — operational procedures (incident steps, manual promotion clicks, on-call playbooks) belong in ops tooling. But *do* document the invariants that tie deploy files to code, because they break builds and deploys silently: how the Dockerfile, deploy manifest, and chart must agree; env-var patterns in resource definitions; CI secrets and variables; and what wiring a new service needs.
- **Frontend implementation details** — if the frontend is in a different repo, note where it lives and what APIs it consumes. Do document its defaults and gates that change what this repo receives (a default model or option it sends, a feature flag that decides which route it calls), with the sibling-repo path. To find them, start from the sibling's feature-flag registry and the few call sites that build requests to this repo; don't read the sibling repo broadly.
- **Tutorials for the language/framework itself** — link to official docs instead

---

## Maintenance System

Include these instructions in the root `AGENTS.md` under a "Documentation Rules" section so future agent sessions know how to keep docs updated:

1. When code changes, update affected docs and their "Last verified" dates
2. When adding new modules, create an `AGENTS.md` following the existing pattern
3. New features should start as specs in `docs/specs/todo/`
4. Significant architectural decisions should be recorded in `docs/decisions/`
5. A stale doc (>3 months without verification) should be fixed or flagged immediately
6. A short form of the 10 writing rules, with the line limits from rule 4 (root <200, module <150, architecture <200 with 300 max, guides <150) and the topic-doc triggers from Step 4. The `update-docs` and `audit-docs` skills read these from here instead of restating them.
7. **README exemption:** user-facing READMEs share the same accuracy bar (no stale info, no retired references) but are exempt from the line-count and style constraints that apply to agent documents

---

## Evaluation Criteria

After all docs are written (by you or by helpers), do one cross-check pass yourself: each root hard rule against the topic doc that owns it, each architecture summary table against the module docs it summarizes, and each deferral or "see X" against its target. Docs written one at a time contradict each other here first.

Then verify:

- [ ] Root `AGENTS.md` is under 200 lines
- [ ] Every per-module doc is under 150 lines
- [ ] Every architecture doc is under 200 lines (300 max), every guide under 150
- [ ] Every doc has a "Last verified" date (except `CLAUDE.md`; decision records use `Date:`)
- [ ] Every code snippet matches the source verbatim (spot-check each against its file)
- [ ] No doc references retired/removed behavior
- [ ] No orphan links: every relative link and path in every doc you wrote or edited resolves. Append-only specs and decision records are exempt; list their broken links under **Needs a person** instead of editing them
- [ ] Every "every/all/each/only/never/none/N of" claim, including table cells, was re-checked against its source of truth
- [ ] Every package that meets a Step 3 criterion has its own `AGENTS.md`; every folded module or guide has a successor list in the report
- [ ] Every in-repo pointer is a markdown link, and every "see X" lands on the fact; no README or doc links to a missing agent doc
- [ ] Every deploy fact stated for all services was grepped across services, and exceptions are named
- [ ] Cross-cutting concerns (auth, messaging, data stores, service framework) have their own topic docs
- [ ] `Last verified` is on the line after the title in every doc
- [ ] Nothing configured-but-uncalled is described as live
- [ ] Every security gap or live bug you found is a known limitation in its owning doc
- [ ] No doc hedges ("probably", "likely"); every unverified claim carries a marker, and every marker, mismatch, defect, and dropped fact is under **Needs a person**
- [ ] CI rules triggered by doc edits (e.g. changesets) are satisfied
- [ ] No absolute or home-directory paths, and no line-number references
- [ ] No generated file links to this generator repo or its hosting URL; `docs/decisions/document-driven-development.md` states the design principles itself
- [ ] No fact is restated in full in more than one agent doc (one owner, pointers elsewhere)
- [ ] Every subsystem that meets a Step 4 trigger has a topic doc
- [ ] Every existing doc you replaced or deleted has a named successor for each of its kept facts (Step 1b)
- [ ] The root README's commands, paths, and links are accurate
- [ ] An agent dropped into any module directory gets enough context from its `AGENTS.md` to understand what it's looking at
- [ ] The root `AGENTS.md` gives enough orientation that an agent knows where to look for any task
- [ ] The root `AGENTS.md` has a Resources section with external tools/channels
- [ ] `.claude/skills/update-docs/` and `.claude/skills/audit-docs/` exist and are adapted to this repo (routing table, skip list, date)
- [ ] `.claude/skills/find-missing-context/SKILL.md` exists, lists the real resources with broad "reach for it when" guidance, and the Resources section points to it
- [ ] Local dev commands are present and accurate (an agent can actually run them)
- [ ] `CLAUDE.md` redirects to `AGENTS.md` with the strong directive wording

Near the end of your report, add a section titled **Needs a person**: one line per item, grouped by kind (external claims, unconfirmed reasons, interview-vs-code mismatches, defects found, facts dropped from replaced docs, stale specs and conflicts). Each line names the doc, the claim, and what would confirm it (a file to read, a person to ask, a build to run). Put the items most likely to mislead an agent first. Don't list claims you verified. Where the confirmation is a build or a container run, say the user can let an agent do it or do it themselves, at their discretion; don't do it yourself.

End your report to the user by offering the optional one-time validation pass: before committing the new docs, they can have an agent run `validation/validate-generated-docs/SKILL.md` from this generator repo, which checks the finished set against the code with fresh agents, fixes confirmed errors, and fills commonly dropped facts found by grep (roughly just under the generation cost). Don't run it yourself, and don't copy it into the target repo.

---

## Additional Context

For the full research backing these rules (academic citations, empirical evidence, refuted claims, and measurement methodology), see [`research/evidence-and-guidelines.md`](research/evidence-and-guidelines.md) in this generator repo. You don't need to read it to generate docs — the rules above are the distilled, actionable output. But it's there if you want to understand *why* each rule exists.
