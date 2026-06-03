# Inventory

Generated snapshot date: 2026-06-03.

## Harness

- `harness/AGENTS.md`: global Codex instruction entrypoint.
- `harness/rules/base.md`: engineering communication, working style, testing, git, dependency, reliability, and documentation rules.
- `harness/rules/frontend.md`: frontend architecture, state/UI separation, styling, and token safety rules.
- `harness/rules/internship.md`: internship-period database, deployment, image, and external-reference safety rules.
- `harness/rules/security.md`: secret handling and sensitive-data safety rules.

## Automations

- `automations/agent-harness/automation.toml`: weekly Friday 15:00 Asia/Shanghai Agent/Skill/Harness review automation. It generates Markdown and Excel reports under `~/.codex/WeeklyReview/<YYYY>/` and does not directly modify skills or harness rules.

## User Skills

- `check`: code review, PR/release/push readiness, issue/PR triage, and project-quality audit workflows.
- `codex-goal-builder`: turns rough long-running objectives into decision-complete Codex Goals.
- `codex-runner-creator`: creates or repairs Codex local environment action files.
- `design`: production-grade UI and screenshot-driven visual polish.
- `git-commit`: conventional commit workflow for session-scoped changes.
- `git-ship`: conventional commit plus safe push workflow.
- `health`: agent configuration, instruction drift, verifier, and maintainability health audit.
- `hunt`: root-cause debugging for errors, regressions, crashes, and failing tests.
- `issue-creator`: GitHub issue drafting/creation workflow for QA and product testing.
- `learn`: research workflow for unfamiliar domains and source bundles.
- `logseq-writer`: practical Logseq-style tutorial writing.
- `read`: URL and PDF reading/fetching workflow.
- `rules`: shared writing/routing rules used by skills.
- `screenshot-interaction`: screenshot-to-interaction and UI behavior inference.
- `test-cluster-setup`: Sealos test-cluster setup workflow with runtime-provided credentials.
- `think`: decision-complete planning for features, architecture, and value judgments.
- `workflow-packager`: identifies repeated agent workflows worth turning into skills, subagents, or automations.
- `write`: Chinese/English prose rewrite and polish workflow.

## System Skills Excluded

Codex bundled `.system` skills are not copied here because they are installed by Codex itself and should not be versioned as personal harness content.

## Local State Excluded

The following were intentionally excluded: auth files, `config.toml`, SQLite databases, logs, raw sessions, app state, browser state, shell snapshots, caches, generated weekly reports, kubeconfigs, private keys, and local machine absolute paths.
