# PPVGO Backup

PPVGO 管理脚本及 Linux AMD64 / ARM64 程序的 GitHub 备份。

## 一键安装（复制下面整行）

```bash
curl -fsSL https://raw.githubusercontent.com/bianyi888/PPVGO-Backup/main/install.sh -o install.sh && bash install.sh
```

> 建议先检查 `install.sh` 和上游管理脚本，再在可信的 Linux 环境运行。安装器尚未经过真实服务器端到端验证。

## 安装源说明

- 安装器从本仓库的 [最新 Release](https://github.com/bianyi888/PPVGO-Backup/releases/latest) 下载 `PPVGO-full-backup.zip` 和 SHA256 校验文件。
- 校验 ZIP、管理脚本和 AMD64 / ARM64 二进制文件后，启动管理菜单。
- 安装器尝试将管理脚本中的原始二进制下载地址改为本次已校验的本地文件路径；如果原始脚本地址格式发生变化，安装器会拒绝继续执行。
- 此改动只作用于本次启动的临时管理脚本；不保证原版管理脚本未来的自更新或独立运行流程也使用本仓库。

## 备份计划

[PPVGO full backup 工作流](https://github.com/bianyi888/PPVGO-Backup/actions/workflows/ppvgo-backup.yml) 支持手动运行，并计划每周日 03:23 UTC 自动备份。

每次成功备份均生成包含管理脚本、AMD64/ARM64 程序及 SHA256 校验信息的 ZIP，发布到 Releases。Actions Artifact 默认保留 90 天。

原始脚本地址：`https://ppvgo.168.us.kg`。二进制源：`https://ppv.168.us.kg/x/ru/ppv_amd` 和 `https://ppv.168.us.kg/x/ru/ppv_arm`。

本仓库公开可读；请勿上传任何凭据或私人配置。
