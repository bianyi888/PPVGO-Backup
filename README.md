# PPVGO Backup

PPVGO 管理脚本及 Linux AMD64 / ARM64 程序的 GitHub 备份。

## 一键安装（复制下面整行）

```bash
curl -fsSL https://raw.githubusercontent.com/bianyi888/PPVGO-Backup/main/install.sh -o install.sh && bash install.sh
```

> 建议先检查 `install.sh` 和上游管理脚本，再在可信的 Linux 环境运行。安装器尚未经过真实服务器端到端验证。

## 安装源说明

- 独立管理脚本永久保存于 [`ppvgo-manager-independent.sh`](https://github.com/bianyi888/PPVGO-Backup/blob/main/ppvgo-manager-independent.sh)，首次运行时会安装为 `/usr/local/bin/ppvgo-manager`，以后可执行 `ppvgo-manager` 进入菜单。\n- 安装和更新从本仓库的 [最新 Release](https://github.com/bianyi888/PPVGO-Backup/releases/latest) 下载 `PPVGO-full-backup.zip` 和 SHA256 校验文件。
- 校验 ZIP 与 AMD64 / ARM64 二进制文件后，按 CPU 架构直接复制对应文件。
- 不再动态修改原作者管理脚本，也不需要原作者的二进制下载域名。
- 安装、更新、启动、停止、重启、状态、日志和卸载菜单由仓库中的独立管理脚本提供；运行时的外部 API 和 EMBED_ORIGIN 行为由 PPV 二进制程序决定，未作修改。

## 备份计划

[PPVGO full backup 工作流](https://github.com/bianyi888/PPVGO-Backup/actions/workflows/ppvgo-backup.yml) 支持手动运行，并计划每周日 03:23 UTC 自动备份。

每次成功备份均生成包含管理脚本、AMD64/ARM64 程序及 SHA256 校验信息的 ZIP，发布到 Releases。Actions Artifact 默认保留 90 天。

原始脚本地址：`https://ppvgo.168.us.kg`。二进制源：`https://ppv.168.us.kg/x/ru/ppv_amd` 和 `https://ppv.168.us.kg/x/ru/ppv_arm`。

本仓库公开可读；请勿上传任何凭据或私人配置。
