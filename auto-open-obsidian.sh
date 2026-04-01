#!/bin/bash
# auto-open-obsidian.sh — PostToolUse hook
# 自动在 Edit/Write 后打开 Obsidian 文件
#
# ⚠️ 多 Vault 限制：Obsidian CLI 只能操作当前活跃连接的 vault。
#    如果你同时开着多个 vault，hook 只会打开当前活跃 vault 里的文件。
#    文件在非活跃 vault 时会被静默跳过。
#    如果只用一个 vault，则无此限制。
#
#    如需强制指定 vault，设置环境变量：
#      export OBSIDIAN_VAULT_PATH="/path/to/your/vault"
#    并取消下方 vault 参数的注释。

LOG="/tmp/auto-open-obsidian.log"
echo "[$(date '+%H:%M:%S')] Hook triggered" >> "$LOG"

# 读取 stdin JSON（只读一次，保存到变量）
STDIN_JSON=$(cat)
echo "[$(date '+%H:%M:%S')] Input received" >> "$LOG"

# 提取 tool_name
TOOL_NAME=$(echo "$STDIN_JSON" | python3 -c "import sys,json; print(json.loads(sys.stdin.read()).get('tool_name',''))" 2>/dev/null)
echo "[$(date '+%H:%M:%S')] Tool: $TOOL_NAME" >> "$LOG"

# 提取 cwd（所有工具通用）
CWD=$(echo "$STDIN_JSON" | python3 -c "
import sys, json
try:
    data = json.loads(sys.stdin.read())
    print(data.get('cwd', ''))
except:
    pass
" 2>/dev/null)

# 根据工具类型提取文件路径
if [ "$TOOL_NAME" = "Edit" ] || [ "$TOOL_NAME" = "Write" ]; then
  # Edit/Write: 直接从 tool_input.file_path 提取
  FILE_PATH=$(echo "$STDIN_JSON" | python3 -c "
import sys, json
try:
    data = json.loads(sys.stdin.read())
    params = data.get('tool_input', {})
    print(params.get('file_path', ''))
except:
    pass
" 2>/dev/null)

elif [ "$TOOL_NAME" = "Bash" ]; then
  # Bash: 从 command 中提取文件路径（仅处理 sed -i 场景）
  BASH_CMD=$(echo "$STDIN_JSON" | python3 -c "
import sys, json
try:
    data = json.loads(sys.stdin.read())
    print(data.get('tool_input', {}).get('command', ''))
except:
    pass
" 2>/dev/null)

  # 只处理 sed -i（原地修改文件）
  if echo "$BASH_CMD" | grep -qE 'sed.*-i'; then
    FILE_PATH=$(echo "$BASH_CMD" | python3 -c "
import sys, shlex
try:
    parts = shlex.split(sys.stdin.read().strip())
    # 去掉管道后面的部分
    for i, p in enumerate(parts):
        if p == '|': parts = parts[:i]; break
    # 最后一个参数通常是文件路径
    if parts:
        candidate = parts[-1].strip(\"\\\"'\")
        if candidate.endswith('.md'):
            print(candidate)
except:
    pass
" 2>/dev/null)
    echo "[$(date '+%H:%M:%S')] Bash sed detected, file: $FILE_PATH" >> "$LOG"
  else
    echo "[$(date '+%H:%M:%S')] Skip: Bash but not sed -i" >> "$LOG"
    exit 0
  fi

else
  echo "[$(date '+%H:%M:%S')] Skip: not Edit/Write/Bash" >> "$LOG"
  exit 0
fi

echo "[$(date '+%H:%M:%S')] File: $FILE_PATH, CWD: $CWD" >> "$LOG"

# 检查是否是 .md 文件
if [ -z "$FILE_PATH" ] || [[ ! "$FILE_PATH" == *.md ]]; then
  echo "[$(date '%H:%M:%S')] Skip: not .md or empty path" >> "$LOG"
  exit 0
fi

# 转换相对路径为绝对路径
if [[ "$FILE_PATH" != /* ]]; then
  FILE_PATH="$CWD/$FILE_PATH"
  echo "[$(date '+%H:%M:%S')] Converted to absolute: $FILE_PATH" >> "$LOG"
fi

# 获取 Vault 路径
# 方式 1：环境变量（强制指定，适合只用一个 vault 的用户）
#   export OBSIDIAN_VAULT_PATH="/path/to/your/vault"
# 方式 2：从文件所在目录往上找 .obsidian 目录（自动检测）
VAULT_PATH="${OBSIDIAN_VAULT_PATH:-}"

if [ -z "$VAULT_PATH" ]; then
  CHECK_DIR=$(dirname "$FILE_PATH")
  while [ "$CHECK_DIR" != "/" ] && [ "$CHECK_DIR" != "$HOME" ]; do
    if [ -d "$CHECK_DIR/.obsidian" ]; then
      VAULT_PATH="$CHECK_DIR"
      break
    fi
    CHECK_DIR=$(dirname "$CHECK_DIR")
  done
fi

if [ -z "$VAULT_PATH" ]; then
  echo "[$(date '+%H:%M:%S')] Skip: file not in any Obsidian vault" >> "$LOG"
  exit 0
fi

echo "[$(date '+%H:%M:%S')] Vault: $VAULT_PATH" >> "$LOG"

# 检查文件是否在 vault 内
if [[ ! "$FILE_PATH" == "$VAULT_PATH"* ]]; then
  echo "[$(date '+%H:%M:%S')] Skip: not in vault ($VAULT_PATH)" >> "$LOG"
  exit 0
fi

# 转换为相对路径
REL_PATH="${FILE_PATH#$VAULT_PATH/}"
echo "[$(date '+%H:%M:%S')] Opening: $REL_PATH" >> "$LOG"

# 打开文件
# Obsidian CLI 只能操作当前活跃连接的 vault，不指定 vault 参数。
# path= 按相对路径精确匹配，避免同名文件冲突。
obsidian open path="$REL_PATH" >/dev/null 2>&1 &

# 如需强制指定 vault（取消注释）：
# VAULT_NAME=$(basename "$VAULT_PATH")
# obsidian open vault="$VAULT_NAME" path="$REL_PATH" >/dev/null 2>&1 &

echo "[$(date '+%H:%M:%S')] Done" >> "$LOG"

exit 0
