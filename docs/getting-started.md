---
layout: default
title: Getting Started
nav_order: 3
---

# Getting Started
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
- TOC
{:toc}
</details>

---

## Prerequisites

### Required

**Claude** — Claude Desktop or Claude Code is the agent that drives everything (including the setup below). If you're using Claude Code in a terminal:
```bash
npm install -g @anthropic-ai/claude-code
claude   # opens browser login on first run (Claude.ai Pro or Max)
```

**Python ≥ 3.11 + uv** — for the Python toolchain and PDF skill.
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

> **No Node.js / npx needed.** This variant has no scaffolder package — Claude sets the project up for you, step by step. The GitHub CLI (`gh`) is installed as part of that setup, not beforehand.

### Optional

**Your ML framework** — `experiments/` is a blank scaffold. Add whatever you need:
```bash
uv add torch        # or jax, tensorflow, scikit-learn, etc.
```

---

## Set Up Your Project (step by step)

There's no `npx create-research-flow` here. You clone the template, open it in Claude, and Claude walks you through each step — paste the prompt under each one and Claude runs it for you.

Want to read the steps first without cloning? Grab the raw README:

```bash
curl -fsSL https://raw.githubusercontent.com/dangquan1402/research-flow-template-claude-desktop/main/README.md
# or save it:   curl -fsSL .../main/README.md -o README.md
```

### 0. Get the template

```bash
git clone https://github.com/dangquan1402/research-flow-template-claude-desktop.git my-research
cd my-research
rm -rf .git          # detach from the template's history — this becomes YOUR repo
```

(Downloaded the ZIP instead? There's no `.git` to remove — skip that line.)

Open the `my-research` folder in Claude Desktop or Claude Code. Everything below is typed **inside Claude**.

### 1. Install the GitHub CLI (Claude detects your OS)

```
Install the GitHub CLI for me. Detect my OS first.
- macOS:    brew install gh
- Windows:  winget install --id GitHub.cli   (or choco install gh)
- Linux:    apt / dnf, or cli.github.com/manual/installation
Verify with `gh --version`.
```

### 2. Log in (Claude starts it, you finish in the browser)

```
Run `gh auth login` for me — GitHub.com, HTTPS, "Login with a web browser".
I'll complete the browser step; tell me the one-time code. The token
needs `repo`, `project`, and `workflow` scopes. Confirm with `gh auth status`.
```

### 3. Name the project (becomes the repo name)

```
My project name is: <my-research-project>  (lowercase, hyphens)
```

### 4. Create the repo from this folder

```
Create the repo from this folder and push it (the template .git was
removed in step 0, so this is a fresh repo):
git init && git add -A && initial commit, then
gh repo create <my-research-project> --public --source=. --remote=origin --push
```

> **Restart here.** Once the repo is created and pushed, **quit Claude and start a fresh session opened on the new `my-research` folder.** This is now a real git repo with its own `origin`, `CLAUDE.md`, skills, and hooks — a clean session loads that project context from the start. Reopen the folder, then continue with Step 5.

### 5. Create a Project board linked to the repo

```
Create a GitHub Project and link it to the repo:
gh project create --owner @me --title "<my-research-project>"
gh project link <project-number> --owner @me --repo <me>/<my-research-project>
Print the project URL.
```

Then in the browser, pick the **Board** layout (`Backlog | In Progress | Synthesizing | Done`) and **import this repo's issues** via the project's "Add items from a repository" option. (Layout + bulk import are web-only; the CLI handles create, link, and per-issue `gh project item-add`.)

### 6. Seed labels + install deps

```
Create labels research-goal, hypothesis, finding, synthesis, maintenance,
then run `uv sync`.
```

---

## Your First Research Session

Once inside Claude:

### 1. Define your goal

```
/research
```

Claude will ask for your research question, then:
- Open a GitHub issue (label: `research-goal`)
- Create a `research/GH-{n}-{slug}` branch
- Write a goal file in `goals/`
- Log the operation to `memory/log.md`

### 2. Feed in sources

```
/analyze https://arxiv.org/abs/...
/analyze path/to/paper.pdf
/analyze "topic: transformer attention mechanisms"
```

Each call extracts entities and findings into `memory/`, updates `memory/index.md`, and logs the operation.

For PDFs with figures and tables, use the image-based reader:
```
/read-pdf path/to/paper.pdf
```

### 3. Import an existing project

```
/import path/to/existing-repo
/import https://github.com/org/repo
```

Bulk-copies artifacts to `sources/`, extracts findings and entities in one pass.

### 4. Run experiments

```
/experiment
```

Claude will ask for your hypothesis and acceptance criteria, then guide you through writing an experiment plan, running your code, classifying the result, and writing a finding.

### 5. Synthesize

```
/synthesize
```

Reads all of `memory/findings/`, builds themes, resolves contradictions, and writes an output report to `outputs/`.

### 6. Distill decisions

```
/distill
```

Extracts actionable decisions from settled findings into `memory/decisions/`.

---

## Parallel Research with Multiple Agents

Spin up agents on separate `hypothesis/` branches to explore different angles simultaneously:

```
Agent({
  isolation: "worktree",
  prompt: "Research goal: {goal}. Your angle: {angle}. Branch: hypothesis/GH-{n}-{slug}.",
  description: "Hypothesis: {angle}"
})
```

Each agent works in its own git worktree — no conflicts. Merge the best findings via a `synthesis/` branch.

---

## Verify Your Setup with the Quickstart Canary

Before starting real research, run the end-to-end canary to confirm every layer of the pipeline is wired correctly on your machine. It takes ~15 minutes and costs ~$0.20 in Vast.ai compute.

➡ **[docs/sample-pipeline.md](sample-pipeline.md)** — 11 steps from `/research` to `/vastai terminate`, each with a ✅ Verify checkpoint so failures localize to the broken layer.

If the canary passes, your installation is good. If not, fix the failing step before starting your own research — debugging the pipeline mid-experiment is much harder.

---

## Useful Commands

| Command | Purpose |
|---|---|
| `uv sync` | Install core deps |
| `uv add <pkg>` | Add a dependency |
| `uv run ruff check .` | Lint |
| `uv run ruff format .` | Format |
| `uv run pre-commit run --all-files` | Run all pre-commit hooks |
