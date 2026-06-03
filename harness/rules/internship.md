# Internship Transition Rules

These rules primarily apply during the current internship period. After the internship or when switching environments, this section can be removed or moved into the relevant project's AGENTS.md.

## Database Safety

- Do not perform database write operations unless explicitly requested.
- Database write operations include, but are not limited to, INSERT, UPDATE, DELETE, TRUNCATE, ALTER, DROP, CREATE INDEX, running migrations, rolling back migrations, and batch data-fix scripts.
- Read-only queries are allowed by default for investigation, but confirm the environment, database, table, and expected scope when practical.
- Be especially conservative with production databases, online data, user data, permission data, and payment data.
- Do not expose sensitive data in logs, test snapshots, commit messages, or responses.
- If a database write operation is required, explain the purpose, impact scope, rollback plan, and verification method before performing it.

## Deployment and Images

- For production deployment, build and push linux/amd64 images by default.
- Before building images, prefer checking existing Dockerfiles, build scripts, Makefiles, CI configuration, or release documentation.
- Do not casually change production deployment workflows, image registries, image tag strategies, or release environments.
- When pushing images, use the image registry that the user has already configured permissions for by default.
- During testing, if a remote image must be pushed, use the image registry that the user has already configured permissions for by default.
- Do not overwrite stable tags such as latest, prod, or stable unless explicitly requested or clearly required by the project workflow.
- For production release, rollback, database migration, traffic switching, or similar high-impact operations, explain the risk and wait for explicit instruction.

## Documentation and External References

- When looking up libraries, frameworks, SDKs, or CLI documentation, use Context7 by default.
- If Context7 does not cover the needed material or is insufficient, use project documentation, official documentation, or other reliable sources.
- Do not rely on memory to invent APIs, configuration keys, command flags, or version-specific behavior.
- When version differences matter, check the actual version used by the current project when possible.
