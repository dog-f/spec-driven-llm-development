---
name: find-missing-context
description: Use when you don't have enough context to be sure — about how a system or external service works, why a decision was made, what a ticket/thread/acronym refers to, why code looks the way it does, or what happened to something that was removed, renamed, or deprecated. Searches [the team's external resources, e.g. Slack, Jira, Confluence, GitHub, sibling repos, observability, the web] before you guess, assume, or ask the user.
---

# Find Missing Context Before Guessing

Last verified: YYYY-MM-DD

You have access to more than this repo. When you notice yourself about to write "probably", "likely", "I assume", or "it seems", or about to ask the user something a teammate could have answered, stop and search first. A guess presented as fact costs more than a few tool calls.

## Getting access: MCP first, then CLI, then authorize

Most resources can be reached as an MCP server, a CLI, or both (e.g. the GitHub MCP and `gh`). [List the MCP/CLI pairs this team has.] Before deciding you can't reach a resource:

1. **Look for an MCP tool first, and prefer it.** MCP tools are often **deferred**: only their names are listed, and you must load their schemas before calling them. Search by keyword (e.g. `ToolSearch` with `slack`, `jira`, `github`). Also check the session's list of MCP servers that need authentication or failed to connect, since an unauthorized server has no callable tools yet.
2. **Fall back to a CLI** only if there's no MCP for the resource, or the MCP can't do what you need. Check with `command -v <tool>` and the tool's `--help`.
3. **Authorize only when the question needs that resource.** Search the sources that are already connected first. Start a login only when the question you're working on specifically needs a resource that isn't connected yet, and only for that resource. Never ask the user to log in to tools up front or "just in case." When a login is needed, don't treat "not logged in" as "not available":
   - MCP: call the server's authenticate tool if it exposes one (often `mcp__<server>__authenticate`) and give the user the URL it returns. If the session can't run the OAuth flow, tell the user to authorize the server in `/mcp` (or their connector settings), then continue once they have.
   - CLI: run its login command (e.g. `gh auth login`). If it opens a browser or prompts for input, tell the user what to run and why.
   - Never ask for raw tokens, passwords, or callback codes in chat.
4. **If a server failed to connect** (as opposed to needing auth), tell the user so they can fix it, and try the CLI meanwhile.

## What each resource is good for

These are starting points, not boundaries. Any resource can hold the answer to any question, so if the obvious one comes up empty, try the next.

| Resource | Reach for it when you need |
|---|---|
| **[Chat, e.g. Slack]** | Why something was done, tribal knowledge, incident chatter, "has anyone seen this error", who owns what |
| **[Issue tracker + project key]** | What a ticket means, acceptance criteria, bug history, whether something is already planned or fixed, similar or duplicate bugs and how they were resolved |
| **[Wiki, e.g. Confluence space]** | Design docs, architecture decisions, runbooks, product requirements |
| **[Code host + org, e.g. GitHub `my-org`]** | PR discussions explaining a change, code in repos that aren't checked out, issues |
| **[Sibling repos + local paths]** | How a caller or callee actually behaves, API contracts, deploy config |
| **[Observability, e.g. logs/APM]** | What production actually does: errors, real payloads, whether a path is hit |
| **Web** | Third-party library and protocol docs, upstream changelogs, known issues |

[Remove rows the team doesn't have. Add rows for any other resource agents can reach. Keep each "reach for it when" broad: describe kinds of questions, not an exhaustive list, so an agent never rules a resource out.]

## How to search

1. **Search in parallel.** Query several sources in one turn. They're cheap and the answer is often in only one of them.
2. **Vary the query.** Try the ticket key, the error string, the function or service name, the product name, and the person's name. One failed query isn't a miss.
3. **Follow the links.** Tickets link threads that link docs, so read the source itself, not only the search snippet.
4. **Verify against the code.** Chat and wikis drift. Treat what you find as a lead, and confirm it in the current code before acting on it.
5. **Search the web before giving up.** If internal sources come up empty, search the web (`WebSearch` / `WebFetch`, which may also be deferred, so load them with `ToolSearch`). Try the exact error string, the library or protocol name with its version, the vendor's docs, and GitHub issues for third-party dependencies. Many "unexplained" behaviors are upstream behaviors with a public answer.
6. **Know when to stop.** Only after internal sources *and* the web come up empty, ask the user. Say what you searched and what you found.

## Report what you found

When context shaped your answer, cite it with a link. When you searched and found nothing, say so. An unflagged assumption isn't useful.

**Remember:** missing context is a reason to search, not to guess. Get access to the tool (MCP first, then the CLI, authorizing only the one this question needs), search the internal sources, then the web, and only then ask the user.
