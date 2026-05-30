---
name: setup
description: One-shot project bootstrap — check/install the GitHub CLI per-OS, log the user in, create the repo from this folder, and link a GitHub Project board. Run this once after cloning the template.
user_invocable: true
---

# /setup — Bootstrap a New Research Project

Turns this freshly-cloned template into the user's own GitHub repo with a linked Project board. Run the steps **in order** and **stop at the first failure** — resolve it before continuing. Every command runs for the user; the only thing they do themselves is complete the browser login in Step 2.

> **Multi-account note:** if the user runs more than one GitHub account, ask which to use and prefix every `gh` call with `GH_CONFIG_DIR=~/.config/gh-<profile>`.

---

## Step 0 — Detect the OS (decides install commands)

```bash
uname -s   # Darwin = macOS, Linux = Linux. MINGW*/MSYS* = Windows (Git Bash); native Windows users are in PowerShell.
```

Remember the result — it picks the install command in Step 1.

## Step 1 — Is the GitHub CLI installed?

```bash
gh --version
```

**If it prints a version**, skip to Step 2.

**If `gh: command not found`, install it for the detected OS, then re-run `gh --version` to confirm:**

- **macOS:** `brew install gh` — if `brew` itself is missing, install Homebrew first (`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`), then `brew install gh`.
- **Windows:** `winget install --id GitHub.cli` (or `choco install gh` if they use Chocolatey).
- **Linux (Debian/Ubuntu):** `sudo apt update && sudo apt install gh` — on older distros without it, follow the official apt repo at <https://cli.github.com/manual/installation>.
- **Linux (Fedora/RHEL):** `sudo dnf install gh`.
- **Any OS fallback:** download a release from <https://github.com/cli/cli/releases>.

Do not proceed until `gh --version` succeeds.

## Step 2 — Is the user logged in?

```bash
gh auth status
```

**If it shows a logged-in account with `repo`, `project`, and `workflow` scopes**, skip to Step 3.

**If not logged in (or missing scopes), start the interactive login.** This opens a browser / shows a one-time device code — **you cannot complete it headless.** Run:

```bash
gh auth login --hostname github.com --git-protocol https --web --scopes "repo,project,workflow"
```

Then tell the user: *"A browser / device code is up — paste the one-time code I just printed and authorize, then tell me when you're done."* Wait for them, then **verify**:

```bash
gh auth status
```

Do not proceed until they're logged in with the three scopes.

## Step 3 — Get the project (repo) name

Ask the user for a project name if they haven't given one. Normalize it: lowercase, hyphens, no spaces. This is both the repo name and the Project board title. Confirm it back to them before creating anything.

## Step 4 — Create the repo from this folder and push

This folder should have **no `.git`** (the README's Step 0 says `rm -rf .git` after clone). Verify, then create:

```bash
# Confirm we're starting fresh — if a .git already exists pointing at the template, detach it:
test -d .git && git remote -v   # if origin = the template, run: rm -rf .git

git init -b main
git add -A
git commit -m "chore: initial commit from research-flow-template-claude-desktop"
gh repo create <project-name> --public --source=. --remote=origin --push
```

(Use `--private` instead of `--public` if the user prefers.) Print the repo URL.

> **Recommend a restart here.** The folder is now a real git repo with its own `origin`, `CLAUDE.md`, skills, and hooks. For the cleanest project context, suggest the user **quit Claude and reopen a fresh session on this folder**, then run `/setup` again (it will detect `gh` is installed + logged in and the repo exists, and skip straight to Step 5). If they'd rather not restart, just continue to Step 5 in the current session.

## Step 5 — Create a Project board linked to the repo

```bash
gh project create --owner @me --title "<project-name>"
# note the project number it returns, then:
gh project link <project-number> --owner @me --repo <me>/<project-name>
```

Print the project URL. Then tell the user the two **browser-only** finishing touches (the CLI can't do these):

- **Choose the layout** — open the project, click the view tab, pick **Board** (`Backlog | In Progress | Synthesizing | Done`) or **Table**.
- **Import existing issues** — use **"Add items from a repository"** to pull this repo's issues onto the board. New issues you open later are added with `gh project item-add <project-number> --owner @me --url <issue-url>`.

## Step 6 — Seed labels and install deps

```bash
for L in research-goal hypothesis finding synthesis maintenance; do
  gh label create "$L" 2>/dev/null || echo "label $L already exists"
done
uv sync
```

## Done

Report a short summary: repo URL, project URL, labels created, deps installed. Tell the user they can now start the research loop with `/research`.
