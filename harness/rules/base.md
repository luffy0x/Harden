# Base Engineering Principles

## Communication

- Respond in Chinese by default unless the user explicitly asks for English.
- Be direct, clear, and engineering-oriented.
- Avoid over-explaining common engineering concepts.
- Do not invent APIs, commands, configuration options, file paths, or version-specific behavior.
- When uncertain, state the uncertainty clearly.
- If requirements are incomplete, make reasonable assumptions and continue. Ask a question only when proceeding may cause obvious mistakes, destructive changes, or production risk.
- When proposing or making code changes, explain what changed and why.

## Working Style

- Prefer minimal necessary changes.
- Avoid unrelated refactoring.
- Do not change behavior just to make code look cleaner.
- Understand the existing style before editing, then stay consistent with it.
- Reuse existing project utilities, functions, types, configurations, and engineering patterns.
- Do not introduce new dependencies unless the benefit is clear and the user agrees.
- Do not casually change public APIs, data structures, database schemas, configuration formats, or deployment workflows.
- Do not delete code, files, tests, or documentation unless explicitly requested or the reason has been explained.

## Code Quality

- Write code that is readable, maintainable, and has clear boundaries.
- Prefer simple implementations over over-engineered abstractions.
- Preserve useful error context; do not silently swallow exceptions.
- Be careful with inputs, null values, empty states, edge cases, and failure paths.
- Avoid hard-coded magic values; extract constants or configuration when appropriate.
- Do not add comments that merely restate the code. Comments should explain why something exists.

## Testing and Verification

- After changing code, run relevant tests, type checks, or lint checks when possible.
- Prefer the smallest relevant test set instead of running unnecessarily heavy full test suites.
- If tests cannot be run, explain why and provide the commands the user should run.
- Do not claim that tests passed unless they were actually run.
- For bug fixes, explain the root cause and the verification method when possible.
- For important logic changes, prefer adding or updating tests.

## Git and Repository Safety

- Do not create git commits unless explicitly requested.
- Do not push, rebase, run `reset --hard`, run `git clean`, delete branches, or rewrite history unless explicitly requested.
- Before editing, be aware of existing user changes in the working tree.
- Do not overwrite uncommitted user changes.
- If unrelated files are already modified, do not touch them unless necessary. Mention them to the user instead.

## Dependencies

- Prefer existing project dependencies.
- Before adding a dependency, explain the reason, alternatives, and impact.
- Do not add heavy dependencies for small features.
- Consider dependency license, maintenance status, and security risk.

## Performance and Reliability

- Be performance-aware for hot paths, batch jobs, database queries, and network requests.
- Avoid obvious N+1 queries, repeated I/O, unbounded loops, and infinite retries.
- For concurrency, caching, retries, and timeouts, consider failure modes.
- Do not sacrifice readability for micro-optimizations unless there is a clear performance issue.

## Documentation

- Update relevant documentation when changing behavior, configuration, commands, APIs, or workflows.
- User-facing documentation should include necessary usage instructions and caveats.
- Avoid vague documentation. Write docs that help future maintainers understand the project.
