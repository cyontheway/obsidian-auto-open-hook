#!/bin/bash
# auto-open-obsidian.sh — PostToolUse hook
# 自动在 Edit/Write 后打开 Obsidian 文件

LOG="/tmp/auto-open-obsidian.log"
echo "[$(date '+%H:%M:%S')] Hook triggered" >> "$LOG"

# 读取 stdin JSON（只读一次，保存到变量）
STDIN_JSON=$(cat)
echo "[$(date '+%H:%M:%S')] Input received" >> "$LOG"

# 提取 tool_name
TOOL_NAME=$(echo "$STDIN_JSON" | python3 -c "import sys,json; print(json.loads(sys.stdin.read()).get('tool_name',''))" 2>/dev/null)
echo "[$(date '+%H:%M:%S')] Tool: $TOOL_NAME" >> "$LOG"

# 只处理 Edit 和 Write
if [ "$TOOL_NAME" != "Edit" ] && [ "$TOOL_NAME" != "Write" ]; then
  echo "[$(date '+%H:%M:%S')] Skip: not Edit/Write" >> "$LOG"
  exit 0
fi

# 提取 file_path 和 cwd
FILE_PATH=$(echo "$STDIN_JSON" | python3 -c "
import sys, json
try:
    data = json.loads(sys.stdin.read())
    params = data.get('tool_input', {})
    print(params.get('file_path', ''))
except:
    pass
" 2>/dev/null)

CWD=$(echo "$STDIN_JSON" | python3 -c "
import sys, json
try:
    data = json.loads(sys.stdin.read())
    print(data.get('cwd', ''))
except:
    pass
" 2>/dev/null)

echo "[$(date '+%H:%M:%S')] File: $FILE_PATH, CWD: $CWD" >> "$LOG"

# 检查是否是 .md 文件
if [ -z "$FILE_PATH" ] || [[ ! "$FILE_PATH" == *.md ]]; then
  echo "[$(date '+%H:%M:%S')] Skip: not .md or empty path" >> "$LOG"
  exit 0
fi

# 转换相对路径为绝对路径
if [[ "$FILE_PATH" != /* ]]; then
  FILE_PATH="$CWD/$FILE_PATH"
  echo "[$(date '+%H:%M:%S')] Converted to absolute: $FILE_PATH" >> "$LOG"
fi

# 获取 Vault 路径（支持多 vault）
# 方式 1：环境变量（推荐）
#   export OBSIDIAN_VAULT_PATH="/path/to/your/vault"
# 方式 2：从 obsidian CLI 配置推断（默认取第一个 vault）
VAULT_PATH="${OBSIDIAN_VAULT_PATH:-}"

if [ -z "$VAULT_PATH" ]; then
  # 从 obsidian CLI 获取 vault 列表的第一个
  VAULT_PATH=$(obsidian vault list 2>/dev/null | head -1 | sed 's/^.*: //')
fi

if [ -z "$VAULT_PATH" ]; then
  echo "[$(date '+%H:%M:%S')] Error: OBSIDIAN_VAULT_PATH not set and cannot detect vault" >> "$LOG"
  exit 1
fi

echo "[$(date '+%H:%M:%S')] Vault: $VAULT_PATH" >> "$LOG"

# 检查是否在目标 Vault 内
if [[ ! "$FILE_PATH" == "$VAULT_PATH"* ]]; then
  echo "[$(date '+%H:%M:%S')] Skip: not in target vault ($VAULT_PATH)" >> "$LOG"
  exit 0
fi

# 转换为相对路径
REL_PATH="${FILE_PATH#$VAULT_PATH/}"
echo "[$(date '+%H:%M:%S')] Opening: $REL_PATH" >> "$LOG"

# 打开文件（静默执行，不阻塞）
obsidian open file="$REL_PATH" >/dev/null 2>&1 &
echo "[$(date '+%H:%M:%S')] Done" >> "$LOG"

exit 0
