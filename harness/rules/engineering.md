# Engineering Workflow Rules

## Simplicity

- Prefer existing structure, derived state, and inline logic before introducing new utilities.
- Add a helper or abstraction only when there is real reuse, meaningful complexity reduction, or an established local pattern.
- When adding a new abstraction, identify its callers and why the logic should not stay local.

## Feature Work

- New features should extend and preserve existing infrastructure behavior.
- Do not delete existing foundation logic to make a new feature path easier unless the migration path and tests prove it is safe.
- Before changing a shared entrypoint, identify current callers, compatibility expectations, and regression checks.

## Harness Mindset

- For bug fixes, prefer a reproducing test or harness case before changing behavior.
- For feature work touching shared infrastructure, add characterization coverage for existing behavior before extending it.
- Use harnesses to prevent behavior regressions; use rules to prevent style and judgment regressions.

## Shipping Safety

- Treat registry pushes, deployment changes, stable tag overwrites, and shared-environment mutations as external state changes.
- Show a plan before external state changes, and verify the resulting state afterwards.
- Do not store or print credentials, kubeconfigs, registry passwords, tokens, or cloud secrets.

