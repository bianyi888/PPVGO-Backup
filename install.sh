#!/usr/bin/env bash
# PPVGO installer from the latest backup in bianyi888/PPVGO-Backup.
# Public repository required for anonymous downloads.
set -Eeuo pipefail

REPO="bianyi888/PPVGO-Backup"
BASE="https://github.com/${REPO}/releases/latest/download"
for cmd in curl unzip sha256sum bash file; do
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
echo "NOTE: The upstream manager may still download binaries from upstream during installation or updates."
echo "Inspect ppvgo-manager.sh before running untrusted code."
chmod +x ppvgo-manager.sh
bash ./ppvgo-manager.sh "$@"
