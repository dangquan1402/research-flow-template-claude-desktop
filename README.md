# research-flow-template-claude-desktop

Skeleton for an agentic research project with persistent working memory, Claude Code skills, and a GitHub Project board for tracking goals → hypotheses → findings.

**This is a template repo, set up for the Claude Desktop workflow.** Instead of a one-shot `npx` scaffolder, you clone this template, open it in Claude (Desktop or Code), and let Claude walk you through setup **step by step** — installing the GitHub CLI for your OS, logging you in, creating your repo, and wiring up a Project board linked to that repo.

---

## Setup — step by step

> You don't run most of these commands yourself. Open this folder in Claude and paste the prompt under each step; Claude detects your OS, runs the command, and reports back. The only thing Claude can't do for you is the interactive browser login in Step 2.

### Step 0 — Get the template onto your machine

Clone this template (or download it as a ZIP and unzip it), then open the folder in Claude Desktop or Claude Code:

```bash
git clone https://github.com/dangquan1402/research-flow-template-claude-desktop.git my-research
cd my-research
```

Everything below is **typed inside Claude**, with this folder open.

### Step 1 — Install the GitHub CLI (OS-aware)

The GitHub CLI (`gh`) is what creates your repo, the Project board, labels, and branch↔issue links. Ask Claude to install it for your operating system:

```
Install the GitHub CLI for me.
- Detect my OS first.
- macOS:    brew install gh        (install Homebrew first if missing)
- Windows:  winget install --id GitHub.cli   (or: choco install gh)
- Linux:    use the package manager for my distro (apt / dnf), else
            the official repo at cli.github.com/manual/installation
Then verify with `gh --version`.
```

Claude picks the right command for your platform and confirms the install.

### Step 2 — Log in to GitHub (Claude starts it, you finish in the browser)

`gh auth login` is interactive — it opens a browser / shows a device code. Claude will **start** it for you; you complete the prompt:

```
Run `gh auth login` for me.
- Choose GitHub.com, HTTPS, and "Login with a web browser".
- I'll complete the browser step; tell me the one-time code to paste.
- Make sure the token has `repo`, `project`, and `workflow` scopes.
When it finishes, run `gh auth status` and confirm I'm logged in.
```

> **Two GitHub accounts?** Tell Claude which one to use and it will set `GH_CONFIG_DIR=~/.config/gh-<profile>` before each `gh` call.

### Step 3 — Name your project (this becomes the repo)

Claude needs a name for your new GitHub repository:

```
My project name is: <my-research-project>
Use it as the GitHub repo name (lowercase, hyphens — no spaces).
```

### Step 4 — Create the repo from this template

Claude turns the current folder into a brand-new GitHub repo under your account and pushes it:

```
Create a new GitHub repo named <my-research-project> from this folder:
- git init + initial commit if not already a repo
- gh repo create <my-research-project> --public --source=. --remote=origin --push
Print the repo URL when done.
```

(Use `--private` instead of `--public` if you'd rather keep it closed.)

### Step 5 — Create a Project board **linked to this repo**

Rather than a standalone board floating in your account, you want a Project **linked to the dedicated repo**, with a layout that fits research tracking and your existing issues imported into it.

```
Set up a GitHub Project for <my-research-project>:
1. Create it:   gh project create --owner @me --title "<my-research-project>"
2. Link it to the repo so it lives with the code:
   gh project link <project-number> --owner @me --repo <me>/<my-research-project>
3. Print the project URL so I can finish the layout in the browser.
```

**Then, in the browser (the CLI can't do these two):**
- **Choose the layout** — open the project, click the view tab, and pick **Board** (`Backlog | In Progress | Synthesizing | Done`) or **Table**. Board is the natural fit for the research loop.
- **Import existing issues** — use the project's **"+ Add item"** → search your repo's issues, or the **"Add items from a repository"** bulk option, to pull this repo's issues onto the board. New issues Claude opens later can be added from the CLI with `gh project item-add <project-number> --owner @me --url <issue-url>`.

### Step 6 — Seed labels and install deps

```
Finish setup for <my-research-project>:
- Create labels: research-goal, hypothesis, finding, synthesis, maintenance
- Run `uv sync` to install core Python deps
Confirm both succeeded.
```

You're ready to start the research loop.

---

## What's included

```
.claude/
  skills/     /research, /analyze, /import, /experiment, /synthesize,
              /distill, /evidence, /verify, /examples, /critique,
              /lint, /read-pdf
  hooks/      Source immutability, branch protection, memory-update reminders
  settings.json

.github/
  ISSUE_TEMPLATE/   research-goal, hypothesis, finding

docs/
  claude-code-guide.md    Every Claude Code primitive explained
  git-workflow.md         Branch strategy and multi-agent dispatch
  memory-page-template.md Frontmatter templates for memory pages

memory/
  index.md, log.md, entity-registry.json
  entities/, findings/, themes/, open-questions/, decisions/

sources/                  Immutable raw material (write-once)
goals/                    Active research goal definitions
outputs/                  Deliverables (reports, evidence, verification, examples, critiques)
experiments/              Blank scaffold — add your own training code and framework

CLAUDE.md                 The research loop, memory rules, git flow, conventions
pyproject.toml            uv-managed Python deps (loguru, pyyaml, pymupdf, tqdm)
```

## How it works

Claude reads `CLAUDE.md` on every session start. Hooks enforce invariants automatically. Skills give Claude step-by-step procedures for each phase of the research loop.

The three-layer memory model:
1. **Sources** (`sources/`) — immutable raw material, never edited after creation
2. **Working Memory** (`memory/`) — LLM-maintained wiki updated every research cycle
3. **Schema** (`CLAUDE.md`) — conventions and rules Claude always has in context

## Read next

- [`CLAUDE.md`](CLAUDE.md) — start here
- [`docs/getting-started.md`](docs/getting-started.md) — prerequisites and your first session
- [`docs/pdf-to-agents-quickstart.md`](docs/pdf-to-agents-quickstart.md) — PDF → memory → issues → agent team, cell by cell
- [`docs/sample-pipeline.md`](docs/sample-pipeline.md) — **15-min end-to-end canary on Vast.ai** (rent → train → report) with verify checkpoints at every step
- [`docs/claude-code-guide.md`](docs/claude-code-guide.md) — full explanation of every Claude Code primitive
- [`docs/git-workflow.md`](docs/git-workflow.md) — branch types and naming
- [`docs/memory-page-template.md`](docs/memory-page-template.md) — frontmatter for memory pages

## Browse docs locally

```bash
gem install bundler && bundle install
bundle exec jekyll serve
# open http://localhost:4000
```

## License

MIT
