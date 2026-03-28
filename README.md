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

1. 复制 hook.sh 到 `~/.claude/hooks/auto-open-obsidian/hook.sh`
2. 在 `~/.claude/settings.json` 中添加配置（参考 `hooks/auto-open-obsidian/settings.json`）
3. 重启 Claude Code

**调试：**

```bash
tail -f /tmp/auto-open-obsidian.log
```

## 贡献新 Hook

欢迎提交 PR！每个 Hook 放在 `hooks/<hook-name>/` 下，包含：
- `hook.sh` — Hook 脚本
- `settings.json` — 配置示例
- `README.md` — 使用说明（如需要）
