---
name: test-cluster-setup
description: Configure a Sealos test cluster on a developer Mac from a nip.io or similar HTTPS domain. Use when the user asks to set up a test cluster locally, trust the cluster certificate, configure passwordless SSH for sealos at the cluster IP, fetch the root kubeconfig into a cluster-specific file under ~/.kube, rewrite the kube-apiserver endpoint to the external domain, record the kubeconfig path in the global Codex AGENTS.md, and retrieve Sealos Cloud admin account/password information from info.sh.
---

# Test Cluster Setup

Use this skill to turn a fresh Sealos test cluster domain such as `https://192.0.2.10.nip.io/` into a locally usable development cluster.

## Default Assumptions

- The SSH user is `sealos`.
- For `*.nip.io` domains, SSH to the extracted IP address, e.g. `sealos@192.0.2.10`, while keeping the kube-apiserver endpoint on the external domain.
- The SSH password must come from the user at runtime, `--password`, or `SEALOS_SSH_PASSWORD`.
- The sudo/root password must come from the user at runtime, `--sudo-password`, or `SEALOS_SUDO_PASSWORD`.
- The local kubeconfig name defaults to the last numeric IPv4 label, e.g. `10` for `192.0.2.10.nip.io`.
- The kubeconfig is written to `~/.kube/<name>`.
- The kubeconfig cluster `server:` must point to `https://<domain-host>:6443`, not the in-cluster address such as `https://apiserver.cluster.local:6443`.
- The global Codex instructions file `~/.codex/AGENTS.md` should record the kubeconfig path after setup. Do not write machine-specific kubeconfig notes into a project repository's `AGENTS.md` unless the user explicitly requests that path.
- Resolve bundled scripts from the installed skill directory. In a standard Codex install this is `${CODEX_HOME:-$HOME/.codex}/skills/test-cluster-setup`; if the skill was loaded from another path, use the directory containing this `SKILL.md`.
- Do not use the skill author's absolute local paths. User-specific paths should be based on `$HOME`, e.g. `$HOME/.kube/<name>` and `$HOME/.codex/AGENTS.md`.

## Workflow

1. Get the cluster domain from the user. Accept either `https://192.0.2.10.nip.io/` or `192.0.2.10.nip.io`; normalize it to HTTPS.
2. Run the bundled certificate trust script:

   ```bash
   SKILL_DIR="${CODEX_HOME:-$HOME/.codex}/skills/test-cluster-setup"
   bash "$SKILL_DIR/scripts/mac-linux.sh" --mode auto https://192.0.2.10.nip.io/
   ```

   If macOS asks for the local sudo password, let the user enter it. If certificate installation fails, stop and report the failing step.

3. Configure passwordless SSH for `sealos@<ip>` using a runtime-provided password. If password login fails, stop and tell the user the `sealos` password may be wrong or SSH is unreachable.
4. Fetch the root kubeconfig through sudo, rewrite its `server:` entries to `https://<domain-host>:6443`, and save it under `~/.kube/<name>`.
5. If `~/.kube/<name>` already exists, ask the user whether to overwrite it or choose another name. Do not overwrite silently.
6. Update or create the global Codex `~/.codex/AGENTS.md` with a short note such as:

   ```markdown
   - Cluster 10 kubeconfig: `~/.kube/10`; access it with `kubectl --kubeconfig ~/.kube/10 ...`.
   ```

7. Find and run the Sealos deployment `info.sh` as root. Search likely install locations first (`/root`, `/home`, `/data`, `/opt`), then fall back to a broader root filesystem search if needed. Prefer paths under `sealos-commercial-*` or `sealos-*`.
8. Return the setup result to the user, including:
   - SSH target, e.g. `sealos@192.0.2.10`
   - kubeconfig path, e.g. `~/.kube/10`
   - global AGENTS.md update status
   - Sealos Cloud admin account/password lines extracted from `info.sh`

## Automation Script

Prefer the bundled script for the full flow:

```bash
SKILL_DIR="${CODEX_HOME:-$HOME/.codex}/skills/test-cluster-setup"
SEALOS_SSH_PASSWORD="<ssh-password>" \
SEALOS_SUDO_PASSWORD="<sudo-password>" \
bash "$SKILL_DIR/scripts/setup-test-cluster.sh" https://192.0.2.10.nip.io/
```

Useful options:

```bash
# Pick a different kubeconfig file name.
bash "$SKILL_DIR/scripts/setup-test-cluster.sh" https://192.0.2.10.nip.io/ --kube-name cluster-test

# Overwrite an existing kubeconfig without prompting.
bash "$SKILL_DIR/scripts/setup-test-cluster.sh" https://192.0.2.10.nip.io/ --overwrite

# Update a specific AGENTS.md only when explicitly requested.
bash "$SKILL_DIR/scripts/setup-test-cluster.sh" https://192.0.2.10.nip.io/ --agents-file /path/to/AGENTS.md

# Skip certificate installation if it was already trusted.
bash "$SKILL_DIR/scripts/setup-test-cluster.sh" https://192.0.2.10.nip.io/ --skip-cert
```

Read the script only when patching behavior is necessary. It already handles SSH key creation, password-based key install with `expect`, kubeconfig rewrite, global AGENTS.md note insertion, and `info.sh` discovery/execution.

## Failure Handling

- If `expect` is missing, tell the user the skill needs `expect` for noninteractive first-login SSH setup.
- If SSH password auth fails, report that `sealos@<host>` password auth failed without printing the password.
- If sudo/root access fails, report that sudo access failed without printing the password.
- If `info.sh` is not found, return the completed kubeconfig setup and say that the deployment directory was not found under the searched paths.
- Treat `info.sh` output as sensitive runtime data: show account/password lines only in the private task response and never commit, snapshot, or store them in public docs.
