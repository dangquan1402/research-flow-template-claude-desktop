---
title: "Template Consistency & Completeness Audit"
created: 2026-06-01
goal: "Review the research-flow template for missing pieces, inconsistencies, and broken references"
type: critique
method: "8 parallel multi-dimensional finders + adversarial per-finding verification (62 agents)"
---

# Template Consistency & Completeness Audit

An exhaustive audit of the `research-flow-template-claude-desktop` repo. Eight
finders swept different dimensions (CLAUDE.md↔skills, README↔reality, link
integrity, hooks/invariants, scaffold/config, per-skill correctness,
examples/docs, completeness) and **every** finding was adversarially
re-verified against the actual files before counting.

**Result: 53 confirmed gaps** (1 high, 19 medium, 33 low) out of 54 raised
(1 rejected as unsubstantiated). All but 2 (intentionally deferred) were fixed
on branch `review/template-consistency-audit`.

## Highest-impact findings

| # | Sev | Finding | Fix |
|---|-----|---------|-----|
| 13/14/18 | high* | **Source immutability was only half-enforced** — `block-source-modification.sh` guarded only `Edit`; `Write`-overwrite and `Bash` (`rm`/`sed -i`/…) could mutate `sources/` undetected, yet docs claimed "immutable (enforced by hook)". | Hook now covers `Edit` + `Write` (blocks overwriting existing sources, allows new) + a best-effort `Bash` guard for mutate-in-place/delete verbs (`rm`/`sed -i`/`truncate`/`dd of=`; `cp`/`mv`/`curl -o` left open as ingest paths); `settings.json` rewired; docs reworded. |
| 38 | high | **single-gpu-experiment README contradicted its shipped artifacts** — narrated RTX 4090 / `best_val=1.62` / 184s / `--max-seconds=1200` while `expected/metrics.json` + `run.log` are RTX 3090 / `2.33` / 28.4s / `60`. Its own acceptance (`<1.7`) would *fail* against the shipped metrics. | All narrative numbers reconciled to the artifacts; reframed as a "pipeline-works baseline (not converged)" per the `_note`. |
| 15/16 | med | Branch protection only blocked literal `main`; didn't enforce the documented typed-branch rule. | Positive allowlist (`research/`, `hypothesis/`, `synthesis/`, `review/`); also covers `master`/detached HEAD and tolerates `git -c`/whitespace. |
| 29/46 | med | `/research` hardcoded another user's GH owner (`--owner dangquan1402`) and an unresolved `{PROJECT_NUMBER}`. | `--owner @me`; `/setup` now persists the project number/repo into CLAUDE.md. |
| 20/45 | med | README/site declared MIT but **no LICENSE file** existed. | Added `LICENSE` (MIT) + `license`/`license-files` in pyproject; `/setup` reminds users to set the holder. |
| 39/40 | med | Docs referenced a `/report` skill and `outputs/quickstart-report.html` that don't exist. | Removed `/report`; pointed at `/synthesize` and `outputs/quickstart-synthesis.md`. |
| 47 | med | No CI despite the repo preaching ruff/pre-commit (and `/setup` requesting the `workflow` scope). | Added `.github/workflows/ci.yml` (ruff check + format on push/PR). |
| 21 | med | pre-commit pinned ruff `v0.8.0` while the project runs `0.15.10`. | Bumped pre-commit rev to `v0.15.10`. |
| 2/52 | med | `goals/` is read by 7 skills but absent from CLAUDE.md's architecture. | Documented `goals/` as a top-level layer + its frontmatter convention. |
| 42 | med | `docs/claude-code-guide.md` skill tree/table omitted import, vastai, quickstart, setup. | Tree + table now list all 15 skills. |
| 48 | med | `entity-registry.json` shape documented nowhere. | Added an "Entity Registry Schema" section to `memory-page-template.md`. |

\* raised as medium by finders; grouped here as the repo's most important
invariant hole.

## Other fixes (low severity)

- CLAUDE.md: added `/import` + `/setup` to the command map; frontmatter rule now
  lists `verification`/`related`/`staleness_days`; `vastai` added to dep lists.
- README: skills list now includes `/vastai` + `/quickstart`; docs/examples/scripts
  dirs + LICENSE added to "What's included"; Jekyll URL fixed to `/docs/`.
- Skills: `verify.md` broken `experiments/config.py` → `experiments/configs/`;
  `evidence`/`examples`/`verify` use `uv run python` (+ `uv add` notes);
  `experiment.md` commit prefix `experiment(` → `hypothesis(`; `lint.md`/`distill.md`
  branch-before-commit notes; `research.md`/`synthesize.md` literal `\n` → heredoc.
- `outputs/{evidence,verification,examples,critiques}/` scaffolded with `.gitkeep`.
- `.gitignore`: ignore `examples/quickstart/{logs,results}/`.
- Docs: unique `nav_order` per page (was colliding); host placeholder in
  `run.log.snippet`; sample-run diff note.
- pyproject: `target-version` `py312` → `py311` (matched `requires-python`).

## Deferred (intentionally not fixed)

- **#49** — extra issue templates for `synthesis`/`maintenance` labels (GitHub
  falls back to a default chooser; the automated skills don't use templates).
- **#53** — `CONTRIBUTING.md` / PR template (only relevant if the upstream
  template repo itself wants external contributions; downstream clones `rm -rf .git`).

## Rejected (unverified)

1 finding was raised and dropped during adversarial verification as not
substantiated by the files.

## What would change this assessment (FUNGI)

- If a `Bash` source-mutation slips past the heuristic guard (it's best-effort,
  not a sandbox) — the guarantee is "Edit/Write-overwrite blocked + common Bash
  ops blocked", not "provably immutable". Documented as such.
- If the single-gpu artifacts are later regenerated on a different GPU, the
  reconciled README numbers will drift again — the durable fix would be to make
  the README pull numbers from `expected/metrics.json` rather than hardcode them.
