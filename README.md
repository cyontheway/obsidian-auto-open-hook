# Claude Hooks

Claude Code Hooks 集合，方便发布和管理。

## 目录结构

```
claude-hooks/
├── hooks/              # Hook 脚本
│   └── auto-open-obsidian/
│       ├── hook.sh     # Hook 脚本
│       └── settings.json # 配置示例
├── CLAUDE.md           # 项目说明
└── README.md           # 本文件
```

## 已收录 Hooks

### auto-open-obsidian

Edit/Write Obsidian 笔记后，自动在 Obsidian 中打开文件。

**功能：**
- 只响应 `.md` 文件
- 自动转换相对路径为绝对路径
- 后台执行，不阻塞工作流
- 完整的日志记录

**安装：**

1. 复制 `hooks/auto-open-obsidian/hook.sh` 到 `~/.claude/hooks/auto-open-obsidian/hook.sh`
2. 复制 `hooks/auto-open-obsidian/settings.json` 到 `~/.claude/settings.json`（或合并到现有配置）
3. 重启 Claude Code

**配置 Vault 路径（必须）：**

方式一：设置环境变量（推荐）

```bash
# 在终端或 shell 配置文件中添加
export OBSIDIAN_VAULT_PATH="/path/to/your/obsidian/vault"
```

方式二：不设置 — hook 会自动从 `obsidian vault list` 取第一个 vault

**调试：**

```bash
tail -f /tmp/auto-open-obsidian.log
```

## 贡献新 Hook

欢迎提交 PR！每个 Hook 放在 `hooks/<hook-name>/` 下，包含：
- `hook.sh` — Hook 脚本
- `settings.json` — 配置示例
- `README.md` — 使用说明（如需要）
