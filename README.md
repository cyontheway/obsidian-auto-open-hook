# Obsidian Auto Open Hook

Claude Code PostToolUse Hook：Edit/Write 后自动在 Obsidian 中打开 .md 文件 / Auto-open .md files in Obsidian after Edit/Write.

## 目录 / Table of Contents

- [安装 / Installation](#安装--installation)
- [配置 Vault 路径 / Configure Vault Path](#配置-vault-路径--configure-vault-path)
- [调试 / Debugging](#调试--debugging)
- [目录结构 / Directory Structure](#目录结构--directory-structure)
- [使用许可 / License](#使用许可--license)

---

## auto-open-obsidian

因为用 ob 比较多，让cc操作ob是很方便，但是每次ta改完笔记我要去ob手动打开 .md，略烦（即使开了同屏还是要自己操作下）。所以让cc给写了这个PostToolUse Hook 自动打开修改后的 .md 文件。我试过Pre的，感觉会让 cc 太忙了，所以最后用的还是Post方案，改完再打开。

> [!Tip]
> 还有个tips，我因为不太开 VS Code，每次就是半盲改（终端看diff真的不习惯）SKILL.md 和 CLAUDE.md，然后我又很爱改，所以干脆把这些的原文件都放在自己常用的ob库下面，反过来在.claude目录下面只放软链接。配合着前面这个Hook，连改这些配置类的 .md 都丝滑起来了😁。
> 

Edit/Write Obsidian 笔记后，自动在 Obsidian 中打开文件。/ Auto-open .md files in Obsidian after Edit/Write.

> [!note] Obsidian CLI
> 这个 Hook 的核心依赖是 [Obsidian CLI](https://github.com/obsidian-tasks-team/obsidian-cli)。它提供了 `obsidian open` 命令，让终端能直接在 Obsidian 中打开指定文件——比 macOS 的 `open` 命令更精准（直接定位到对应 vault 和文件，不会误开其他应用）。没有它这个 Hook 就做不了。
> This hook relies on [Obsidian CLI](https://github.com/obsidian-tasks-team/obsidian-cli), which provides the `obsidian open` command — more precise than macOS `open` (targets the exact vault and file, no wrong-app surprises). Without it, this hook wouldn't be possible.

### 功能 / Features

- 只响应 `.md` 文件 / Only responds to `.md` files
- 自动转换相对路径为绝对路径 / Auto-convert relative paths to absolute
- 后台执行，不阻塞工作流 / Non-blocking background execution
- 完整的日志记录 / Full logging

### 安装 / Installation

> [!tip]
> hook 放哪里都行，settings 里路径指对就行。放 `.claude` 根目录也行，不强制套目录。

1. 复制 `auto-open-obsidian.sh` 到任意位置，如 `~/.claude/auto-open-obsidian.sh`
   / Copy `auto-open-obsidian.sh` anywhere, e.g. `~/.claude/auto-open-obsidian.sh`

2. 在你 `~/.claude/settings.json` 的 `hooks.PostToolUse` 里加入（路径改成你实际的）：
   / Add to your `hooks.PostToolUse` array in `~/.claude/settings.json`:
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
obsidian-auto-open-hook/
├── auto-open-obsidian.sh           # Hook 脚本 / Hook script
├── README.md
├── LICENSE
└── .gitignore
```

---

## 使用许可 / License

本项目采用 MIT License开源，可自由使用、修改、分发。/ This project is open source under MIT License. Free to use, modify, and distribute.

完整许可文本见 `LICENSE` 文件。/ See `LICENSE` file for full license text.
