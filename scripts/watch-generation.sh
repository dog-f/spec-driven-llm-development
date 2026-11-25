#!/usr/bin/env bash
# Watch a documentation-generation run from a second terminal.
#
# Every interval it prints: files the run has created or changed (from git),
# the last line of the generator's progress log, and, when the run is a
# Claude Code session started in the target repo, its token usage so far
# (including subagents). Tokens, not cost: prices vary by plan and model.
#
# Usage: scripts/watch-generation.sh /path/to/target-repo [interval-seconds] [--once]
#
# Some reading before the first doc is normal; on a large codebase the first
# file usually appears within about 15 minutes. No file after ~15 minutes, or
# ~15 minutes without a new file once writing has started, while tokens keep
# climbing, means the run is reading instead of writing: the cue to stop it.

set -euo pipefail

target="${1:?usage: watch-generation.sh /path/to/target-repo [interval-seconds] [--once]}"
interval="${2:-60}"
once="${3:-}"
[[ "$interval" == "--once" ]] && { once="--once"; interval=60; }

target="$(cd "$target" && pwd)"
log="$target/.docgen-progress.log"

tokens() {
  python3 - "$target" <<'EOF'
import glob, json, os, re, sys
key = re.sub(r"[^A-Za-z0-9]", "-", sys.argv[1])
proj = os.path.expanduser(f"~/.claude/projects/{key}")
sessions = sorted(glob.glob(f"{proj}/*.jsonl"), key=os.path.getmtime)
if not sessions:
    sys.exit(0)
session = sessions[-1]
files = [session] + glob.glob(session[:-6] + "/**/*.jsonl", recursive=True)
seen = {}
for path in files:
    try:
        for line in open(path):
            try:
                msg = json.loads(line).get("message") or {}
            except ValueError:
                continue
            usage, mid = msg.get("usage"), msg.get("id")
            if usage and mid:
                seen[(path, mid)] = usage
    except OSError:
        pass
fresh = sum(u.get("input_tokens", 0) for u in seen.values())
cached = sum(u.get("cache_read_input_tokens", 0) for u in seen.values())
written = sum(u.get("cache_creation_input_tokens", 0) for u in seen.values())
out = sum(u.get("output_tokens", 0) for u in seen.values())
print(f"tokens in {(fresh + cached + written) / 1e6:.1f}M (cached {cached / 1e6:.1f}M), out {out / 1e3:.0f}k, agents {len(files)}")
EOF
}

while true; do
  files="$(git -C "$target" status --porcelain --untracked-files=all | grep -cv '\.docgen-progress\.log$' || true)"
  last="$( [[ -f "$log" ]] && tail -n 1 "$log" || echo "no progress log yet")"
  usage="$(tokens 2>/dev/null || true)"
  echo "$(date +%H:%M:%S)  files ${files}  ${usage:+$usage  }last: ${last}"
  [[ "$once" == "--once" ]] && break
  sleep "$interval"
done
