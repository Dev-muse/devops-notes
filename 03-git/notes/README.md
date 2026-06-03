# 🌿 Git for DevOps — Complete Beginner's Guide

> **Continued from:** Linux for DevOps and Bash Scripting. You already know the command line, how to navigate filesystems, and how to write scripts. Git lives entirely in the terminal and uses patterns you already know.
>
> **How to use this document:** Read top-to-bottom once. Every section has a plain-English explanation, the technical detail, and real commands you can run immediately. Come back to any section whenever you forget something.
>
> **The goal:** By the end of this document you will understand how Git works internally, use every daily Git command with confidence, manage branches and resolve merge conflicts, collaborate via Pull Requests, follow professional team workflows, avoid the mistakes that cause real production incidents, and have a clean GitHub portfolio that DevOps employers can see.
>
> **Mental model:** Git is a time machine for your code. Every `git commit` takes a snapshot of your project. You can travel back to any snapshot, branch off in a new direction, and merge timelines back together. Once that mental model is solid, every Git command makes sense.

---

# 📘 Chapter 1 — Introduction to Version Control

## 1.1 What is Version Control?

**Version control** is a system that tracks changes to files over time so you can:

- **Undo** — go back to any previous state of your project.
- **Inspect** — see exactly what changed, when, and who changed it.
- **Collaborate** — multiple people work on the same codebase without overwriting each other.
- **Branch** — work on a new feature in isolation without breaking the main codebase.
- **Recover** — if you break something, the full history is there to restore from.

> **Analogy:** Version control is a **time machine for your code and config.** Every save point (commit) is a moment you can return to. Unlike Ctrl+Z, which only goes back a few steps in one session, version control goes back months or years, across thousands of changes, on any file in your project.

**Why it's non-negotiable in DevOps:**

Every piece of infrastructure, every deployment script, every configuration file, every application — all of it lives in version control in a professional DevOps environment. If it's not in Git, it doesn't exist as far as the team is concerned. The Optum JD lists Git explicitly. Every CI/CD pipeline starts with a Git repository. You cannot do modern DevOps without this.

## 1.2 Centralised vs Distributed Version Control

Before Git dominated, two fundamentally different approaches existed:

### Centralised VCS (SVN, CVS, Perforce)

```
Developer A  ──┐
Developer B  ──┼──→  Central Server (the single source of truth)
Developer C  ──┘
```

- One central server stores the entire history.
- Developers check out files, make changes, commit back to the server.
- **Requires a network connection** to commit anything.
- **If the server goes down** → no one can commit, history is inaccessible. As the slides put it: "it's GGs."
- File locking was common — one developer editing a file blocked everyone else.
- Branching and merging were painful and slow.

### Distributed VCS (Git)

```
Developer A  (full history)
Developer B  (full history)  ←──→  GitHub (a remote copy)
Developer C  (full history)
```

- **Every developer has the full repository history** on their machine.
- You commit locally — no network needed.
- Push to a shared remote (GitHub, GitLab) to share your work.
- **If GitHub goes down** → everyone still has the full history. Work continues.
- Branching is instant and essentially free.
- Merging is fast and built into the core model.

| Feature | Centralised (SVN) | Distributed (Git) |
|---|---|---|
| History stored | On one central server | Full copy on every machine |
| Commit requires network | Yes | No — commit locally |
| Offline work | No | Yes |
| Branching | Slow, expensive | Instant, free |
| Merging | Difficult, conflict-prone | Fast, well-tooled |
| Server outage | Entire team blocked | Work continues locally |
| File locking | Common | Not needed |

## 1.3 Git Changed the Game

Git was created by **Linus Torvalds in 2005** — the same person who created the Linux kernel. He built it specifically to manage Linux kernel development after the previous tool (BitKeeper) became unavailable.

His requirements: fast, distributed, and able to handle thousands of developers working in parallel on millions of lines of code. Git delivered on all three.

**Why Git won:**
- Distributed model means every clone is a full backup.
- Branching is so cheap and fast that it changed how teams work — feature branches, short-lived branches, and experimental branches became normal practice.
- Open source and free — no licensing costs.
- Adopted by GitHub (2008), which made collaboration via the web mainstream.
- Now the default tool in virtually every software and DevOps team worldwide.

---

# 📗 Chapter 2 — Git Architecture and Internals

## 2.1 Git is Not a File Tracker

This is the most important thing to understand about Git, and most tutorials get it wrong or skip it entirely.

**The wrong mental model:** Git tracks the differences between file versions (like a changelog of edits).

**The correct mental model:** Git stores **snapshots** — a complete picture of all your files at a point in time. Each commit is a full snapshot of the entire project, not a delta of what changed.

```
Snapshot approach (Git):
Commit 1: [file_a_v1] [file_b_v1] [file_c_v1]
Commit 2: [file_a_v1] [file_b_v2] [file_c_v1]  ← file_b changed, others unchanged
Commit 3: [file_a_v2] [file_b_v2] [file_c_v1]  ← file_a changed
```

Where files haven't changed between commits, Git stores a pointer to the previous version rather than a duplicate. This makes it space-efficient while still being a complete snapshot at every point.

**How it works internally — content-addressed storage:**

Git uses a **key-value store**. The "key" is a **SHA-1 hash** of the content. The "value" is the content itself. This means:
- The same content always produces the same hash — Git can detect if anything changed.
- You can verify data integrity by re-hashing.
- Duplicate files across commits are stored only once (same hash = same stored object).

## 2.2 The Four Git Object Types

Everything Git stores is one of four object types, all living in `.git/objects/`:

### Blob (Binary Large Object)

- Stores the **raw content of a file** — just the bytes, no filename, no path.
- A file named `README.md` containing "Hello World" and another file named `notes.txt` containing the exact same text would produce the **same blob** (same content = same hash).

### Tree

- Stores a **directory snapshot** — filenames, file paths, and pointers to blobs (files) and other trees (subdirectories).
- A tree is the snapshot of one directory level.

### Commit

- Points to a **root tree** (the full project snapshot at this moment).
- Contains: author, committer, timestamp, commit message, and a pointer to the parent commit(s).
- Following commit → parent commit → parent's parent traces your entire history.

### Tag

- A named pointer to a specific commit.
- Usually used for marking releases: `v1.0.0`, `v2.3.1`.

```
Commit object
├── points to → Root Tree
│                ├── blob: README.md
│                ├── blob: app.py
│                └── tree: src/
│                    ├── blob: main.py
│                    └── blob: utils.py
├── author: Alice <alice@example.com>
├── timestamp: 2024-01-15 14:30:00
├── message: "Add user authentication"
└── parent: → previous commit SHA
```

## 2.3 The `.git` Directory — What's Actually Inside

When you run `git init`, Git creates a `.git` directory. This directory **is** your repository. Everything else is just a working copy. Delete `.git` and you've deleted all your history.

```bash
ls -la .git/
```

```
.git/
├── HEAD          ← which branch/commit you're currently on
├── config        ← repo-specific settings (remote URL, user config)
├── index         ← the staging area (binary file)
├── objects/      ← all commits, blobs, trees stored by SHA hash
│   ├── info/
│   └── pack/
└── refs/
    ├── heads/    ← local branches (each file = branch name, contains SHA of tip commit)
    │   ├── main
    │   └── feature/login
    └── tags/     ← tags
```

**Exploring it yourself:**

```bash
# After a commit, look at what Git stored
cat .git/HEAD
# ref: refs/heads/main

cat .git/refs/heads/main
# a1b2c3d4e5f6...  (SHA of the latest commit on main)

# Look at the object store
ls .git/objects/
# Directories named with first 2 chars of SHA, files named with remaining 38 chars

# Look at a commit object (use the first 7+ chars of any SHA from git log)
git cat-file -p a1b2c3d
# tree 4e7a...
# parent 9f2b...
# author Alice <alice@example.com> 1705325400 +0000
# committer Alice <alice@example.com> 1705325400 +0000
# Add user authentication

# Look at a tree object
git cat-file -p 4e7a...
# 100644 blob 8ab...  README.md
# 100644 blob 1cd...  app.py
# 040000 tree 5ef...  src

# Look at a blob (raw file content)
git cat-file -p 8ab...
# Hello, World  (the actual file content)
```

## 2.4 Plumbing vs Porcelain Commands

Git commands split into two categories:

**Porcelain** (what you use every day — user-friendly wrappers):
`git add`, `git commit`, `git status`, `git log`, `git push`, `git pull`, `git branch`, `git merge`

**Plumbing** (low-level internal commands Git uses internally):
`git hash-object`, `git cat-file`, `git update-index`, `git rev-parse`, `git write-tree`

You'll use porcelain commands 99% of the time. Understanding that they exist — and using `git cat-file` occasionally — gives you a much deeper understanding of what's actually happening when you commit.

## 2.5 Key Git Terminology

| Term | Definition |
|---|---|
| **Repository (repo)** | A Git-tracked project — a folder with a `.git` directory containing all history |
| **Commit** | A snapshot of your project at a point in time, with metadata (author, message, timestamp, parent) |
| **Branch** | A movable pointer to a specific commit. Creating a branch is just creating a new pointer. |
| **Remote** | A reference to an external Git host — usually named `origin` (GitHub, GitLab, etc.) |
| **HEAD** | Pointer to the commit or branch you're currently working on. Usually points to a branch, which points to a commit. |
| **Staging Area (Index)** | A buffer between your working directory and the repository. What you've `git add`ed but not yet committed. |
| **Blob** | The raw content of a file (no filename, just bytes) |
| **Tree** | A directory snapshot — filenames, paths, and pointers to blobs |
| **Ref** | Any pointer to a commit: branches, tags, HEAD |
| **Tag** | A named, permanent pointer to a specific commit — used for marking releases |
| **Object Store** | `.git/objects/` — where Git stores all blobs, trees, commits by SHA hash |
| **Working Directory** | The actual files on your disk that you're editing |
| **Origin** | The conventional name for the primary remote repository |
| **Upstream** | The original repo you forked from, or the remote branch your local branch tracks |

---

# 📙 Chapter 3 — The Three Areas of Git

This is the most important conceptual map for understanding what every Git command actually does.

## 3.1 The Three Areas

```
┌─────────────────┐   git add    ┌──────────────────┐   git commit  ┌──────────────────┐
│ Working Directory│ ──────────→ │  Staging Area    │ ───────────→ │   Repository     │
│                 │              │  (Index)         │               │   (.git/)        │
│  Files you're  │              │  Changes marked  │               │  Commit history  │
│  editing       │ ←──────────  │  for next commit │               │  (permanent)     │
└─────────────────┘  git restore └──────────────────┘               └──────────────────┘
                                                                              │
                                                     git checkout/switch  ←──┘
```

### Working Directory

The actual files on your disk. Where you edit code. Git watches this directory and detects what's changed since the last commit, but it doesn't do anything with those changes until you tell it to.

### Staging Area (Index)

A preparation zone. You explicitly add changes here with `git add`. This lets you be surgical — you might have edited 5 files, but only want to commit 3 of them. You `git add` those 3, leave the others unstaged, and commit only the staged changes.

> **Why this exists:** It lets you craft clean, logical commits even when your actual working session was messy. You can write code across multiple files in one session, then group related changes into separate, meaningful commits. Professional teams use this deliberately.

### Repository (`.git/`)

The permanent record. Once you `git commit`, the snapshot is in the repository. It's safe, versioned, and part of your history.

## 3.2 Moving Between Areas

```bash
# Working directory → Staging area
git add file.txt           # stage one file
git add .                  # stage all changes in current directory
git add src/               # stage an entire directory
git add -p                 # interactively stage chunks (powerful — lets you stage partial file changes)

# Staging area → Repository
git commit -m "Add user login endpoint"

# Staging area → Working directory (unstage, keep file changes)
git restore --staged file.txt

# Repository → Working directory (discard changes, restore file to last commit state)
git restore file.txt        # WARNING: destructive — loses your edits

# See what's in each area
git status                  # overview of all three areas
git diff                    # what changed in working dir vs staging area
git diff --staged           # what's in staging area vs last commit
```

---

# 📕 Chapter 4 — Core Git Commands

## 4.1 Setting Up Git

```bash
# The first thing to do on any machine — set your identity
# These details appear in every commit you make
git config --global user.name "Alice Smith"
git config --global user.email "alice@example.com"

# Set your default editor (for commit messages)
git config --global core.editor vim
# or: nano, code (VS Code), etc.

# Set default branch name to 'main' (modern standard)
git config --global init.defaultBranch main

# See all your config
git config --list

# See where config is stored
cat ~/.gitconfig
```

## 4.2 Starting a Repository

```bash
# Start tracking an existing project
cd my-project
git init
# Creates .git/ directory

# Clone an existing repository from GitHub
git clone https://github.com/username/repo-name.git
git clone git@github.com:username/repo-name.git  # SSH (preferred)

# Clone into a specific directory name
git clone https://github.com/username/repo.git my-local-name
```

## 4.3 The Daily Workflow

```bash
# 1. Check what's changed
git status

# 2. See the actual changes
git diff                    # unstaged changes
git diff --staged           # staged changes (what you're about to commit)

# 3. Stage changes
git add file.txt
git add .
git add -p                  # interactive — choose specific chunks to stage

# 4. Commit
git commit -m "feat: add user authentication endpoint"
git commit                  # opens editor for multi-line message

# 5. Repeat
```

## 4.4 Viewing History

```bash
# Full commit log
git log

# Compact one-line per commit
git log --oneline

# Visual graph of branches and merges
git log --oneline --graph

# The GOAT: compact + visual + all branches
git log --oneline --graph --all

# Show a specific commit (what changed, the diff)
git show a1b2c3d
git show HEAD               # the most recent commit
git show HEAD~1             # the commit before HEAD
git show HEAD~3             # three commits before HEAD

# Show who last changed each line of a file
git blame app.py

# View ALL history of HEAD movement (even deleted branches and reverted commits)
git reflog                  # your safety net — almost nothing is truly lost
```

**Reading `git log --oneline --graph --all` output:**

```
* a1b2c3d (HEAD -> main, origin/main) Merge feature/login
|\
| * 5e6f7g8 (feature/login) Add JWT token validation
| * 9h0i1j2 Add login endpoint
|/
* 3k4l5m6 Add user model
* 7n8o9p0 Initial commit
```

- `*` = a commit
- `|` and `\` = branch lines
- `(HEAD -> main)` = where you currently are
- `(origin/main)` = where GitHub's copy is

## 4.5 Working with Files

```bash
# Remove a file from both Git tracking and disk
git rm file.txt

# Remove from Git tracking but KEEP the file on disk
# (useful when you forgot to .gitignore something)
git rm --cached file.txt

# Rename or move a file
git mv old_name.txt new_name.txt

# Undo changes to a file (restore to last committed version)
git restore file.txt         # DESTRUCTIVE — loses your changes

# Discard ALL unstaged changes
git restore .

# Amend the last commit (fix message or add forgotten files)
git add forgotten_file.txt
git commit --amend -m "Corrected commit message"
# WARNING: only use on commits not yet pushed to a shared remote
```

## 4.6 Connecting to GitHub

### SSH vs HTTPS

| Method | Auth | Password prompts | Use |
|---|---|---|---|
| **SSH** | SSH key pair | Never (after setup) | Preferred — set it up once |
| **HTTPS** | Username + token | Every push/pull | OK for one-off use |

### Setting up SSH authentication

```bash
# Step 1: Generate an SSH key pair
ssh-keygen -t ed25519 -C "alice@example.com"
# Press Enter to accept defaults (or set a passphrase for extra security)
# Creates: ~/.ssh/id_ed25519 (private key) and ~/.ssh/id_ed25519.pub (public key)

# Step 2: Copy your public key
cat ~/.ssh/id_ed25519.pub
# Copies the content to clipboard on macOS:
pbcopy < ~/.ssh/id_ed25519.pub

# Step 3: Add to GitHub
# → GitHub.com → Settings → SSH and GPG keys → New SSH key → Paste → Save

# Step 4: Test the connection
ssh -T git@github.com
# Hi alice! You've successfully authenticated, but GitHub does not provide shell access.

# Step 5: Clone using SSH
git clone git@github.com:username/repo.git
```

### Pushing to GitHub for the first time

```bash
# Create a repo on GitHub first (github.com → New repository)

# Add the remote to your local repo
git remote add origin git@github.com:username/repo-name.git

# Push and set upstream tracking (-u means future 'git push' needs no arguments)
git push -u origin main

# Future pushes (once -u is set)
git push

# Pull changes from GitHub
git pull

# Fetch (download) without merging
git fetch origin

# See configured remotes
git remote -v
```

---

# 📒 Chapter 5 — Branching, Merging, and Conflict Resolution

## 5.1 What is a Branch?

A **branch** is just a movable pointer to a commit. That's all it is. When you create a new branch, Git creates a new file in `.git/refs/heads/` containing the SHA of the commit you branched from. It costs almost nothing.

```
main: ──→ commit_A ──→ commit_B ──→ commit_C  ←── (HEAD)

# git switch -c feature/login

main:          commit_A ──→ commit_B ──→ commit_C
feature/login:                                ↑
                                       (HEAD now here)

# Make commits on feature/login:
main:          commit_A ──→ commit_B ──→ commit_C
feature/login:                            commit_C ──→ commit_D ──→ commit_E
                                                                         ↑ (HEAD)
```

## 5.2 Branch Commands

```bash
# List all local branches (* = current branch)
git branch

# List all branches including remote-tracking branches
git branch -a

# List remote branches only
git branch -r

# Create a new branch (does NOT switch to it)
git branch feature/user-login

# Switch to an existing branch
git switch main
git checkout main           # older syntax, still works

# Create AND switch in one command (use this)
git switch -c feature/user-login
git checkout -b feature/user-login  # older equivalent

# Delete a branch (safe — won't delete if unmerged changes)
git branch -d feature/user-login

# Force delete (even if unmerged — be careful)
git branch -D feature/user-login

# Rename a branch
git branch -m old-name new-name

# Push a branch to GitHub
git push origin feature/user-login

# Push and set tracking (-u)
git push -u origin feature/user-login

# Delete a remote branch
git push origin --delete feature/user-login
```

## 5.3 Merging

Merging combines changes from one branch into another.

```bash
# Standard workflow: merge feature/login INTO main
git switch main                     # switch to the TARGET branch
git merge feature/user-login        # bring in the changes
```

### Fast-forward merge (the simple case)

When `main` hasn't moved since you branched off it, Git can just move the `main` pointer forward. No merge commit needed, history stays linear.

```
Before:
main:    A ──→ B ──→ C
                     ↑ feature/x was created here
feature: A ──→ B ──→ C ──→ D ──→ E

After git merge feature/x (on main):
main:    A ──→ B ──→ C ──→ D ──→ E   ← just moved the pointer forward
```

### True merge (merge commit)

When `main` has new commits since you branched, Git creates a **merge commit** that has two parents, joining the two timelines:

```
Before:
main:    A ──→ B ──→ C ──→ F
feature:             C ──→ D ──→ E

After git merge feature:
main:    A ──→ B ──→ C ──→ F ──→ M  (M is the merge commit, has parents F and E)
                     └──→ D ──→ E ──┘
```

```bash
# Force a merge commit even when fast-forward is possible
git merge --no-ff feature/user-login

# Squash all commits from feature branch into one (then commit manually)
git merge --squash feature/user-login
git commit -m "Add user login feature"
```

## 5.4 Merge Conflicts

A conflict happens when the same line(s) in the same file were changed differently on both branches, and Git can't automatically decide which to keep.

```bash
git merge feature/user-login
# CONFLICT (content): Merge conflict in app.py
# Automatic merge failed; fix conflicts and then commit the result.
```

**What a conflict looks like inside the file:**

```python
def authenticate(user):
<<<<<<< HEAD
    return check_password(user, hash_method="bcrypt")
=======
    return check_jwt_token(user)
>>>>>>> feature/user-login
```

- `<<<<<<< HEAD` — start of your current branch's version
- `=======` — divider
- `>>>>>>> feature/user-login` — the incoming branch's version

**Resolving the conflict:**

```bash
# Step 1: Open the conflicted file and edit it
# Remove the conflict markers and keep what you want:

def authenticate(user):
    return check_jwt_token(user)   # decided to use the new approach

# Step 2: Stage the resolved file
git add app.py

# Step 3: Complete the merge
git commit -m "Merge feature/user-login: use JWT authentication"

# OR: if you want to abort and undo the merge attempt
git merge --abort
```

**Tools to help:**

```bash
# See all conflicted files
git status

# Use a visual merge tool
git mergetool

# VS Code opens conflict markers visually with "Accept Current / Accept Incoming" buttons
```

---

# 📓 Chapter 6 — Rebase, Stash, and Cherry-Pick

## 6.1 Rebase vs Merge — The Big Decision

Both rebase and merge integrate changes from one branch into another. The difference is in the resulting history.

### Merge — preserves history exactly as it happened

```
main:    A ──→ B ──→ C ──→ F
                     └──→ D ──→ E
After merge:
main:    A ──→ B ──→ C ──→ F ──→ M
                     └──→ D ──→ E ──┘
```
- Creates a merge commit (M).
- History shows exactly what happened and when.
- Good for team workflows — the true history of what was merged is preserved.

### Rebase — rewrites history to be linear

```
main:    A ──→ B ──→ C ──→ F
feature:             C ──→ D ──→ E

After git rebase main (run on feature branch):
main:    A ──→ B ──→ C ──→ F
feature:                   F ──→ D' ──→ E'   (D and E are replayed as NEW commits)
```
- Replays your commits on top of the latest main — as if you had branched off today.
- No merge commit — history is linear and clean.
- D' and E' are **new commits** with new SHAs (the content is the same, but they're technically different commits).

```bash
# Rebase your feature branch on top of the latest main
git switch feature/user-login
git rebase main

# If conflicts occur during rebase:
# Fix the conflict in the file
git add fixed_file.py
git rebase --continue       # continue to next commit being replayed
# or
git rebase --abort          # give up, restore original state

# Interactive rebase — rewrite, squash, reorder, drop commits
git rebase -i HEAD~3        # interactively edit the last 3 commits
git rebase -i main          # interactively rebase everything since branching from main
```

**Interactive rebase options:**

```
pick a1b2c3d Add login endpoint       ← keep as-is
squash 5e6f7g8 Fix typo in login      ← squash INTO the previous commit
reword 9h0i1j2 Add JWT validation     ← keep but edit the message
drop 3k4l5m6 WIP broken state         ← remove this commit entirely
```

### The golden rule of rebase

> **Never rebase commits that have been pushed to a shared remote branch.** Rebase rewrites history (new SHA hashes). If others have already pulled those commits, their history and yours will diverge and cause chaos. Rebase is safe on your own local branches that haven't been pushed yet, or on feature branches that only you are working on.

### When to use which

| Scenario | Use |
|---|---|
| Merging a feature branch into `main` in a team | Merge (or squash merge via PR) |
| Cleaning up your local commits before opening a PR | Rebase or interactive rebase |
| Keeping your feature branch up to date with `main` locally | Rebase |
| Anything on a shared/public branch | Merge — never rebase |

## 6.2 Git Stash — Save Work Without Committing

`git stash` temporarily saves your uncommitted changes so you can switch context without committing half-finished work.

```bash
# You're mid-feature when an urgent bug fix is needed on main:
git stash                           # save all uncommitted changes
git switch main                     # switch to main (now clean)
# ... fix the bug, commit, push ...
git switch feature/user-login       # return to your feature
git stash pop                       # restore your saved changes

# Stash with a descriptive name
git stash push -m "WIP: login form validation"

# List all stashes
git stash list
# stash@{0}: WIP on feature/login: add validation
# stash@{1}: WIP on feature/signup: email form

# Apply a specific stash (keeps it in the stash list)
git stash apply stash@{1}

# Apply and remove from stash list
git stash pop               # pops stash@{0} (most recent)
git stash pop stash@{1}     # pop a specific stash

# Drop a stash (delete without applying)
git stash drop stash@{0}

# Clear all stashes
git stash clear

# Stash including untracked files
git stash -u

# View what's in a stash
git stash show stash@{0}
git stash show -p stash@{0}  # full diff
```

## 6.3 Reset, Revert, and Cherry-Pick — Undoing Things

### `git reset` — move the branch pointer backward

**Soft reset** — moves the branch pointer back, but leaves changes in the staging area. Good for "uncommit but keep everything staged":

```bash
git reset --soft HEAD~1
# Branch moved back 1 commit. Changes from that commit are now staged.
```

**Mixed reset (default)** — moves the branch pointer back, unstages the changes. Good for "uncommit and unstage, but keep file edits":

```bash
git reset HEAD~1            # same as git reset --mixed HEAD~1
git reset HEAD~3            # go back 3 commits
# Changes from those commits are now in your working directory (unstaged)
```

**Hard reset** — moves the branch pointer back AND discards the changes. **Destructive — data loss.**

```bash
git reset --hard HEAD~1     # DANGEROUS: discards commits AND file changes
git reset --hard origin/main  # reset to match remote — discards local commits
```

> **After a hard reset, use `git reflog` to find the lost commit SHA and recover if needed.**

### `git revert` — safe undo for shared history

Creates a **new commit** that undoes the changes of a previous commit. The original commit stays in history. Safe to use on shared/public branches.

```bash
# Undo a specific commit by creating a new "undo" commit
git revert a1b2c3d

# Revert the most recent commit
git revert HEAD

# Revert without immediately committing (stage the undo first)
git revert --no-commit a1b2c3d

# Revert a range of commits
git revert HEAD~3..HEAD
```

**Reset vs Revert — when to use which:**

| Scenario | Use |
|---|---|
| Undoing commits only on your local branch (not yet pushed) | `git reset` |
| Undoing a commit that's already been pushed to a shared branch | `git revert` |
| Production hotfix — undo a deployment | `git revert` |
| Cleaning up messy local history before pushing | `git reset --soft` then recommit |

### `git cherry-pick` — apply a specific commit from another branch

Cherry-pick takes a single commit from anywhere in the git history and applies it to your current branch.

```bash
# Apply commit a1b2c3d to the current branch
git cherry-pick a1b2c3d

# Cherry-pick multiple commits
git cherry-pick a1b2c3d 5e6f7g8

# Cherry-pick a range of commits
git cherry-pick a1b2c3d..9h0i1j2

# Cherry-pick without committing (stage the changes first)
git cherry-pick --no-commit a1b2c3d

# If there's a conflict during cherry-pick:
# Fix the conflict
git add fixed_file.py
git cherry-pick --continue
# or
git cherry-pick --abort
```

**Typical use case:** You fixed a critical bug on `main`. The fix needs to go into the `release/v2.1` branch immediately, without merging everything else from main. Cherry-pick that one fix commit onto the release branch.

## 6.4 `git amend` — Fix the Last Commit

```bash
# Fix the commit message of the last commit
git commit --amend -m "Correct commit message"

# Add a forgotten file to the last commit
git add forgotten_file.py
git commit --amend --no-edit    # --no-edit keeps the existing message

# WARNING: amend changes the commit SHA (it's a new commit)
# Only amend commits that haven't been pushed to a shared branch yet
```

---

# 📃 Chapter 7 — GitHub and Collaboration

## 7.1 Git vs GitHub — Not the Same Thing

This confuses beginners constantly.

| | Git | GitHub |
|---|---|---|
| **What it is** | Version control tool (CLI) | Git repository hosting + collaboration platform |
| **Runs where** | Locally on your machine | In the cloud (web) |
| **Purpose** | Tracks and manages code history | Share code, review PRs, manage issues, CI/CD |
| **Offline** | Yes — works fully offline | No — needs internet |
| **Who owns it** | Open source (community) | Microsoft |
| **Alternatives** | — | GitLab, Bitbucket, Gitea |

> **Key relationship:** GitHub stores a *copy* of your Git repository in the cloud. When you `git push`, you're uploading your local Git history to GitHub. When you `git pull`, you're downloading theirs. GitHub adds collaboration features (PRs, Issues, Actions) on top of that.

Other Git hosts: **GitLab** (popular in enterprise, has built-in CI/CD), **Bitbucket** (popular in Atlassian/Jira shops), **Gitea** (self-hosted, open source).

## 7.2 Forks and Pull Requests

### Fork

A **fork** is your own copy of someone else's repository on GitHub. Forking is how open source contribution works:

```
Original repo: github.com/org/project
        ↓  Fork on GitHub
Your fork:     github.com/yourname/project   (full copy on GitHub)
        ↓  git clone
Your local:    ~/project                      (full copy on your machine)
        ↓  git push (to your fork)
Your fork:     updated
        ↓  Open Pull Request
Original repo: proposes your changes for review
```

```bash
# 1. Fork on GitHub (click "Fork" button on the repo page)

# 2. Clone your fork locally
git clone git@github.com:yourname/project.git

# 3. Add the original repo as "upstream"
git remote add upstream git@github.com:org/project.git

# 4. Keep your fork up to date with the original
git fetch upstream
git switch main
git merge upstream/main

# 5. Create a branch, make changes, push to YOUR fork
git switch -c fix/broken-auth
# ... make changes ...
git push origin fix/broken-auth

# 6. Open a Pull Request on GitHub (from your fork's branch → original repo's main)
```

### Pull Request (PR)

A **Pull Request** is a proposal to merge your changes into another branch/repo. It's not a Git concept — it's a GitHub (and GitLab) feature. PRs provide:

- A visual diff showing exactly what changed.
- A code review workflow (assign reviewers, add comments, request changes, approve).
- Discussion thread on the changes.
- CI/CD integration (automated tests run on the PR before merge).
- Merge options: merge commit, squash and merge, rebase and merge.

**PR best practices:**
- Keep PRs small and focused — one feature or fix per PR.
- Write a clear description: what changed and why.
- Link to the related issue (`Fixes #42`).
- Respond to review comments promptly.
- Don't merge your own PR without at least one reviewer (on a team).

## 7.3 `.gitignore` — What Not to Track

The `.gitignore` file tells Git which files and directories to ignore entirely.

```bash
# Create at the root of your repo
touch .gitignore
```

```gitignore
# .gitignore

# Dependencies
node_modules/
vendor/
venv/
__pycache__/
*.pyc

# Build output
dist/
build/
*.o
*.exe

# Environment files — NEVER commit these
.env
.env.local
.env.production
*.env

# IDE and editor files
.vscode/
.idea/
*.swp
*.swo
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Test coverage
coverage/
.coverage
htmlcov/

# Secrets and keys — NEVER commit
*.pem
*.key
*.cert
id_rsa
id_ed25519
```

```bash
# Check if a file is being ignored
git check-ignore -v filename.txt

# See all ignored files
git status --ignored

# If you accidentally committed something that should be ignored:
git rm --cached .env              # stop tracking it (keeps file on disk)
echo ".env" >> .gitignore
git add .gitignore
git commit -m "Remove .env from tracking"
# NOTE: The .env content is still in your history. If it contained real secrets,
# you must clean it from history (git filter-repo) and rotate the secrets.
```

> **Use gitignore.io** (now toptal.com/developers/gitignore) — type your tech stack and it generates a comprehensive `.gitignore` for you.

---

# 🖥️ Chapter 8 — Professional Git Workflows

## 8.1 GitHub Flow — Simple and Modern

The workflow most teams use. Well-suited to continuous deployment.

```
main (always deployable)
 └── feature/user-login
 └── fix/auth-bug
 └── feature/payment-api
```

**The steps:**

1. `git switch -c feature/your-feature` — branch off `main`
2. Make commits on your branch, push regularly: `git push origin feature/your-feature`
3. Open a Pull Request to `main`
4. Team reviews, CI/CD runs tests automatically on the PR
5. Approve → squash and merge into `main`
6. Delete the feature branch
7. `main` is immediately deployable (often auto-deployed by CI/CD)

```bash
# Full GitHub Flow cycle:
git switch main
git pull                                    # get latest main
git switch -c feature/add-payment-api       # new branch
# ... work work work ...
git add .
git commit -m "feat: add Stripe payment endpoint"
git push -u origin feature/add-payment-api  # push, open PR on GitHub
# ... review, approve, merge on GitHub ...
git switch main
git pull                                    # pull the merged changes
git branch -d feature/add-payment-api      # clean up local branch
```

## 8.2 Git Flow — Release-Driven

Used by teams with scheduled releases, long QA cycles, or enterprise environments.

```
main          ← production-ready releases only, tagged (v1.0, v1.1...)
develop       ← integration branch, always has latest finished features
feature/x     ← individual features, branch off develop
release/1.1   ← release preparation (bug fixes only), branch off develop
hotfix/1.0.1  ← urgent production fix, branches off main
```

**Flow for a feature:**
1. Branch `feature/x` from `develop`
2. Develop, test
3. Merge `feature/x` → `develop` via PR
4. When enough features are ready: branch `release/1.1` from `develop`
5. QA, bug fixes go onto the release branch
6. Merge `release/1.1` → `main` (tag it `v1.1`) AND back into `develop`

**Flow for a hotfix:**
1. Branch `hotfix/1.0.1` from `main`
2. Fix the bug
3. Merge into both `main` (tag `v1.0.1`) AND `develop`

**Verdict:** Git Flow is powerful but heavyweight. For most DevOps teams practising CI/CD, GitHub Flow or trunk-based development is faster and simpler.

## 8.3 Trunk-Based Development

All developers commit frequently to `main` (the "trunk") or use very short-lived branches (hours, not days).

```
main ──→ commit ──→ commit ──→ commit ──→ commit ──→ (deployed continuously)
```

- Used by Google, Facebook, Netflix, and high-velocity tech teams.
- **Requires** strong CI/CD pipelines that test every commit automatically.
- **Feature flags** manage incomplete features — code is merged but hidden behind a toggle.
- Forces small, frequent commits that keep the team in sync constantly.
- Merge conflicts are rare because no one diverges far from main.

```bash
# Trunk-based daily workflow:
git switch main
git pull                              # always start from latest main
# Make a small, focused change
git add .
git commit -m "refactor: extract auth middleware"
git push                              # CI runs tests automatically
# If tests pass: deployed. If they fail: fix immediately.
```

## 8.4 Commit Hygiene — Writing Good Commits

A commit message is a communication to your future self and your teammates. Make it count.

### The Conventional Commits format

Used by most professional teams. Enables automated changelogs and semantic versioning.

```
type(scope): short description

Longer explanation if needed. Explain WHY, not WHAT
(the diff already shows what changed).

Fixes #123
```

**Types:**

| Type | When to use |
|---|---|
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation changes |
| `style` | Formatting, whitespace (no logic changes) |
| `refactor` | Code restructuring (no feature or bug change) |
| `test` | Adding or fixing tests |
| `chore` | Build process, dependency updates |
| `ci` | CI/CD pipeline changes |
| `perf` | Performance improvements |
| `revert` | Reverting a previous commit |

**Good commit messages:**

```
feat(auth): add JWT token refresh endpoint

Implements automatic token refresh to prevent session expiry.
The new /auth/refresh endpoint accepts a valid refresh token
and returns a new access token with a 1-hour TTL.

Closes #47
```

```
fix(database): handle connection timeout in pool

Previously, database connection timeouts caused an unhandled
exception that crashed the worker. Now handles TimeoutError
and returns a 503 with a Retry-After header.
```

**Bad commit messages:**

```
fix stuff
update
asdfgh
wip
final
FINAL v2
```

### One logical change per commit

```bash
# BAD: everything in one commit
git commit -m "Add login, fix bugs, update README, refactor database"

# GOOD: separate logical commits
git commit -m "feat(auth): add login endpoint"
git commit -m "fix(db): correct connection pool timeout"
git commit -m "docs: update README with API examples"
git commit -m "refactor(db): extract connection helper"
```

### Squashing before merging

```bash
# Before opening a PR, squash your "WIP" commits into clean ones
git rebase -i main

# In the editor:
pick a1b2c3d feat: add login form
squash 5e6f7g8 wip
squash 9h0i1j2 fix typo
squash 3k4l5m6 fix another typo
# → These 4 commits become 1 clean commit
```

---

# 📋 Chapter 9 — Pre-Commit Hooks and Automation

## 9.1 Git Hooks

Git hooks are scripts that run automatically at specific points in the Git workflow. They live in `.git/hooks/`.

```bash
ls .git/hooks/
# applypatch-msg  pre-commit  pre-push  commit-msg  post-merge  ...
```

**Useful hooks:**

| Hook | When it runs | Common use |
|---|---|---|
| `pre-commit` | Before a commit is created | Run linters, formatters, tests |
| `commit-msg` | After commit message is written | Validate message format |
| `pre-push` | Before a push to remote | Run tests, prevent bad pushes |
| `post-merge` | After a successful merge | Install dependencies |

### Writing a simple pre-commit hook

```bash
# .git/hooks/pre-commit
#!/bin/bash
echo "Running pre-commit checks..."

# Run Python linter
if ! pylint src/; then
    echo "Linting failed. Commit aborted."
    exit 1
fi

# Run tests
if ! python -m pytest; then
    echo "Tests failed. Commit aborted."
    exit 1
fi

echo "All checks passed."
exit 0
```

```bash
chmod +x .git/hooks/pre-commit
```

**Problem:** `.git/hooks/` is not version controlled — team members don't share your hooks automatically.

## 9.2 `pre-commit` — The Professional Solution

The `pre-commit` framework manages hooks as a config file that IS version controlled and shared with the team.

```bash
# Install
pip install pre-commit

# or
brew install pre-commit
```

```yaml
# .pre-commit-config.yaml (in repo root — commit this!)
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace      # remove trailing whitespace
      - id: end-of-file-fixer        # ensure files end with a newline
      - id: check-yaml               # validate YAML syntax
      - id: check-json               # validate JSON syntax
      - id: check-merge-conflict     # detect leftover merge conflict markers
      - id: detect-private-key       # prevent committing private keys
      - id: no-commit-to-branch      # prevent direct commits to main
        args: ['--branch', 'main']

  - repo: https://github.com/psf/black
    rev: 23.12.1
    hooks:
      - id: black                    # Python code formatter

  - repo: https://github.com/pycqa/flake8
    rev: 7.0.0
    hooks:
      - id: flake8                   # Python linter

  - repo: https://github.com/hadolint/hadolint
    rev: v2.12.0
    hooks:
      - id: hadolint-docker          # Dockerfile linter
```

```bash
# Install the hooks into .git/hooks/
pre-commit install

# Now pre-commit runs automatically on every git commit

# Run manually against all files
pre-commit run --all-files

# Update all hooks to latest versions
pre-commit autoupdate
```

---

# 🔒 Chapter 10 — Security and Secrets Hygiene

## 10.1 The Cardinal Rule

**Never commit secrets to a Git repository.** Not even private repositories. Never.

Secrets include: passwords, API keys, AWS credentials, private SSH keys, database URLs with credentials, JWT signing keys, OAuth tokens.

**Why never:**
- Git history is permanent — even after you delete the file, the secret is in history.
- Private repos get shared, forked, or accidentally made public.
- GitHub scans public repos for secrets and notifies service providers (AWS, etc.) who immediately invalidate the key — but not before attackers scrape it.
- Leaked AWS keys are found and used within minutes. Bills of thousands of pounds arrive within hours.

## 10.2 Prevention — Stop Secrets Entering the Repo

```bash
# Add to .gitignore BEFORE you create the files
.env
*.env
.env.*
config/secrets.yaml
credentials.json
*.pem
*.key
id_rsa
id_ed25519
terraform.tfvars    # often contains cloud credentials
```

**Use `pre-commit` hooks with secret detection:**

```yaml
# .pre-commit-config.yaml
- repo: https://github.com/Yelp/detect-secrets
  rev: v1.4.0
  hooks:
    - id: detect-secrets

- repo: https://github.com/awslabs/git-secrets
  rev: v1.3.0
  hooks:
    - id: git-secrets
```

**Store secrets properly instead:**

```bash
# Environment variables (injected at runtime, not in code)
export DB_PASSWORD="secret"
./app                       # app reads from $DB_PASSWORD

# .env file (loaded by the app, NEVER committed)
echo "DB_PASSWORD=secret" >> .env
echo ".env" >> .gitignore

# AWS credentials (stored in ~/.aws/credentials, not in code)
aws configure

# For production: use a secrets manager
# AWS Secrets Manager, HashiCorp Vault, GitHub Actions Secrets
```

## 10.3 If You Accidentally Commit a Secret

Act immediately. The longer it's exposed, the greater the risk.

```bash
# Step 1: IMMEDIATELY rotate/invalidate the secret
# Change the password, revoke the API key, generate new credentials
# Do this BEFORE anything else

# Step 2: Remove from current working tree
git rm --cached .env
echo ".env" >> .gitignore
git add .gitignore
git commit -m "Remove accidentally committed .env file"
git push

# Step 3: Scrub from Git history (the file is still in old commits)
# Install git-filter-repo (pip install git-filter-repo)
git filter-repo --path .env --invert-paths

# Or remove a specific string from all files in history:
git filter-repo --replace-text replacements.txt
# replacements.txt: LITERAL:old_secret==>REDACTED

# Step 4: Force push to all remotes (coordinate with team)
git push --force origin main

# Step 5: All team members must re-clone the repo
# Their local copies still have the old history
```

> **After a secret leak, invalidating and rotating is more important than removing from history.** Even if you remove it from history perfectly, someone may have scraped it in the window it was exposed. Always assume it's compromised.

## 10.4 Tools for Scanning

```bash
# trufflehog — scans for secrets in Git history
pip install trufflehog
trufflehog git file://. --since-commit HEAD --only-verified

# git-secrets — prevents committing AWS credentials and patterns
brew install git-secrets
git secrets --install
git secrets --register-aws

# GitGuardian — monitors public GitHub for your secrets (free tier)
# github.com/gitguardian
```

---

# 🌳 Chapter 11 — Common Mistakes and Git at Scale

## 11.1 The Most Dangerous Git Mistakes in the Real World

### Mistake 1: `git push --force` on a shared branch

```bash
# NEVER do this on main or any shared branch
git push --force origin main    # overwrites everyone else's history

# SAFE alternative if you truly need to force push (e.g. after a rebase on YOUR branch)
git push --force-with-lease origin feature/my-branch
# --force-with-lease fails if someone else pushed since you last pulled
# Prevents overwriting others' work
```

### Mistake 2: Committing secrets

Covered in Chapter 10. Use `.gitignore` and `pre-commit` hooks. Always.

### Mistake 3: Forgetting to pull before pushing

```bash
# Results in: "rejected — non-fast-forward"
git push
# error: failed to push some refs to 'origin/main'
# hint: Updates were rejected because the remote contains work you don't have locally.

# Fix:
git pull --rebase           # fetch remote commits, replay yours on top
# or
git pull                    # fetch and merge
git push
```

### Mistake 4: Working directly on `main`

```bash
# Never commit directly to main in a team setting
# Always branch:
git switch -c fix/urgent-auth-bug
# ... make fix ...
git push -u origin fix/urgent-auth-bug
# Open PR for review, even for urgent fixes
```

### Mistake 5: Messy, meaningless commit history

```bash
# Before opening a PR, clean up your commits:
git rebase -i main

# Use interactive rebase to:
# - Squash "wip" and "fix typo" commits
# - Rewrite commit messages
# - Remove commits that added then reverted changes
```

### Mistake 6: Not using `.gitignore` properly

```bash
# Generate a good .gitignore:
# Visit toptal.com/developers/gitignore
# Select your tech stack (Python, Node, macOS, VS Code, etc.)
# Copy the output to .gitignore

# Or use the gh CLI:
gh repo create --gitignore Python
```

### Mistake 7: Merging without code review

Every PR should have at least one reviewer. Enable branch protection rules on GitHub:

```
Repository Settings → Branches → Add rule:
☑ Require a pull request before merging
☑ Require approvals: 1
☑ Require status checks to pass before merging
☑ Do not allow bypassing the above settings
```

## 11.2 Git at Scale

### Monorepo strategies

A monorepo is one repository containing multiple projects (e.g. all microservices in one repo).

**Tools:** `nx`, `Turborepo`, `Bazel` — these understand which parts of the monorepo changed and only rebuild/test what's affected.

**Sparse checkout** — check out only the subdirectory you need, not the entire monorepo:

```bash
git clone --no-checkout git@github.com:org/monorepo.git
cd monorepo
git sparse-checkout init --cone
git sparse-checkout set services/auth-service
git checkout main
```

### Git LFS (Large File Storage)

Git performs poorly with large binary files (images, videos, ML models, datasets). Git LFS replaces large files with a pointer in Git and stores the actual content on a separate server.

```bash
# Install Git LFS
git lfs install

# Track large file types
git lfs track "*.psd"
git lfs track "*.mp4"
git lfs track "models/*.bin"

# .gitattributes is created — commit it
git add .gitattributes
git commit -m "chore: configure Git LFS for large files"

# Now these files are stored in LFS automatically
```

### Submodules and Subtrees

For including one repository inside another:

```bash
# Submodule — separate repo linked by reference
git submodule add git@github.com:org/shared-lib.git libs/shared
git submodule update --init --recursive  # when cloning a repo with submodules

# Subtree — copy of another repo merged into yours (simpler to use)
git subtree add --prefix libs/shared git@github.com:org/shared-lib.git main --squash
```

---

# 🎯 Chapter 12 — Quick Reference Cheat Sheet

## Setup

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --list
```

## Starting out

```bash
git init                          # start a new repo
git clone git@github.com:u/r.git  # clone existing repo
git remote -v                     # show remotes
git remote add origin <url>       # add remote
```

## Daily workflow

```bash
git status                        # what's changed?
git diff                          # unstaged changes
git diff --staged                 # staged changes
git add file.txt                  # stage one file
git add .                         # stage all changes
git add -p                        # stage interactively (chunks)
git commit -m "type: message"     # commit staged changes
git push                          # push to remote
git pull                          # fetch + merge from remote
git pull --rebase                 # fetch + rebase
git fetch                         # download without merging
```

## History

```bash
git log --oneline --graph --all   # the GOAT view
git show HEAD                     # last commit details
git blame file.py                 # who changed each line
git reflog                        # safety net — full HEAD history
git diff main..feature            # diff between branches
```

## Branches

```bash
git branch                        # list local branches
git branch -a                     # all branches incl. remote
git switch -c feature/name        # create and switch
git switch main                   # switch branch
git branch -d feature/name        # delete (safe)
git branch -D feature/name        # force delete
git push -u origin feature/name   # push branch
git push origin --delete feature  # delete remote branch
```

## Merging and rebasing

```bash
git merge feature/name            # merge into current branch
git merge --no-ff feature/name    # always create merge commit
git merge --squash feature/name   # squash all commits into one
git rebase main                   # rebase onto main
git rebase -i HEAD~3              # interactive rebase (last 3 commits)
git rebase -i main                # interactive rebase from main
git merge --abort                 # cancel a merge
git rebase --abort                # cancel a rebase
```

## Undoing

```bash
git restore file.txt              # discard working dir changes (destructive)
git restore --staged file.txt     # unstage
git commit --amend                # fix last commit (before pushing)
git revert HEAD                   # safe undo — creates new commit
git reset --soft HEAD~1           # uncommit, keep staged
git reset HEAD~1                  # uncommit, keep unstaged
git reset --hard HEAD~1           # DESTRUCTIVE — discard commits
git reflog                        # find lost commits after reset
```

## Stash

```bash
git stash                         # save uncommitted changes
git stash push -m "description"   # stash with name
git stash list                    # view all stashes
git stash pop                     # apply and remove latest
git stash apply stash@{1}         # apply specific stash
git stash drop stash@{0}          # delete a stash
```

## Cherry-pick

```bash
git cherry-pick a1b2c3d           # apply one commit
git cherry-pick a1b..9h0          # range of commits
git cherry-pick --abort           # cancel
```

## Tags

```bash
git tag v1.0.0                    # lightweight tag
git tag -a v1.0.0 -m "Release"    # annotated tag
git push origin v1.0.0            # push tag
git push origin --tags            # push all tags
git tag -d v1.0.0                 # delete local tag
git push origin --delete v1.0.0   # delete remote tag
```

## Cleanup

```bash
git clean -fd                     # remove untracked files and dirs
git branch --merged | grep -v main | xargs git branch -d  # delete merged branches
```

## SSH key setup

```bash
ssh-keygen -t ed25519 -C "you@example.com"
cat ~/.ssh/id_ed25519.pub         # copy this to GitHub
ssh -T git@github.com             # test connection
```

---

# 📌 Appendix — Being Hireable: What You Must Know Cold

Git is tested in every DevOps, Platform Engineer, and SRE interview. These are the things you must be able to do or explain without hesitation:

1. **Explain what Git is and why it matters** — distributed VCS, full history on every machine, offline commits, fast branching. Contrast with centralised (SVN).

2. **Explain the three areas** — working directory, staging area, repository. What `git add` and `git commit` do to move changes between them. Why the staging area exists.

3. **The daily workflow without looking it up** — `status`, `diff`, `add`, `commit`, `push`, `pull`. Do this fluently.

4. **Read `git log --oneline --graph --all`** — understand what you're looking at. Identify merge commits, branches, HEAD position.

5. **Branch creation and switching** — `git switch -c feature/name`. Why you always branch from the latest `main`. How to delete a branch after merging.

6. **Explain merge vs rebase** — merge preserves history, creates a merge commit. Rebase rewrites history, creates a linear timeline. When to use each. The golden rule: never rebase shared history.

7. **Resolve a merge conflict** — open the file, understand the conflict markers, edit to resolve, `git add`, `git commit`. Do this under pressure in an interview setting.

8. **Explain `git reset` modes** — soft, mixed, hard. Which are destructive. When to use `git revert` instead (shared branches).

9. **`git stash`** — when and why. `push`, `list`, `pop`, `apply`.

10. **`git cherry-pick`** — apply one commit from another branch. The hotfix use case.

11. **SSH key setup** — generate with `ed25519`, add public key to GitHub, test with `ssh -T`. Know why SSH is preferred over HTTPS.

12. **Write a good commit message** — conventional commits format (`feat:`, `fix:`, `docs:`). One logical change per commit. Why good messages matter.

13. **Explain GitHub Flow** — branch off main, commit, push, open PR, review, merge, deploy. This is the workflow most companies use.

14. **Secrets hygiene** — never commit `.env` or credentials. `.gitignore` them before creating them. What to do if you accidentally commit a secret (rotate immediately, `git filter-repo`).

15. **`pre-commit` hooks** — what they are, why they exist, how to install the `pre-commit` framework, what checks they enforce (linting, secret detection, formatting).

16. **`git reflog`** — the safety net. If you `reset --hard` and lose work, `reflog` shows every position HEAD has been — you can recover almost anything.

17. **Explain what `.git/` contains** — HEAD, objects/, refs/, index. Understand that deleting `.git/` deletes all history.

18. **GitOps concept** — Git as the single source of truth for infrastructure. Changes to infrastructure are made via PRs, not manual console clicks. Tools like ArgoCD and Flux watch a Git repo and apply changes to Kubernetes automatically. This is directly relevant to the Optum SRE role.
