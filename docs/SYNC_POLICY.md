# Sync Policy

Use this repository as the durable source for reusable agent behavior.

## Include

- User-authored skills and supporting references, scripts, assets, and agent prompts.
- Global AGENTS entrypoints and rule modules that are reusable across projects.
- Automation definitions whose prompts and schedules are safe to share.
- Inventory and security documentation that helps future review.

## Exclude

- Codex bundled `.system` skills.
- Raw conversation logs, summaries with private context, memories, SQLite databases, browser state, caches, and app state.
- Runtime credentials, tokens, passwords, cookies, kubeconfigs, private keys, or account files.
- One-off temporary paths, machine-specific workspace paths, or internal cluster addresses.
- Generated weekly review reports unless they have been manually reviewed and redacted.

## Update Workflow

1. Copy only durable user-authored assets into the repo.
2. Replace local absolute paths, internal endpoints, and runtime credentials with placeholders.
3. Run syntax checks for scripts and structured files.
4. Run the secret scan from `docs/SECURITY.md`.
5. Commit with a conventional message and push.
