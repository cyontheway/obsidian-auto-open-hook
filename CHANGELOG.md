# Changelog

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
