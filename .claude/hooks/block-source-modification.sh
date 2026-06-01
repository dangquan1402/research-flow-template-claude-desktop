#!/bin/bash
# PreToolUse hook: Keep source files immutable after creation (write-once).
#
# Sources are the raw material of research — once ingested they must never
# change, or findings that cite them become untrustworthy. To "fix" a source,
# create a new page in memory/findings/ instead.
#
# Coverage (all three paths a source could be mutated):
#   - Edit  : always blocked on sources/ (Edit only ever targets existing files)
#   - Write : blocked on sources/ ONLY when the target already exists
#             (a brand-new source file via Write is the legitimate ingest path)
#   - Bash  : blocked when the command destructively targets sources/
#             (rm / mv / cp-into / sed -i / truncate / tee / dd / > / >> redirect)

TOOL_NAME="$1"
ARG="$2"   # Edit/Write: the file path. Bash: the full command.

case "$TOOL_NAME" in
  Edit)
    if [[ "$ARG" == *"sources/"* && "$ARG" != *".gitkeep"* ]]; then
      echo "BLOCKED: Source files are immutable after creation. Do not Edit sources/. Create a new finding in memory/findings/ instead." >&2
      exit 2
    fi
    ;;
  Write)
    # Allow creating genuinely-new source files; block overwriting existing ones.
    if [[ "$ARG" == *"sources/"* && "$ARG" != *".gitkeep"* && -e "$ARG" ]]; then
      echo "BLOCKED: '$ARG' already exists and sources/ is immutable. Do not overwrite a source. Create a new finding in memory/findings/ instead." >&2
      exit 2
    fi
    ;;
  Bash)
    # Heuristic guard: catch shell ops that can ONLY mutate/delete an EXISTING
    # file (rm / sed -i / truncate / dd of=). Deliberately does NOT match
    # cp/mv/tee/redirects — those are the documented ingest paths for new
    # sources (e.g. /read-pdf's `curl -o sources/x.pdf`, /import's `cp ... sources/`),
    # and a verb-only check can't tell "create new" from "overwrite existing".
    # This is best-effort, not a sandbox.
    if echo "$ARG" | grep -Eq \
      -e '(^|[^[:alnum:]_])rm[[:space:]].*sources/' \
      -e '(^|[^[:alnum:]_])sed[[:space:]]+-i.*sources/' \
      -e '(^|[^[:alnum:]_])truncate[[:space:]].*sources/' \
      -e '(^|[^[:alnum:]_])dd[[:space:]].*of=[^[:space:]]*sources/'; then
      echo "BLOCKED: command appears to delete or modify-in-place files under sources/, which are immutable. Read sources freely; record changes in memory/findings/ instead." >&2
      exit 2
    fi
    ;;
esac

exit 0
