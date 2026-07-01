# Harden

Personal Codex agent harness, skills, automations, and durable working rules.

This repository is a portable, sanitized snapshot of the local Codex setup. It is meant to make the agent system auditable and recoverable across machines without publishing local runtime state, credentials, conversation logs, caches, databases, or machine-specific secrets.

## Contents

- `skills/`: user-level Codex skills and their supporting agents, references, scripts, and assets.
- `harness/AGENTS.md`: the global Codex instruction entrypoint.
- `harness/rules/`: reusable rule modules merged by `harness/AGENTS.md`.
- `harness/ship/`: sample harness case for validating shipping behavior.
- `automations/`: Codex automation definitions that are safe to version.
- `docs/`: inventory, security notes, and maintenance guidance.
- `scripts/`: helper scripts for installing this harness into a local Codex home.

## Install

Review the files first, then run:

```bash
./scripts/install.sh
```

By default this installs into `${CODEX_HOME:-$HOME/.codex}`. To preview without writing:

```bash
./scripts/install.sh --dry-run
```

To install into another directory:

```bash
CODEX_HOME=/path/to/codex-home ./scripts/install.sh
```

## What Is Intentionally Not Included

The repo does not include local Codex auth files, app state, browser sessions, raw conversation logs, memory databases, shell snapshots, process state, generated weekly reports, kubeconfigs, private keys, or cache directories.

Runtime-only values such as passwords, tokens, cluster endpoints, and local worktree paths must stay outside the repo and be provided through the current environment or user prompt.
