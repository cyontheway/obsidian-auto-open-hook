# Obsidian Auto Open Hook

Claude Code PostToolUse Hook：Edit/Write 后自动在 Obsidian 中打开 .md 文件。

---

## 简介

因为用 Obsidian 比较多，让 Claude Code 操作 Obsidian 很方便，但每次改完笔记要手动去 Obsidian 打开 .md 有点烦。这个 PostToolUse Hook 会在 Edit/Write 后自动用 Obsidian 打开修改的文件。

## 两个版本

本项目提供两个版本的 hook 脚本，根据你的 vault 使用场景选择：

| 版本 | 文件 | 打开方式 | 说明 |
|------|------|---------|------|
| **CLI 版** | `auto-open-obsidian.sh` | `obsidian open` CLI | 原版，依赖 Obsidian CLI |
| **URI 版** | `auto-open-obsidian-uri.sh` | `obsidian://` URI scheme | 通过 vault ID 定位，不走 CLI 连接限制 |

### CLI 版（原版）`auto-open-obsidian.sh`

依赖 Obsidian CLI 的 `obsidian open` 命令。打开的是 Obsidian CLI **当前连接的 vault**（通常是最后聚焦的那个窗口）。

**多 vault 场景下**，你有两个选择：
- **方案 A（活跃 vault）**：不做任何配置，CLI 默认连哪个就开哪个。适合同一时间只用一个 vault 的用户。
- **方案 B（硬编码）**：取消脚本底部 `vault=` 的注释，指定一个固定 vault。代价是写其他库的文件时，文件路径不存在于该 vault 中，会被静默跳过。

两种方案都不完美——这正是 URI 版要解决的问题。

### URI 版 `auto-open-obsidian-uri.sh`

使用 `obsidian://open?vault=xxx&file=yyy` URI scheme 打开文件，绕过 CLI 的活跃 vault 连接限制。自动从 `obsidian.json` 查找 vault ID（而非使用文件夹名），避免中文/特殊字符的 URI 编码问题。写入哪个库的文件，就自动定位到哪个库，无需硬编码。

> **注意**：URI 版要求对应 vault 的标签页在 Obsidian 中处于打开状态，否则 Obsidian 的 workspace 恢复可能覆盖文件导航。

## 安装

1. 选择你想要的版本，复制 `.sh` 文件到任意位置，如 `~/.claude/`：

```bash
cp auto-open-obsidian.sh ~/.claude/     # CLI 版
# 或
cp auto-open-obsidian-uri.sh ~/.claude/auto-open-obsidian.sh  # URI 版
```

2. 在 `~/.claude/settings.json` 的 `hooks.PostToolUse` 数组中加入：

```json
{
  "matcher": "Edit|Write",
  "hooks": [
    {
      "type": "command",
      "command": "~/.claude/auto-open-obsidian.sh",
      "timeout": 3
    }
  ]
}
```

3. 重启 Claude Code。

## 前置条件

- **Obsidian CLI**（CLI 版必需，URI 版可选）：Obsidian v1.12+ 内置。启用方法：Obsidian → 设置 → Command Line Interface → 打开开关
- **Obsidian 建议保持运行**，否则首次启动后 vault 恢复可能覆盖文件导航

## 配置

脚本会自动从文件所在目录往上查找 `.obsidian` 目录来判断 vault，通常无需手动配置。

如需强制指定 vault 路径：

```bash
export OBSIDIAN_VAULT_PATH="/path/to/your/vault"
```

## 调试

查看运行日志：

```bash
tail -f /tmp/auto-open-obsidian.log
```

## 目录结构

```
obsidian-auto-open-hook/
├── auto-open-obsidian.sh        # CLI 版（原版）
├── auto-open-obsidian-uri.sh    # URI 版（多 vault 支持）
├── README.md
└── LICENSE
```

## 许可

MIT License
