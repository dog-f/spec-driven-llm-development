# Document-Driven Development for AI Agents

A framework for generating empirically-optimized documentation that makes your codebase navigable by AI coding agents (Claude, Copilot, Cursor, etc.).

## What This Is


### Please read this if nothing else

This repo contains everything you need to generate a documentation system for your own codebase — one that's specifically designed to help AI agents understand and work in your code effectively. It's based on a research synthesis of ~38 academic sources and ~50 verified empirical claims about how LLMs consume documentation. I highly recommend at least viewing and understanding the rationale behind the [10 Design Principles](research/evidence-and-guidelines.md#4-design-principles-plain-language-summary).

The core insight: **curated, layered documentation dramatically improves AI agent output quality** — but only if you follow specific principles backed by evidence (positioning, length budgets, concrete examples over prose, freshness).

This is empirically derived but not explicitly tested. ***Just like the Agile processes we love***, expect to ***tailor*** and ***tune*** these documents to fit the needs and constraints of your repos, agents, teams, wishes, desires, and dreams. If you ultimately notice this documentation system helping your workflow but you find yourself repeating the same context or leading question, point the agent at the root AGENTS.md and research doc and tell it to find the most appropriate spot to insert the concern.

## How It Works

Make sure the model your using is one you've had decent luck with understanding your codebase. I personally recommend using Opus at `high` or above at the current time of August 3, 2026.

1. **You** copy this repo (or its contents) somewhere accessible
2. **You** point your AI agent at the prompt file and say "generate docs for my codebase"
3. **The agent** reads your source code and produces documentation following the research-backed rules
4. **You** review, refine, and maintain the docs as living artifacts

## Quick Start

Clone this repo, then

```bash
# Copy the prompt into your target project (or reference it directly)
cp spec-driven-llm-development/prompt.md /path/to/your/project/

# Point Claude at it:
# "Read prompt.md and generate documentation for this codebase following the system described there."

# remove the prompt after generation
rm /path/to/your/project/prompt.md
```

Or, if using Claude Code directly in your target repo:

```
Read ~/path/to/spec-driven-llm-development/prompt.md and generate documentation
for this codebase following the system described there.
```

### Monitoring an initial run

Generation on a large codebase can take 30–60 minutes and a lot of tokens. The agent keeps a timestamped progress log at `.docgen-progress.log` in your project (its planned doc list, then one timestamped line per doc written), so with any agent you can watch it from a second terminal:

```bash
tail -f /path/to/your/project/.docgen-progress.log
```

Some reading before the first doc is normal. On a medium sized codebase the first doc usually appears within about 15 minutes. ~15 minutes without a new one once writing has started means the agent is reading without writing. Double check the plan it logged.

With Claude Code, `scripts/watch-generation.sh` also shows the files changed and the tokens used so far, including subagents (tokens, not cost). Agents can't see their own token usage, so this comes from the session transcript, not the log:

```bash
spec-driven-llm-development/scripts/watch-generation.sh /path/to/your/project      # every 60s
spec-driven-llm-development/scripts/watch-generation.sh /path/to/your/project 30   # every 30s
```

## Optional: validate the generated docs

Before committing the new docs, you can run a one-time pass where fresh agents check them against the code, fix confirmed errors, and add commonly missed facts that a grep turns up. It costs roughly a quarter to a third of the generation run.

```
Read ~/path/to/spec-driven-llm-development/validation/validate-generated-docs/SKILL.md
and run it on the docs just generated in this repo.
```

It isn't installed into your repo (use `audit-docs` for ongoing checks). Review its diff before committing.

## Contents

```
spec-driven-llm-development/
├── README.md                          # You are here
├── prompt.md                          # The instruction file you give to your AI agent
├── scripts/
│   └── watch-generation.sh            # Optional: watch a generation run (files written, progress, tokens)
├── research/
│   └── evidence-and-guidelines.md     # Full research synthesis (read for understanding, not required)
├── templates/
│   ├── AGENTS.md                      # Root agent document template
│   ├── service-agents.md              # Per-service/module agent document template
│   ├── architecture-doc.md            # Architecture document template
│   ├── guide.md                       # How-to guide template
│   ├── spec.md                        # Feature specification template
│   ├── decision.md                    # Architectural decision record template
│   ├── working-with-agents.md         # "Working with Agents" section for the root README
│   └── find-missing-context-skill.md          # Skill template: search external resources before guessing (filled in per repo)
├── validation/
│   └── validate-generated-docs/SKILL.md   # One-time accuracy pass after generation (not installed into your repo)
├── skills/
│   ├── update-docs/SKILL.md           # Claude Code skill: update docs after code changes
│   └── audit-docs/SKILL.md            # Claude Code skill: periodic audit of docs vs codebase
└── examples/
    ├── root-agents-md.md              # Example root AGENTS.md (fictional e-commerce monorepo)
    ├── service-agents-md.md           # Example per-service AGENTS.md
    └── architecture-doc.md            # Example architecture document
```

## Skills (Claude Code)

The `skills/` directory contains two Claude Code skills for ongoing documentation maintenance. The generator copies each one into your target repo as `.claude/skills/<name>/` and adapts it (Step 7b of `prompt.md`). To copy them by hand:

```bash
# From your target repo root:
mkdir -p .claude/skills
cp -r /path/to/spec-driven-llm-development/skills/update-docs /path/to/spec-driven-llm-development/skills/audit-docs .claude/skills/
```

This gives you `update-docs` and `audit-docs`. Once placed, new Claude sessions should be able to use them to keep your docs up to date.

- **`/update-docs`** — run after any code change to sync affected docs
- **`/audit-docs`** — run periodically to catch drift from PRs that skipped `/update-docs`

The generation prompt also creates a third, repo-specific skill from `templates/find-missing-context-skill.md`:

- **`find-missing-context`** — reminds agents which external resources they can reach (chat, issue tracker, wiki, other repos, observability) and to search them before guessing or asking. It lives in `templates/` rather than `skills/` because it has to be filled in with each repo's real resources.

## The 10 Writing Rules (Summary)

These are the empirically-backed rules that govern all generated documentation:

1. **Layered retrieval** — scope context to the task. Don't flood everything at once.
2. **Keep docs fresh** — "Last verified" dates on every doc. Stale docs are defects.
3. **Critical info at edges** — start or end of document, never buried in the middle.
4. **Curate hard** — less is more. Under 200 lines per doc (300 max for complex topics).
5. **Concrete code examples** — over abstract prose. Real file paths, real code.
6. **Reference actual code** — not generic "similar" patterns. Point to the real thing.
7. **Exact interfaces** — specify real function names, class names, explicit requirements.
8. **Don't over-invest in format** — no empirical support for template structure mattering.
9. **Cite with links** — actual URLs, not "per the docs somewhere."
10. **Describe the present** — not the past. Remove references to retired behavior.

Each rule has empirical backing mapped in the [research synthesis](research/evidence-and-guidelines.md#4-design-principles-plain-language-summary).

## Who This Is For

- Teams with codebases that AI agents struggle to navigate
- Projects with no documentation or outdated docs
- Anyone who wants to systematically improve AI agent performance on their code
- Monorepos, microservices, or any multi-module project

## Philosophy

This is NOT a documentation framework for humans (though humans benefit too). It's specifically optimized for how LLMs consume and reason about context. The key differences from traditional documentation:

- **Ruthless length limits** (LLM attention degrades with context size)
- **Layered architecture** (just-in-time retrieval, not everything-at-once)
- **Examples over explanations** (ablation studies show examples matter most)
- **Freshness as a first-class concern** (stale docs cause confidently wrong code)

## License

MIT — use however you want.
