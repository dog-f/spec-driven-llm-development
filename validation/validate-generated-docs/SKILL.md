---
name: validate-generated-docs
description: One-time accuracy check of a freshly generated documentation set, run once after prompt.md finishes and before the docs are committed. Fresh agents check each group of docs against the code, fix confirmed errors, and fill common gaps found by cheap greps. Not installed into the target repo; for ongoing drift checks use audit-docs.
---

# Validate Generated Docs

Run this once, right after generation and before you commit the new docs. The generator wrote each doc from what it had read at the time; this pass checks the finished set against the code with agents that never saw the generation, so they don't share its blind spots.

Expect it to cost roughly a quarter to a third of the generation run. It mainly fixes wrong claims and contradictions. It also adds facts the generator commonly drops, where they can be found cheaply (warning comments, deploy-file invariants, unused dependencies, and conditions next to code it is already reading). It reports missing docs instead of writing them: writing a new doc is generation, not validation.

## 1. Collect the docs

List what generation created or changed: `git status --porcelain --untracked-files=all`, or `git diff --name-only <commit-before-generation>` if it was committed. Include every `AGENTS.md`, `CLAUDE.md`, `docs/architecture/*`, `docs/guides/*`, `docs/decisions/*`, the skills under `.claude/skills/`, and any README it edited. Skip specs and existing decision records; they are append-only.

Group them into 5–8 groups by area, keeping each module doc with the topic docs and guides that cover the same code (for example: root and meta docs; core architecture; deployment and guides; one group per cluster of services or packages).

## 2. Fill common gaps

Run these yourself, once, with greps and directory listings; don't read source to do them. For each hit, check whether the doc that owns that code mentions it, and if not, add it there in a sentence with its evidence. Keep a list of these additions; the validation agents in step 3 check them along with every other claim.

- **Warning comments**: grep source and config for `IMPORTANT`, `NOTE`, `WARNING`, `HACK`, `FIXME`, `TODO`, `keep in sync`, `must match`, `change together`, ticket keys, and region or environment names in comments. Each one that states a rule, condition, or reason belongs in a doc.
- **Deploy-file invariants**: grep Dockerfiles and deploy manifests for `USER`, `groupadd`/`addgroup`, `umask`, `chmod`, `chown`, `EXPOSE`, `ENV`, and certificate or CA paths. A value that must match another file, and the error when it doesn't, belongs in the deployment doc or guide.
- **Unused dependencies**: for each manifest (services and packages), list dependencies that no source file imports. Each is a negative fact for that module's doc.
- **Missing docs**: list areas that meet a topic-doc trigger in `prompt.md` Step 4, and packages that meet a Step 3 criterion, but have no doc. Report them; don't write them.

## 3. Validate each group with a fresh agent

Give each group to its own subagent, started without the generation context, with the group's file list and the rules below verbatim. Run them in parallel if you can. Without subagents, do one group at a time and keep notes short.

**Rules for each group agent**

Check every claim in your docs against the code, reading only what each claim needs. Do not read the whole codebase or survey areas outside your docs.

- **Exact interfaces**: every command, script name, path, port, env var, config key, file, and symbol exists and is spelled as written. Run read-only commands only (`--help`, `ls`, `grep`); don't install, build, run tests, or start services.
- **Universal claims**: for every "all", "every", "each", "only", "never", "none", or "N of", including table cells, list the members from their source of truth (file glob, route table, registry, manifests) and check each one. Claims copied from one example component and stated for all are the most common error.
- **Reachability**: something described as used, called, or live has both a registration and a call site; something configured but never called must not be described as live.
- **Values**: a field, flag, status, or default is described from the code that sets it, not from its name.
- **Pointers**: every link and "see X" lands on a doc that actually covers the fact; when a doc defers a topic to another, the other covers it.
- **Within your group**: docs that state the same fact agree.

How to fix:

- Fix only what you have confirmed wrong, in place, with the smallest edit that makes it right. Keep the doc's structure and line limits.
- Do not delete a claim because you couldn't verify it. Leave it and list it as unverified.
- **Add what you see, not what you'd have to search for.** While reading code to check a claim, if a condition, rule, consequence, or "change X and Y together" right there is missing from the doc that owns that code, add it in a sentence with its evidence. Don't go looking for more.
- Don't add new docs or new sections; if a topic has no home, report it.
- Keep each doc's `Last verified` date only if you checked all of its claims; otherwise list the doc as partially checked.
- Record every fix with its evidence: the file and symbol that show the right value.

Return: a table of fixes (`doc | wrong claim | fix | evidence`), a separate table of additions (`doc | added fact | evidence`), the unverified claims, and any disagreement with docs outside your group.

## 4. Cross-group pass

After all groups finish, check across groups yourself:

- each hard rule in the root `AGENTS.md` against the topic doc that owns it;
- each architecture summary table (which component uses which store, client, queue, or route) against the module docs it summarizes;
- the disagreements the group agents reported.

Fix confirmed errors the same way.

## 5. Report

Give the user:

- the combined fixes table with evidence;
- the additions table with evidence, kept separate from the fixes so the reviewer can see what is new;
- missing docs (unmet Step 3 and Step 4 criteria), for a person to decide on or a targeted rerun;
- the unverified claims, so a person can check them;
- docs left partially checked;
- a reminder to review the diff before committing. Validators can be wrong too, which is why every fix carries its evidence.

Leave the changes uncommitted.
