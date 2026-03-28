# Claude Hooks

个人Claude Code Hooks 集合 / Collection of Personal Claude Code Hooks

## 目录 / Table of Contents

- [auto-open-obsidian](#auto-open-obsidian)
- [目录结构 / Directory Structure](#目录结构--directory-structure)
- [使用许可 / License](#使用许可--license)

---

## auto-open-obsidian

因为用 ob 比较多，让cc操作ob是很方便，但是每次ta改完笔记我要去ob手动打开 .md，略烦（即使开了同屏还是要自己操作下）。所以让cc给写了这 Hook 自动打开.md文件。这句没有翻译。

Edit/Write Obsidian 笔记后，自动在 Obsidian 中打开文件。/ Auto-open .md files in Obsidian after Edit/Write.

### 功能 / Features

- 只响应 `.md` 文件 / Only responds to `.md` files
- 自动转换相对路径为绝对路径 / Auto-convert relative paths to absolute
- 后台执行，不阻塞工作流 / Non-blocking background execution
- 完整的日志记录 / Full logging

### 安装 / Installation

1. 复制 `hooks/auto-open-obsidian/hook.sh` 到 `~/.claude/hooks/auto-open-obsidian/hook.sh`
   / Copy `hook.sh` to `~/.claude/hooks/auto-open-obsidian/hook.sh`

2. 在 `~/.claude/settings.json` 中添加配置（参考 `hooks/auto-open-obsidian/settings.json`）
   / Add config to `~/.claude/settings.json` (see `settings.json` for reference)

3. 重启 Claude Code / Restart Claude Code

### 配置 Vault 路径 / Configure Vault Path

**方式一：环境变量（推荐）/ Method 1: Environment Variable (Recommended)**

```bash
# 在终端或 shell 配置文件中添加 / Add to terminal or shell config
export OBSIDIAN_VAULT_PATH="/path/to/your/obsidian/vault"
```

**方式二：不设置 / Method 2: No Config**

不设置则自动从 `obsidian vault list` 取第一个 vault / If not set, auto-detects first vault from `obsidian vault list`

### 调试 / Debugging

```bash
tail -f /tmp/auto-open-obsidian.log
```

---

## 目录结构 / Directory Structure

```
claude-hooks/
├── hooks/                      # Hook 脚本 / Hook scripts
│   └── auto-open-obsidian/
│       ├── hook.sh             # Hook 脚本 / Hook script
│       └── settings.json       # 配置示例 / Config example
├── .gitignore
├── CLAUDE.md                   # 项目说明 / Project notes
├── LICENSE                     # MIT License
└── README.md                   # 本文件 / This file
```

---

## 使用许可 / License

本项目采用 MIT License开源，可自由使用、修改、分发。/ This project is open source under MIT License. Free to use, modify, and distribute.

完整许可文本见 `LICENSE` 文件。/ See `LICENSE` file for full license text.
