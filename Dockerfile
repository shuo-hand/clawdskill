FROM node:20-slim

# 安裝系統依賴：ffmpeg (必備), python (為了某些 Skills), git
RUN apt-get update && apt-get install -y \
    ffmpeg \
    python3 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 安裝 pnpm
RUN npm install -g pnpm

# 複製專案檔案
COPY . .

# 安裝主程式依賴
RUN pnpm install

# 賦予啟動腳本權限
RUN chmod +x entrypoint.sh

# 執行你剛寫的那個啟動指令
CMD ["./entrypoint.sh"]