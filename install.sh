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
# Redirect the upstream manager's two binary downloads to the verified local
# files in this temporary directory. curl supports file:// URLs.
# Refuse to proceed if upstream changed either expected download URL.
grep -Fq 'AMD_URL="https://ppv.168.us.kg/x/ru/ppv_amd"' ppvgo-manager.sh || { echo "Unexpected upstream AMD64 URL; refusing to run" >&2; exit 1; }
grep -Fq 'ARM_URL="https://ppv.168.us.kg/x/ru/ppv_arm"' ppvgo-manager.sh || { echo "Unexpected upstream ARM64 URL; refusing to run" >&2; exit 1; }
sed -i \
  -e "s|AMD_URL=\"https://ppv.168.us.kg/x/ru/ppv_amd\"|AMD_URL=\"file://${WORKDIR}/ppv_amd\"|" \
  -e "s|ARM_URL=\"https://ppv.168.us.kg/x/ru/ppv_arm\"|ARM_URL=\"file://${WORKDIR}/ppv_arm\"|" \
  ppvgo-manager.sh
if grep -Eq 'https://ppv\\.168\\.us\\.kg/x/ru/ppv_(amd|arm)' ppvgo-manager.sh; then
  echo "Original binary download URL remains; refusing to run" >&2
  exit 1
fi
bash -n ppvgo-manager.sh
echo "Using SHA256-verified binaries from your own GitHub Release."
echo "Review the upstream management script before running it as root."
chmod +x ppvgo-manager.sh
bash ./ppvgo-manager.sh "$@"
