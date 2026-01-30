#!/bin/sh

echo "=== Setting up moltbot command ==="
# Setup moltbot command
WORKDIR="$(pwd)"
mkdir -p /home/node/bin
cat > /home/node/bin/moltbot << SCRIPT
#!/bin/sh
exec node ${WORKDIR}/dist/index.js "\$@"
SCRIPT
chmod +x /home/node/bin/moltbot
ln -sf /home/node/bin/moltbot /home/node/bin/clawdbot
export PATH="/home/node/bin:$PATH"
echo "moltbot command ready at /home/node/bin/moltbot"

# Patch pi-ai library
echo "=== Patching pi-ai library ==="
PI_AI_FILE="/app/node_modules/.pnpm/@mariozechner+pi-ai@"*"/node_modules/@mariozechner/pi-ai/dist/providers/google-gemini-cli.js"
if ls $PI_AI_FILE 1>/dev/null 2>&1; then
  sed -i 's|antigravity/1.11.5 darwin/arm64|antigravity/1.15.8 linux/amd64|g' $PI_AI_FILE
  echo "Patch applied."
else
  echo "pi-ai library not found, skipping patch"
fi

# ... (中間那段動態生成 $CONFIG_FILE 的 JSON 邏輯請完整保留在這邊) ...
# 注意：為了篇幅，我這裡省略中間那段長長的 CONFIG_JSON 邏輯，請你手動把原本腳本中 
# CONFIG_DIR 到 chmod 600 "$CONFIG_FILE" 的部分原封不動貼進來。

# === 新增：安裝 Skills 的依賴 (Python/Node) ===
echo "=== Setting up custom skills dependencies ==="
if [ -d "./skills" ]; then
  for skill_dir in ./skills/*; do
    if [ -d "$skill_dir" ]; then
      # 如果有 requirements.txt 就用 pip 安裝 (針對 Python Skills)
      if [ -f "$skill_dir/requirements.txt" ]; then
        echo "Installing Python dependencies for $(basename $skill_dir)..."
        pip install --no-cache-dir -r "$skill_dir/requirements.txt" || echo "Pip install failed."
      fi
      # 如果有 package.json 就用 pnpm 安裝 (針對 Node Skills)
      if [ -f "$skill_dir/package.json" ]; then
        echo "Installing Node dependencies for $(basename $skill_dir)..."
        pnpm install --prefix "$skill_dir" || echo "Pnpm install failed."
      fi
    fi
  done
fi

# === 初始化 Workspace ===
echo "=== Initializing workspace ==="
WORKSPACE_DIR="${CLAWDBOT_WORKSPACE_DIR}"
mkdir -p "$WORKSPACE_DIR/memory"
if [ ! -f "$WORKSPACE_DIR/MEMORY.md" ]; then
  echo "# Memory\n\nThis file stores long-term memories." > "$WORKSPACE_DIR/MEMORY.md"
fi

# 啟動主程式
echo "=== Starting Moltbot ==="
exec node dist/index.js gateway --allow-unconfigured --bind "${CLAWDBOT_GATEWAY_BIND}" --port "${CLAWDBOT_GATEWAY_PORT}" --token "${CLAWDBOT_GATEWAY_TOKEN}"