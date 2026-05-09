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

### CLI 版 `auto-open-obsidian.sh`

依赖 Obsidian CLI 的 `obsidian open` 命令。只能连接到**当前活跃的 vault**。

**优点**：简单，无额外依赖。
**局限**：
- 多 vault 同时打开时，无法控制 CLI 连接到哪个 vault
- 要么接受连到哪个开哪个（方案 A），要么硬编码写死一个库（方案 B）
- 硬编码后，写其他库的文件会被静默跳过

### URI 版 `auto-open-obsidian-uri.sh`

使用 `obsidian://` URI scheme 打开文件，不走 CLI 连接限制。自动从 `obsidian.json` 查找 vault ID，写入哪个库就打开哪个库。

**优点**：
- 多 vault 自动匹配，无需配置
- 中文路径自动 URL encode
- Obsidian 未运行时也可自动启动

**局限**：
- 极少数 vault 因 workspace/homepage 配置，在vault关闭时触发 hook 可能被配置恢复覆盖跳转，但 vault 打开后不受影响

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

### 焦点行为

`auto-open-obsidian.sh` 默认会执行 `open -a Obsidian` 把 Obsidian 切到前台。如果觉得每次编辑都抢焦点烦人，注释或删除脚本中 `open -a Obsidian` 那行即可，CLI 开文件不受影响。

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
