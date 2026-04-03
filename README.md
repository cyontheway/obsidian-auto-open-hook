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

因为用 ob 比较多，让cc操作ob是很方便，但是每次ta改完笔记我要去ob手动打开 .md，略烦（即使开了同屏还是要自己操作下）。所以让cc给写了这个PostToolUse Hook，用Obsidian CLI 自动打开 Write|Edit 后的 .md 文件。我也考虑过PreToolUse的Hook，感觉会让 cc 太忙了，所以最后用的还是Post方案，改完再打开。另外，如果你也会用sed修改文件，可以把Bash sed放进去，注意settings.json里面的matcher要加上Bash。至于怎么相应调整 .sh 文件，直接问一下你的agent让他改就行了。

> [!Tip]
> 还有个tips，我因为不太开 VS Code，每次就是半盲改（终端看diff真的不习惯）SKILL.md 和 CLAUDE.md，然后我又很爱改，所以干脆把这些的原文件都放在自己常用的ob库下面，反过来在.claude目录下面只放软链接。配合着前面这个Hook，连改这些配置类的 .md 都丝滑起来了😁。
> 

> [!Note]
> **Obsidian CLI（前置条件 / Prerequisite）**
> 这个 Hook 用的是 **Obsidian CLI**（v1.12+ 内置）的 `obsidian open` 命令。理论上 `obsidian://open` URI scheme 也能实现同样效果，但 CLI 更简洁——URI 的 `file` 参数含中文/空格时需 URL encode，`vault` 参数用文件夹名无需 encode；CLI 则直接用原始路径，不用管编码。
>
> **启用方式**：Obsidian → Settings → Command Line Interface → 打开开关。详见 [官方文档](https://obsidian.md/help/cli)。
>
> **⚠️ Obsidian 必须在运行中**，否则 CLI 命令无法生效。
>
> This hook relies on **Obsidian CLI** (built into v1.12+). Enable: Obsidian → Settings → Command Line Interface → toggle on. See [official docs](https://obsidian.md/help/cli). **Obsidian must be running** for the CLI to work.

> [!Tip]
> **进阶 / Going Further**
> 如果你想让 Claude Code 做更多 Obsidian 操作（搜索、创建、移动笔记等），推荐安装 [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills/) 里的 obsidian-cli skill。装上后 CC 就能直接学会 Obsidian CLI 的各种用法，这个 Hook 只是个抛砖引玉。
> If you want Claude Code to do more with Obsidian (search, create, move notes, etc.), try obsidian-cli skill under [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills/). This hook is just a starting point。

### 功能 / Features

- 只响应 `.md` 文件 / Only responds to `.md` files
- 自动转换相对路径为绝对路径 / Auto-convert relative paths to absolute
- 使用 `path=` 精确匹配，不同子目录的同名文件不会冲突 / Uses `path=` for exact matching, no conflict with same-name files in different directories
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

脚本会自动从文件所在目录往上查找 `.obsidian` 目录来判断 vault，通常无需手动配置。

如需强制指定 vault 路径：
```bash
export OBSIDIAN_VAULT_PATH="/path/to/your/obsidian/vault"
```

> [!Warning]
> **多 Vault 限制 / Multi-Vault Limitation**
> 
> **Obsidian CLI 只能操作当前活跃连接的 vault**（通常是最后打开/聚焦的那个）。
>
> 如果你同时开着多个 vault：
> - Hook **只能打开当前活跃 vault 里的文件**
> - 文件在非活跃 vault 时会被静默跳过（日志中可见）
>
> **如果你只用一个 vault，完全没有这个问题。**
>
> 解决方案：在脚本底部取消 `vault=` 注释行，强制指定 vault 名。
>
> Obsidian CLI connects to one vault at a time (usually the last active one). If you run multiple vaults simultaneously, the hook can only open files in the currently active vault. To force a specific vault, uncomment the `vault=` lines at the bottom of the script. If you use a single vault, this is a non-issue.

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
