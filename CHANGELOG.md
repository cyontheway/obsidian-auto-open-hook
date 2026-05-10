# Changelog

## 2026-05-11

### 修复：CLI 版跨 vault 相对路径问题

- `obsidian open path="$REL_PATH"` 解析相对路径时基于当前 cwd，当 hook 从其他 vault 目录触发时，相对路径找不到文件
- 修复：执行 `obsidian open` 前先 `cd "$VAULT_PATH"`，确保路径从 vault 根目录解析
- 同步更新 `~/.claude/auto-open-obsidian.sh`

## 2026-05-08

### 新增：URI 版（auto-open-obsidian-uri.sh）

新增第二个 hook 版本，使用 `obsidian://` URI scheme 而非 Obsidian CLI 打开文件。

**区别**：
- CLI 版（原版）依赖 `obsidian open` 命令，只能连接当前活跃 vault
- URI 版从 `obsidian.json` 查找 vault ID 构建 URI，不依赖 CLI 连接状态

**URI 版细节**：
- vault ID 查找失败时自动回退使用文件夹名
- vault 和 file 参数中的中文/特殊字符通过 Python `urllib.parse.quote` 做 URL encode
- 不再保留额外的 `open -a Obsidian`（URI 本身会自动带到前台）

### 变更：README 重构

- 新增两个版本的对比说明和表格
- 将原多 vault 限制的警告改为客观描述
