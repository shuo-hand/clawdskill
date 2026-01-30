FROM node:20-slim

# 安裝系統依賴：ffmpeg (處理影音), python (備用)
RUN apt-get update && apt-get install -y \
    ffmpeg \
    python3 \
    python3-pip \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 安裝依賴
COPY package.json ./
RUN npm install

# 複製程式碼並編譯
COPY . .
RUN npx tsc

# 設定環境變數
ENV NODE_ENV=production
ENV PORT=3000

# 開放端口
EXPOSE 3000

CMD ["node", "dist/index.js"]