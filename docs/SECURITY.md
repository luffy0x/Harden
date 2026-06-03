# Security Notes

This repository is intended for source-controlled agent configuration, not for runtime state.

## Excluded Local State

Do not commit:

- `~/.codex/auth.json`
- `~/.codex/config.toml` when it contains local credentials, MCP secrets, or account state
- SQLite databases, logs, session JSONL files, shell snapshots, browser sessions, caches, or app state
- kubeconfigs under `~/.kube`
- SSH, GPG, cloud, GitHub CLI, or browser credentials
- raw conversation exports that may contain secrets, private project context, or user data

## Public-Surface Rules

- Skills should describe reusable behavior, not one-off local paths or private operational details.
- Test credentials and cluster addresses must be placeholders or runtime parameters.
- Automation prompts may reference `~/.codex` but should avoid absolute user-specific paths.
- Any generated reports should be reviewed before publishing because they summarize recent conversations and memories.

## Pre-Push Check

Run this before pushing:

```bash
rg -n -i --hidden --glob '!**/.git/**' \
  '(api[_-]?key|secret|token|password|passwd|private[_ -]?key|BEGIN [A-Z ]*PRIVATE KEY|cookie|authorization|bearer|github_pat|ghp_|sk-[A-Za-z0-9]|client-key-data|client-certificate-data|/Users/|192\.168\.)' .
```

Some matches are expected in safety rules and scanner code. Investigate every hit that looks like a real value rather than a warning, placeholder, or pattern.
