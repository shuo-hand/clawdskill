#!/bin/sh

# 定義路徑
GIT_SKILLS_DIR="/app/skills"         # GitHub 傳上來、唯讀的路徑
PERSISTENT_WORKSPACE="/home/node/app/workspace" # 掛載 Volume 的路徑
ACTIVE_SKILLS_DIR="$PERSISTENT_WORKSPACE/skills"

echo "=== 正在同步 GitHub Skills 到持久化空間 ==="

# 確保目錄存在
mkdir -p "$ACTIVE_SKILLS_DIR"

# 關鍵：將 Git 的 Skills 同步到 Volume，但不刪除 Volume 裡原有的資料（如 MEMORY.md）
if [ -d "$GIT_SKILLS_DIR" ]; then
    cp -r $GIT_SKILLS_DIR/* "$ACTIVE_SKILLS_DIR/"
    echo "同步完成。路徑：$ACTIVE_SKILLS_DIR"
else
    echo "警告：找不到 Git Skills 目錄 $GIT_SKILLS_DIR"
fi

# 執行原有的環境變數設定與 Patch 邏輯...
# (保留你之前那段長長的 CONFIG_JSON 產生邏輯)

# 啟動 Moltbot，並明確指定工作目錄
exec node dist/index.js gateway --allow-unconfigured --workspace "$PERSISTENT_WORKSPACE"