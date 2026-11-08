#!/usr/bin/env bash
# Bootstrap the permanent independent PPVGO manager from this repository.
set -Eeuo pipefail
URL="https://raw.githubusercontent.com/bianyi888/PPVGO-Backup/main/ppvgo-manager-independent.sh"
command -v curl >/dev/null || { echo "缺少依赖: curl" >&2; exit 1; }
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
curl -fsSL --retry 3 "$URL" -o "$tmp"
head -n 1 "$tmp" | grep -qx '#!/usr/bin/env bash' || { echo "管理脚本格式错误" >&2; exit 1; }
bash -n "$tmp"
# Keep a persistent copy so future service management does not depend on
# the temporary bootstrap file. Do not overwrite the running binary.
install -m 755 "$tmp" /usr/local/bin/ppvgo-manager
echo "独立管理脚本已保存到 /usr/local/bin/ppvgo-manager"
exec bash /usr/local/bin/ppvgo-manager "$@"
