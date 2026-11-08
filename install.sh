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
# Use verified release binaries for both installation and updates.
# Match variable assignments, not an upstream hostname, so an expired domain
# cannot prevent installing from the archived release.
for arch in AMD ARM; do
  count="$(grep -Ec "^[[:space:]]*${arch}_URL=" ppvgo-manager.sh || true)"
  if [[ "$count" != "1" ]]; then
    echo "Unexpected ${arch}_URL definition count: $count; refusing to run" >&2
    exit 1
  fi
done
sed -i \
  -e "s|^[[:space:]]*AMD_URL=.*$|AMD_URL=\"file://${WORKDIR}/ppv_amd\"|" \
  -e "s|^[[:space:]]*ARM_URL=.*$|ARM_URL=\"file://${WORKDIR}/ppv_arm\"|" \
  ppvgo-manager.sh
grep -Fxq "AMD_URL=\"file://${WORKDIR}/ppv_amd\"" ppvgo-manager.sh || exit 1
grep -Fxq "ARM_URL=\"file://${WORKDIR}/ppv_arm\"" ppvgo-manager.sh || exit 1
bash -n ppvgo-manager.sh
echo "Using SHA256-verified binaries from your own GitHub Release."
echo "Review the upstream management script before running it as root."
chmod +x ppvgo-manager.sh
bash ./ppvgo-manager.sh "$@"
