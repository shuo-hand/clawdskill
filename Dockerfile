FROM node:20-slim

# 安裝影音處理必備工具
RUN apt-get update && apt-get install -y ffmpeg python3 python3-pip git curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 先安裝依賴
COPY package.json ./
RUN npm install

# 複製 tsconfig.json 和原始碼
COPY tsconfig.json ./
COPY src ./src

# 執行編譯
RUN npx tsc

# 暴露端口
EXPOSE 3000

# 啟動命令
CMD ["node", "dist/index.js"]