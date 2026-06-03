---
name: git-ship
description: 'Commit and push session-scoped git changes with Conventional Commit message analysis, safe staging, logical change grouping, verification, and push safety gates. Use when the user asks to 提交并推送, 发代码, 提交代码并 push, commit and push, git ship, push my changes, or run the full git add/commit/push SOP. Supports avoiding unrelated dirty worktree changes, generating clean commit messages, checking branch/upstream/remote state, and pushing only after verification.'
license: MIT
allowed-tools: Bash
---

# Git Ship with Conventional Commits

Create standardized, semantic git commits using the Conventional Commits specification. Analyze the actual diff to determine appropriate type, scope, and message.
Create clean Conventional Commits for session-scoped changes, then push them safely after checking branch, upstream, remote, and worktree state.

## Conventional Commit Format

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Commit Types

| Type       | Purpose                        |
| ---------- | ------------------------------ |
| `feat`     | New feature                    |
| `fix`      | Bug fix                        |
| `docs`     | Documentation only             |
| `style`    | Formatting/style (no logic)    |
| `refactor` | Code refactor (no feature/fix) |
| `perf`     | Performance improvement        |
| `test`     | Add/update tests               |
| `build`    | Build system/dependencies      |
| `ci`       | CI/config changes              |
| `chore`    | Maintenance/misc               |
| `revert`   | Revert commit                  |

## Breaking Changes

```text
# Exclamation mark after type/scope
feat!: remove deprecated endpoint

# BREAKING CHANGE footer
feat: allow config to extend other configs

BREAKING CHANGE: `extends` key behavior changed
```

## Workflow

### 1. Analyze Diff

```bash
# If files are staged, use staged diff
git diff --staged

# If nothing staged, use working tree diff
git diff

# Also check status
git status --porcelain
```

### 2. Establish Session Scope

In a shared or already-dirty worktree, interpret a request like "commit code", "提交代码", or `/commit` as "commit the changes attributable to this conversation/session". Do not stage or commit unrelated work from other sessions just because it is present in the current git worktree.

Before grouping commits, identify the session-scoped candidate set:

- Include files and hunks edited by the current session.
- Include files the user explicitly asked this session to change.
- Include generated files, lockfiles, migrations, snapshots, or docs that were produced by commands in this session and belong to the same change.
- Include pre-existing staged changes only if they clearly belong to this session or the user explicitly says to keep them.
- Exclude dirty files, untracked files, and staged changes that were not touched or requested in this session, unless the user explicitly asks to commit the whole worktree.

Use status and diff inspection to separate ownership:

```bash
git status --short
git diff --name-status
git diff --staged --name-status
git ls-files --others --exclude-standard
```

When the worktree contains out-of-scope changes, leave them unstaged and mention them in the final response as intentionally not committed. If a file contains both in-scope and out-of-scope hunks, use precise staging such as `git add -p`, `git apply --cached`, or an equivalent patch-based method. If hunk ownership is still ambiguous after inspection and committing could capture another session's work, ask the user for confirmation instead of broad-staging.

Only commit the entire dirty worktree when the user explicitly says so, for example "commit all changes", "提交整个工作区", "把所有改动都提交", or after the user confirms the broader scope.

### 3. Split Into Logical Commit Groups

Default to creating multiple commits when the diff contains multiple independent features, fixes, refactors, docs changes, tests, config changes, or generated artifacts. A user request such as "commit code", "提交代码", or `/commit` means "commit all appropriate changes as clean logical commits", not "force everything into one commit".

Before staging, inspect the session-scoped candidate set, then decide commit groups by behavior and ownership:

- Keep one logical change per commit.
- Separate unrelated features, fixes, refactors, docs, tests, build/CI, and formatting-only changes.
- Keep tests with the code they verify when they belong to the same behavioral change.
- Keep generated lockfiles, migrations, schema snapshots, and build metadata with the source/config change that produced them.
- Do not split files mechanically when a single file contains one coherent change.
- If unrelated changes are mixed inside one file, prefer `git add -p` or another precise staging method.
- If the safe grouping is unclear, inspect more context and make the smallest defensible grouping; ask only when committing risks including user work, secrets, or an unintended change.
- Use a single commit only when the whole diff is genuinely one logical change or the user explicitly asks for one commit.

### 4. Stage Files

If nothing is staged or you want to group changes differently:

```bash
# Stage specific files
git add path/to/file1 path/to/file2

# Stage by pattern
git add '*.test.*'
git add src/components/*

# Interactive staging
git add -p
```

Never commit secrets such as `.env`, `credentials.json`, private keys, tokens, or local credentials.

### 5. Generate Commit Message

Analyze the diff to determine:

- **Type**: What kind of change is this?
- **Scope**: What area/module is affected?
- **Description**: One-line summary of what changed, in present tense and imperative mood, ideally under 72 characters.

### 6. Execute Commit

```bash
# Single line
git commit -m "<type>[scope]: <description>"

# Multi-line with body/footer
git commit -m "$(cat <<'EOF'
<type>[scope]: <description>

<optional body>

<optional footer>
EOF
)"
```

### 7. Push Safety Gate

After every commit and before pushing, re-check:

```bash
git status --short --branch
git rev-parse HEAD
git branch --show-current
git remote -v
git status -sb
```

If the branch has no upstream, use:

```bash
git push -u origin <branch>
```

If the branch has an upstream, use:

```bash
git push
```

If the branch is behind the upstream, stop and report that a pull/rebase decision is needed. Do not auto-merge or auto-rebase unless the user explicitly asks.

## Best Practices

- Default to committing only the current session's attributable changes in dirty shared worktrees.
- Default to multiple decoupled commits when multiple logical changes are present.
- Present tense: "add" not "added".
- Imperative mood: "fix bug" not "fixes bug".
- Reference issues when relevant, such as `Closes #123` or `Refs #456`.
- Keep the description concise, ideally under 72 characters.

## Git Safety Protocol

- Never update git config.
- Never run destructive commands such as `--force` or hard reset without explicit request.
- Never skip hooks with `--no-verify` unless the user asks.
- Never force-push to `main` or `master`.
- If commit fails due to hooks, fix the issue and create a new commit instead of amending by default.
- Never push with `--force` or `--force-with-lease` unless explicitly requested in the current turn.
- Never push to `main` or `master` unless the user explicitly asks and the branch state has been verified.
- Never push if `git status -sb` shows the branch is behind upstream; ask whether to rebase, merge, or stop.
- Never push if HEAD changed between commit and push checks.
- If push fails due to auth, permissions, protected branch rules, or remote rejection, report the exact blocker and stop.