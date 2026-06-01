#!/bin/bash
# PreToolUse hook: Enforce the typed-branch Git Flow for commits.
# All work must happen on a research/, hypothesis/, synthesis/, or review/
# branch — never directly on main/master (or a detached HEAD).

TOOL_NAME="$1"

if [[ "$TOOL_NAME" != "Bash" ]]; then
  exit 0
fi

COMMAND="$2"

# Best-effort detection of `git commit` (tolerate extra whitespace and
# `git -c key=val` / `git -C path` global flags before the subcommand).
NORM=$(echo "$COMMAND" | tr -s '[:space:]' ' ')
if [[ "$NORM" == *"git commit"* || "$NORM" =~ git\ (-[cC][^\ ]*\ [^\ ]+\ )*commit ]]; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [[ ! "$BRANCH" =~ ^(research|hypothesis|synthesis|review)/ ]]; then
    echo "BLOCKED: Commits must be on a research/, hypothesis/, synthesis/, or review/ branch (current: ${BRANCH:-unknown}). Create one first, e.g. \`git checkout -b review/GH-<issue>-<slug>\`." >&2
    exit 2
  fi
fi
