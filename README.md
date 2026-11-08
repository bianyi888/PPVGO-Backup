# PPVGO Backup

PPVGO Linux AMD64 / ARM64 程序与管理脚本的独立 GitHub 备份。支持从本仓库的 Release 安装或更新 PPVGO，无需依赖原作者的二进制下载域名。保留原程序的外部 API 与 `EMBED_ORIGIN` 功能。

## 一键安装

适用于 Debian / Ubuntu 等使用 systemd 的 Linux 系统。使用 root 账号运行：

```bash
curl -fsSL https://raw.githubusercontent.com/bianyi888/PPVGO-Backup/main/install.sh -o install.sh && bash install.sh
```

首次运行会将独立管理脚本保存到 `/usr/local/bin/ppvgo-manager`。进入菜单后选择 **1. 安装 / 更新**，按提示设置监听端口（默认 `4579`）。安装过程从本仓库的 [最新 Release](https://github.com/bianyi888/PPVGO-Backup/releases/latest) 获取 AMD64 或 ARM64 二进制文件并进行 SHA256 校验。

所需依赖包括 `curl`、`unzip`、`file`、`openssl`、`sha256sum` 和 `systemd`。Debian / Ubuntu 可先执行：

```bash
apt update && apt install -y curl unzip file openssl coreutils
```

> 运行远程安装脚本前，请先审阅仓库中的脚本内容。

## 日常使用

安装后随时运行：

```bash
ppvgo-manager
```

管理菜单：

```text
1. 安装 / 更新
2. 启动
3. 停止
4. 重启
5. 查看状态
6. 查看日志
7. 卸载
8. 查看订阅链接
0. 退出
```

- **安装 / 更新**：从本仓库最新 Release 获取并校验二进制文件；更新会短暂重启服务。
- **启动 / 停止 / 重启**：管理 `ppv` systemd 服务。
- **查看状态 / 日志**：查看服务运行情况和日志。
- **查看订阅链接**：自动读取 `/ppvgo/.env` 中的端口，尝试识别公网 IP，并显示代理 M3U、直连 M3U 和健康检查地址。
- **卸载**：会要求确认，并删除 `/ppvgo`（包括配置），请提前备份。

## 订阅地址

假设服务器公网 IP 为 `YOUR_SERVER_IP`、端口为默认的 `4579`：

| 用途 | 地址 |
| --- | --- |
| 代理 M3U 订阅 | `http://YOUR_SERVER_IP:4579/playlist.m3u` |
| 直连 M3U 订阅 | `http://YOUR_SERVER_IP:4579/playlist.m3u?proxy=0` |
| 健康检查 | `http://YOUR_SERVER_IP:4579/healthz` |

将 `YOUR_SERVER_IP` 换成你的公网 IP 或域名。也可以直接在管理菜单选择 **8. 查看订阅链接**，复制实际地址到 FongMi 等支持 M3U 的播放器。

验证服务：

```bash
systemctl is-active ppv
curl -i http://127.0.0.1:4579/healthz
```

正常情况下分别返回 `active` 和 `HTTP/1.1 200 OK`。健康检查成功不代表所有频道都能播放，仍需实际测试播放。

## 更新管理脚本（不更新 PPVGO 程序）

当 GitHub 上的管理菜单增加新功能时，可以只更新管理脚本，不影响正在运行的服务：

```bash
curl -fsSL "https://raw.githubusercontent.com/bianyi888/PPVGO-Backup/main/ppvgo-manager-independent.sh?refresh=$(date +%s)" -o /tmp/ppvgo-manager-new.sh && \
bash -n /tmp/ppvgo-manager-new.sh && \
install -m 755 /tmp/ppvgo-manager-new.sh /usr/local/bin/ppvgo-manager
```

随后运行 `ppvgo-manager` 即可。URL 中的 `refresh` 参数用于减少获取旧缓存版本的可能性。

## 备份与独立性说明

- [独立管理脚本](https://github.com/bianyi888/PPVGO-Backup/blob/main/ppvgo-manager-independent.sh) 使用本仓库 Release 中的已备份二进制文件，不再从原作者二进制域名下载。
- [自动备份工作流](https://github.com/bianyi888/PPVGO-Backup/actions/workflows/ppvgo-backup.yml) 支持手动触发，并计划每周日 03:23 UTC 运行。
- 每次成功备份会生成带 SHA256 校验的 `PPVGO-full-backup.zip`，发布到 [Releases](https://github.com/bianyi888/PPVGO-Backup/releases)。
- **已有备份**在原下载域名失效后仍可使用；**获取新的上游版本**仍依赖上游可用。
- PPVGO 二进制程序内部使用的外部 API、iframe 和 `EMBED_ORIGIN` 行为保持原样，播放功能可能仍依赖第三方服务。

本仓库公开可读，请勿上传 `/ppvgo/.env`、`PROXY_SECRET` 或其他敏感配置。
