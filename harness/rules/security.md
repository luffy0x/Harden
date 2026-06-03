# Security Rules

- Do not print, log, commit, or expose secrets, tokens, passwords, private keys, cookies, production connection strings, or other sensitive values.
- If a potential secret leak is found, warn the user and recommend rotating the secret.
- Do not put sensitive data into logs, test snapshots, example configs, documentation, or responses.
- Be especially conservative around authentication, authorization, payments, data deletion, production operations, and user data.
- Do not suggest dangerous commands unless the risks and safer alternatives are explained.
- Do not access tokens, secrets, credentials, or production connection strings directly from arbitrary application code.
- Use the project's approved authentication, session, secret-management, or configuration abstraction.
- Never log or expose tokens, cookies, credentials, or sensitive user data.
