#!/usr/bin/env bash
# PPVGO installer from the latest backup in bianyi888/PPVGO-Backup.
# Public repository required for anonymous downloads.
set -Eeuo pipefail

REPO="bianyi888/PPVGO-Backup"
BASE="https://github.com/${REPO}/releases/latest/download"
for cmd in curl unzip sha256sum bash file python3 cp; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Missing dependency: $cmd" >&2; exit 1; }
done

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT
cd "$WORKDIR"
curl -fL --retry 3 --connect-timeout 15 --max-time 240 -o PPVGO-full-backup.zip "${BASE}/PPVGO-full-backup.zip"
curl -fL --retry 3 --connect-timeout 15 --max-time 60 -o PPVGO-full-backup.zip.sha256 "${BASE}/PPVGO-full-backup.zip.sha256"
sha256sum -c PPVGO-full-backup.zip.sha256
unzip -q PPVGO-full-backup.zip
sha256sum -c SHA256SUMS
bash -n ppvgo-manager.sh
file -b ppv_amd | grep -qi 'ELF.*x86-64' || { echo "Invalid AMD64 binary" >&2; exit 1; }
file -b ppv_arm | grep -qi 'ELF.*aarch64' || { echo "Invalid ARM64 binary" >&2; exit 1; }
echo "Backup downloaded and checksums verified."
# Patch only the audited upstream download block. Abort if the upstream
# manager changes, rather than silently running an unreviewed installer.
export PPVGO_LOCAL_AMD="${WORKDIR}/ppv_amd"
export PPVGO_LOCAL_ARM="${WORKDIR}/ppv_arm"
python3 - ppvgo-manager.sh <<'PY'
import pathlib
import sys

p = pathlib.Path(sys.argv[1])
s = p.read_text()
old = '''    curl -fL \\
        --progress-bar \\
        "$BIN_URL" \\
        -o "$TMP"'''
new = '''    # Use the binaries already downloaded and checksum-verified by install.sh.
    case "$ARCH" in
        x86_64|amd64) LOCAL_BIN="$PPVGO_LOCAL_AMD" ;;
        aarch64|arm64) LOCAL_BIN="$PPVGO_LOCAL_ARM" ;;
        *) echo "Unsupported architecture" >&2; exit 1 ;;
    esac
    test -s "$LOCAL_BIN" || { echo "Missing verified binary" >&2; exit 1; }
    cp -- "$LOCAL_BIN" "$TMP"'''
if s.count(old) != 1:
    raise SystemExit("Unexpected upstream download block; refusing to run")
s = s.replace(old, new)
p.write_text(s)
PY
bash -n ppvgo-manager.sh
echo "Using SHA256-verified binaries from your own GitHub Release."
echo "Review the upstream management script before running it as root."
chmod +x ppvgo-manager.sh
bash ./ppvgo-manager.sh "$@"
