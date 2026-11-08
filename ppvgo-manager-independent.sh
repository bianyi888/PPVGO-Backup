#!/usr/bin/env bash
# Independent PPVGO manager. Binary source: this repository's latest Release.
set -Eeuo pipefail
REPO="bianyi888/PPVGO-Backup"
BASE="/ppvgo"
SERVICE="/etc/systemd/system/ppv.service"
DEFAULT_PORT=4579
require_root() { [[ $EUID -eq 0 ]] || { echo "请使用 root 运行" >&2; exit 1; }; }
need() { for c in "$@"; do command -v "$c" >/dev/null || { echo "缺少依赖: $c" >&2; exit 1; }; done; }
fetch_verified_binary() {
  need curl unzip sha256sum file mktemp
  local work url arch bin
  work="$(mktemp -d)"
  url="https://github.com/${REPO}/releases/latest/download"
  if ! curl -fsSL --retry 3 -o "$work/PPVGO-full-backup.zip" "$url/PPVGO-full-backup.zip" ||
     ! curl -fsSL --retry 3 -o "$work/PPVGO-full-backup.zip.sha256" "$url/PPVGO-full-backup.zip.sha256"; then
    rm -rf "$work"; echo "GitHub 备份下载失败" >&2; return 1
  fi
  if ! (cd "$work" && sha256sum -c PPVGO-full-backup.zip.sha256 && unzip -q PPVGO-full-backup.zip && sha256sum -c SHA256SUMS); then
    rm -rf "$work"; echo "备份校验失败" >&2; return 1
  fi
  arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64) bin=ppv_amd; file -b "$work/$bin" | grep -qi 'ELF.*x86-64' ;;
    aarch64|arm64) bin=ppv_arm; file -b "$work/$bin" | grep -qi 'ELF.*aarch64' ;;
    *) rm -rf "$work"; echo "不支持的架构: $arch" >&2; return 1 ;;
  esac || { rm -rf "$work"; echo "二进制架构检查失败" >&2; return 1; }
  mkdir -p "$BASE"
  install -m 755 "$work/$bin" "$BASE/ppv.new"
  rm -rf "$work"
}
install_app() {
  require_root
  need systemctl openssl install
  local port secret oldport
  port="$DEFAULT_PORT"
  if [[ -f "$BASE/.env" ]]; then
    oldport="$(grep '^PORT=' "$BASE/.env" | cut -d= -f2- || true)"
    [[ -z "$oldport" ]] || port="$oldport"
  fi
  read -r -p "请输入监听端口 [$port]: " entered || true
  port="${entered:-$port}"
  [[ "$port" =~ ^[0-9]+$ ]] && ((10#$port >= 1 && 10#$port <= 65535)) || { echo "端口无效" >&2; return 1; }
  echo "==> 从自己的 GitHub Release 下载并校验 PPVGO"
  fetch_verified_binary || return 1
  if [[ -f "$BASE/.env" ]] && grep -q '^PROXY_SECRET=' "$BASE/.env"; then
    secret="$(grep '^PROXY_SECRET=' "$BASE/.env" | cut -d= -f2-)"
  else
    secret="$(openssl rand -hex 32)"
  fi
  [[ -n "$secret" ]] || { echo "PROXY_SECRET 为空" >&2; return 1; }
  printf 'PROXY_SECRET=%s\nPORT=%s\n' "$secret" "$port" > "$BASE/.env"
  chmod 600 "$BASE/.env"
  cat > "$SERVICE" <<EOF
[Unit]
Description=PPVGO
After=network.target
[Service]
Type=simple
WorkingDirectory=/ppvgo
EnvironmentFile=/ppvgo/.env
ExecStart=/ppvgo/ppv
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
EOF
  systemctl stop ppv 2>/dev/null || true
  mv -f "$BASE/ppv.new" "$BASE/ppv"
  chmod 755 "$BASE/ppv"
  systemctl daemon-reload
  systemctl enable ppv
  systemctl restart ppv
  sleep 2
  systemctl is-active --quiet ppv || { systemctl status ppv --no-pager; return 1; }
  echo "PPVGO 安装/更新成功，端口 $port"
  echo "本地检测: curl -i http://127.0.0.1:$port/healthz"
}
uninstall_app() {
  require_root
  read -r -p "确定卸载 PPVGO 并删除 /ppvgo（包括配置）？[y/N]: " answer
  [[ "$answer" == y || "$answer" == Y ]] || return 0
  systemctl stop ppv 2>/dev/null || true
  systemctl disable ppv 2>/dev/null || true
  rm -f "$SERVICE"
  systemctl daemon-reload
  rm -rf "$BASE"
  echo "已卸载"
}
menu() {
  echo "========================================"
  echo " PPVGO 独立管理脚本（GitHub 备份源）"
  echo "========================================"
  echo "1. 安装 / 更新"
  echo "2. 启动"
  echo "3. 停止"
  echo "4. 重启"
  echo "5. 查看状态"
  echo "6. 查看日志"
  echo "7. 卸载"
  echo "0. 退出"
  read -r -p "请选择: " choice
  case "$choice" in
    1) install_app ;;
    2) require_root; systemctl start ppv ;;
    3) require_root; systemctl stop ppv ;;
    4) require_root; systemctl restart ppv ;;
    5) systemctl status ppv --no-pager ;;
    6) journalctl -u ppv -f ;;
    7) uninstall_app ;;
    0) exit 0 ;;
    *) echo "无效选项" >&2; return 1 ;;
  esac
}
menu
