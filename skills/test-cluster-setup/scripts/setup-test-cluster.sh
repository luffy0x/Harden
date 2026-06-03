#!/usr/bin/env bash
set -euo pipefail

SSH_USER="sealos"
SSH_HOST=""
SSH_PASSWORD="${SEALOS_SSH_PASSWORD:-}"
SUDO_PASSWORD="${SEALOS_SUDO_PASSWORD:-}"
KUBE_NAME=""
OVERWRITE="0"
SKIP_CERT="0"
SKIP_AGENTS="0"
AGENTS_FILE="${HOME}/.codex/AGENTS.md"

usage() {
  cat <<'EOF'
Usage:
  setup-test-cluster.sh <cluster-domain> [options]

Options:
  --kube-name <name>       Write kubeconfig to ~/.kube/<name>
  --overwrite              Overwrite existing kubeconfig without prompting
  --agents-file <path>     Update this AGENTS.md file (default: ~/.codex/AGENTS.md)
  --skip-agents            Do not update AGENTS.md
  --skip-cert              Skip local certificate trust step
  --ssh-user <user>        SSH user (default: sealos)
  --ssh-host <host>        SSH host (default: IPv4 extracted from nip.io host)
  --password <password>    SSH password, or set SEALOS_SSH_PASSWORD
  --sudo-password <pass>   sudo/root password, or set SEALOS_SUDO_PASSWORD
  -h, --help               Show this help
EOF
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

shell_quote() {
  local value="$1"
  printf "'%s'" "$(printf "%s" "$value" | sed "s/'/'\\\\''/g")"
}

DOMAIN=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --kube-name)
      [ "$#" -ge 2 ] || die "--kube-name requires a value"
      KUBE_NAME="$2"
      shift 2
      ;;
    --overwrite)
      OVERWRITE="1"
      shift
      ;;
    --agents-file)
      [ "$#" -ge 2 ] || die "--agents-file requires a value"
      AGENTS_FILE="$2"
      shift 2
      ;;
    --skip-agents)
      SKIP_AGENTS="1"
      shift
      ;;
    --skip-cert)
      SKIP_CERT="1"
      shift
      ;;
    --ssh-user)
      [ "$#" -ge 2 ] || die "--ssh-user requires a value"
      SSH_USER="$2"
      shift 2
      ;;
    --ssh-host)
      [ "$#" -ge 2 ] || die "--ssh-host requires a value"
      SSH_HOST="$2"
      shift 2
      ;;
    --password)
      [ "$#" -ge 2 ] || die "--password requires a value"
      SSH_PASSWORD="$2"
      shift 2
      ;;
    --sudo-password)
      [ "$#" -ge 2 ] || die "--sudo-password requires a value"
      SUDO_PASSWORD="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      die "Unknown option: $1"
      ;;
    *)
      [ -z "$DOMAIN" ] || die "Only one cluster domain is supported"
      DOMAIN="$1"
      shift
      ;;
  esac
done

[ -n "$DOMAIN" ] || {
  usage
  exit 1
}

[ -n "$SSH_PASSWORD" ] || die "Missing SSH password; pass --password or set SEALOS_SSH_PASSWORD"
[ -n "$SUDO_PASSWORD" ] || die "Missing sudo password; pass --sudo-password or set SEALOS_SUDO_PASSWORD"

require_cmd bash
require_cmd expect
require_cmd ssh
require_cmd ssh-keygen
require_cmd python3
require_cmd sed
require_cmd grep

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
CERT_SCRIPT="${SCRIPT_DIR}/mac-linux.sh"

URL_HOST="$(python3 - "$DOMAIN" <<'PY'
from urllib.parse import urlparse
import sys

raw = sys.argv[1].strip()
if "://" not in raw:
    raw = "https://" + raw
parsed = urlparse(raw)
host = parsed.hostname or ""
if not host:
    raise SystemExit("could not parse host")
scheme = parsed.scheme or "https"
path = parsed.path or "/"
netloc = host
if parsed.port:
    netloc = f"{host}:{parsed.port}"
url = f"{scheme}://{netloc}{path}"
print(url)
print(host)
PY
)" || die "Could not parse cluster domain: $DOMAIN"

URL="$(printf "%s\n" "$URL_HOST" | sed -n '1p')"
HOST="$(printf "%s\n" "$URL_HOST" | sed -n '2p')"
[ -n "$HOST" ] || die "Could not parse host from: $DOMAIN"

if [ -z "$SSH_HOST" ]; then
  SSH_HOST="$(python3 - "$HOST" <<'PY'
import re
import sys

host = sys.argv[1]
match = re.match(r'^(\d{1,3}(?:\.\d{1,3}){3})(?:\.nip\.io)?$', host)
print(match.group(1) if match else host)
PY
)"
fi

if [ -z "$KUBE_NAME" ]; then
  KUBE_NAME="$(python3 - "$HOST" <<'PY'
import re
import sys

host = sys.argv[1]
nums = re.findall(r'(?<!\d)(\d{1,3})(?!\d)', host)
if len(nums) >= 4:
    print(nums[3])
elif nums:
    print(nums[-1])
else:
    print(re.sub(r'[^A-Za-z0-9_.-]+', '-', host).strip('-') or 'cluster')
PY
)"
fi

KUBE_DIR="${HOME}/.kube"
KUBE_FILE="${KUBE_DIR}/${KUBE_NAME}"
KUBE_DISPLAY="~/.kube/${KUBE_NAME}"
SSH_TARGET="${SSH_USER}@${SSH_HOST}"
API_SERVER="https://${HOST}:6443"

echo "== Test cluster setup =="
echo "Domain:      ${URL}"
echo "SSH target:  ${SSH_TARGET}"
echo "Kubeconfig:  ${KUBE_DISPLAY} (${KUBE_FILE})"
echo "API server:  ${API_SERVER}"
echo ""

if [ "$SKIP_CERT" != "1" ]; then
  [ -x "$CERT_SCRIPT" ] || die "Certificate script is missing or not executable: $CERT_SCRIPT"
  echo "[1/6] Trust cluster certificate"
  bash "$CERT_SCRIPT" --mode auto "$URL" || die "Certificate trust step failed for ${URL}"
else
  echo "[1/6] Trust cluster certificate: skipped"
fi

echo ""
echo "[2/6] Ensure local SSH key"
mkdir -p "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"

PUB_KEY=""
if [ -f "${HOME}/.ssh/id_ed25519.pub" ]; then
  PUB_KEY="${HOME}/.ssh/id_ed25519.pub"
elif [ -f "${HOME}/.ssh/id_rsa.pub" ]; then
  PUB_KEY="${HOME}/.ssh/id_rsa.pub"
else
  ssh-keygen -t ed25519 -N "" -f "${HOME}/.ssh/id_ed25519" -C "${USER:-codex}@$(hostname)-test-cluster"
  PUB_KEY="${HOME}/.ssh/id_ed25519.pub"
fi
echo "Using public key: ${PUB_KEY}"

echo ""
echo "[3/6] Install SSH public key on ${SSH_TARGET}"
PUB_CONTENT="$(sed -n '1p' "$PUB_KEY")"
[ -n "$PUB_CONTENT" ] || die "Public key is empty: $PUB_KEY"
PUB_QUOTED="$(shell_quote "$PUB_CONTENT")"
REMOTE_KEY_CMD="mkdir -p ~/.ssh && chmod 700 ~/.ssh && touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys; if ! grep -qxF ${PUB_QUOTED} ~/.ssh/authorized_keys; then printf '%s\n' ${PUB_QUOTED} >> ~/.ssh/authorized_keys; fi"

set +e
expect -f - "$SSH_HOST" "$SSH_USER" "$SSH_PASSWORD" "$REMOTE_KEY_CMD" <<'EXPECT'
set timeout 30
set host [lindex $argv 0]
set user [lindex $argv 1]
set password [lindex $argv 2]
set remote_cmd [lindex $argv 3]

spawn ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 "$user@$host" "$remote_cmd"
expect {
  -re "(?i)are you sure you want to continue connecting" {
    send "yes\r"
    exp_continue
  }
  -re "(?i)password:" {
    send "$password\r"
    exp_continue
  }
  timeout {
    exit 124
  }
  eof {
    catch wait result
    exit [lindex $result 3]
  }
}
EXPECT
EXPECT_STATUS="$?"
set -e
if [ "$EXPECT_STATUS" != "0" ]; then
  die "SSH password setup failed for ${SSH_TARGET}; the password may be wrong or SSH is unreachable"
fi

if ! ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 "$SSH_TARGET" "true"; then
  die "Passwordless SSH verification failed for ${SSH_TARGET}"
fi
echo "Passwordless SSH is ready."

sudo_ssh() {
  local remote_cmd="$1"
  local quoted
  quoted="$(printf "%q" "$remote_cmd")"
  printf "%s\n" "$SUDO_PASSWORD" | ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=20 "$SSH_TARGET" "sudo -S -p '' bash -lc $quoted"
}

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

RAW_KUBECONFIG="${TMP_DIR}/config.raw"
EDITED_KUBECONFIG="${TMP_DIR}/config.edited"
SUDO_ERR="${TMP_DIR}/sudo.err"

echo ""
echo "[4/6] Fetch root kubeconfig and rewrite server endpoint"
if ! sudo_ssh "cat /root/.kube/config" >"$RAW_KUBECONFIG" 2>"$SUDO_ERR"; then
  cat "$SUDO_ERR" >&2 || true
  die "Could not read /root/.kube/config through sudo; the sudo password may be wrong"
fi

if ! grep -q '^apiVersion:' "$RAW_KUBECONFIG"; then
  cat "$SUDO_ERR" >&2 || true
  die "Fetched kubeconfig does not look valid"
fi

python3 - "$RAW_KUBECONFIG" "$EDITED_KUBECONFIG" "$API_SERVER" <<'PY'
import re
import sys
from pathlib import Path

src = Path(sys.argv[1])
dst = Path(sys.argv[2])
server = sys.argv[3]
changed = 0
out = []

for line in src.read_text().splitlines():
    match = re.match(r'^(\s*)server:\s*.+$', line)
    if match:
        out.append(f"{match.group(1)}server: {server}")
        changed += 1
    else:
        out.append(line)

if changed == 0:
    raise SystemExit("no server lines found in kubeconfig")

dst.write_text("\n".join(out) + "\n")
PY

mkdir -p "$KUBE_DIR"
chmod 700 "$KUBE_DIR"

if [ -e "$KUBE_FILE" ] && [ "$OVERWRITE" != "1" ]; then
  if [ -t 0 ]; then
    echo "Kubeconfig already exists: ${KUBE_FILE}"
    printf "Overwrite it? [y/N] "
    read -r answer
    case "$answer" in
      y|Y|yes|YES)
        ;;
      *)
        printf "Enter another kubeconfig name: "
        read -r KUBE_NAME
        [ -n "$KUBE_NAME" ] || die "No kubeconfig name provided"
        KUBE_FILE="${KUBE_DIR}/${KUBE_NAME}"
        KUBE_DISPLAY="~/.kube/${KUBE_NAME}"
        [ ! -e "$KUBE_FILE" ] || die "Kubeconfig still exists: ${KUBE_FILE}"
        ;;
    esac
  else
    die "${KUBE_FILE} already exists; rerun with --overwrite or --kube-name <new-name>"
  fi
fi

umask 077
cp "$EDITED_KUBECONFIG" "$KUBE_FILE"
chmod 600 "$KUBE_FILE"
echo "Wrote kubeconfig: ${KUBE_DISPLAY} (${KUBE_FILE})"

if command -v kubectl >/dev/null 2>&1; then
  if kubectl --kubeconfig "$KUBE_FILE" config view --raw >/dev/null; then
    echo "kubectl can parse the kubeconfig."
  else
    echo "WARNING: kubectl could not parse ${KUBE_FILE}" >&2
  fi
fi

echo ""
echo "[5/6] Update AGENTS.md"
if [ "$SKIP_AGENTS" = "1" ]; then
  echo "AGENTS.md update skipped."
else
  python3 - "$AGENTS_FILE" "$KUBE_NAME" "$KUBE_DISPLAY" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1]).expanduser()
name = sys.argv[2]
kube_file = sys.argv[3]
start = "<!-- test-cluster-setup:start -->"
end = "<!-- test-cluster-setup:end -->"
entry = f"- Cluster {name} kubeconfig: `{kube_file}`; access it with `kubectl --kubeconfig {kube_file} ...`.\n"

if path.exists():
    content = path.read_text()
else:
    content = ""

if kube_file in content:
    print(f"AGENTS.md already mentions {kube_file}: {path}")
    raise SystemExit(0)

if start in content and end in content:
    before, rest = content.split(start, 1)
    block, after = rest.split(end, 1)
    lines = block.rstrip().splitlines()
    if not any(line.strip() == "## Test Cluster Access" for line in lines):
        lines.insert(0, "## Test Cluster Access")
    lines.append(entry.rstrip())
    new_block = "\n" + "\n".join(lines).rstrip() + "\n"
    content = before.rstrip() + "\n\n" + start + new_block + end + after
else:
    block = f"{start}\n## Test Cluster Access\n{entry}{end}\n"
    content = content.rstrip() + ("\n\n" if content.strip() else "") + block

path.parent.mkdir(parents=True, exist_ok=True)
path.write_text(content)
print(f"Updated AGENTS.md: {path}")
PY
fi

echo ""
echo "[6/6] Find and run Sealos info.sh"
FIND_INFO_CMD='
set -e
{
  for base in /root /home /data /opt; do
    if [ -d "$base" ]; then
      find "$base" -maxdepth 6 -type f -name info.sh 2>/dev/null
    fi
  done
  find / -xdev -type f -name info.sh 2>/dev/null | head -n 40
} | awk '"'"'!seen[$0]++'"'"'
'

INFO_PATHS="$(sudo_ssh "$FIND_INFO_CMD" 2>/dev/null || true)"
INFO_PATH="$(printf "%s\n" "$INFO_PATHS" | grep -E '/sealos(-commercial)?[^/]*/info\.sh$' | head -n 1 || true)"
if [ -z "$INFO_PATH" ]; then
  INFO_PATH="$(printf "%s\n" "$INFO_PATHS" | sed '/^$/d' | head -n 1 || true)"
fi

INFO_OUTPUT=""
if [ -n "$INFO_PATH" ]; then
  echo "Found info.sh: ${INFO_PATH}"
  INFO_DIR="$(dirname "$INFO_PATH")"
  INFO_BASE="$(basename "$INFO_PATH")"
  RUN_INFO_CMD="cd $(shell_quote "$INFO_DIR") && bash $(shell_quote "$INFO_BASE")"
  INFO_OUTPUT="$(sudo_ssh "$RUN_INFO_CMD" 2>/dev/null || true)"
  if [ -n "$INFO_OUTPUT" ]; then
    echo ""
    echo "---- info.sh output ----"
    printf "%s\n" "$INFO_OUTPUT"
    echo "---- end info.sh output ----"
    echo ""
    echo "Likely account/password lines:"
    printf "%s\n" "$INFO_OUTPUT" | grep -Ei 'admin|user|username|account|password|passwd|账号|账户|用户名|密码' || true
  else
    echo "WARNING: info.sh ran but produced no output, or execution failed." >&2
  fi
else
  echo "WARNING: info.sh was not found under /root, /home, /data, /opt, or the root filesystem fallback." >&2
fi

echo ""
echo "== Setup complete =="
echo "SSH target: ${SSH_TARGET}"
echo "Kubeconfig: ${KUBE_DISPLAY} (${KUBE_FILE})"
echo "API server: ${API_SERVER}"
