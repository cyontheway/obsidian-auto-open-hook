#!/bin/bash
# auto-open-obsidian-uri.sh — PostToolUse hook (URI version)
# 自动在 Edit/Write 后打开 Obsidian 文件
#
# 【URI 版本】使用 obsidian:// URI scheme 打开文件。
# - 自动检测文件所在 vault
# - 从 obsidian.json 查 vault ID，避免中文路径问题
# - 不走 Obsidian CLI 的活跃 vault 连接限制
# - 适合多 vault 同时运行的场景
#
# 如需手动指定 vault 路径（覆盖自动检测），设置环境变量：
#   export OBSIDIAN_VAULT_PATH="/path/to/your/vault"
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
# 使用 obsidian:// URI scheme 打开，绕过 CLI 的活跃 vault 连接限制
# 从 obsidian.json 查找 vault ID 用于 URI（比文件夹名更可靠）
VAULT_NAME=$(basename "$VAULT_PATH")
OBSIDIAN_CONFIG="$HOME/Library/Application Support/obsidian/obsidian.json"
VAULT_ID=$(python3 -c "
import json, os
config = os.path.expanduser('$OBSIDIAN_CONFIG')
try:
    with open(config) as f:
        vaults = json.load(f).get('vaults', {})
    for vid, vinfo in vaults.items():
        if vinfo.get('path', '') == '$VAULT_PATH':
            print(vid)
            raise SystemExit(0)
except: pass
print('$VAULT_NAME')
")
OBSIDIAN_URI=$(python3 -c "
import urllib.parse
vault = urllib.parse.quote('$VAULT_ID', safe='')
path  = urllib.parse.quote('$REL_PATH', safe='/')
print(f'obsidian://open?vault={vault}&file={path}')
")
open "$OBSIDIAN_URI" >/dev/null 2>&1 &

# obsidian:// URI 会自动把 Obsidian 带到前台，无需额外 open -a

echo "[$(date '+%H:%M:%S')] Done" >> "$LOG"

exit 0
