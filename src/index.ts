import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { SSEServerTransport } from "@modelcontextprotocol/sdk/server/sse.js";
import express from "express";
import { z } from "zod";
const app = express();
// 解析 JSON Body，MCP 訊息需要這個
app.use(express.json());

const server = new McpServer({
  name: "Moltbot-Custom-Skills",
  version: "1.0.0",
});

// 1. Google Workspace
server.tool("google_workspace", {
  action: z.enum(["search_drive", "send_gmail", "list_calendar"]),
  query: z.string(),
}, async ({ action, query }) => {
  return { content: [{ type: "text", text: `Google Workspace ${action} 執行：${query}` }] };
});

// 2. 語音
server.tool("transcribe_audio", {
  fileUrl: z.string().url(),
}, async ({ fileUrl }) => {
  return { content: [{ type: "text", text: "語音轉文字模擬結果" }] };
});

// 3. 影片
server.tool("analyze_video", {
  videoUrl: z.string().url(),
  question: z.string(),
}, async ({ videoUrl, question }) => {
  return { content: [{ type: "text", text: `影片分析模擬結果: ${question}` }] };
});

// 4. Notion
server.tool("notion_manager", {
  operation: z.enum(["create_page", "search_docs"]),
  content: z.string(),
}, async ({ operation, content }) => {
  return { content: [{ type: "text", text: `Notion ${operation} 已模擬執行` }] };
});

// 5. Pinecone
server.tool("memory_vault", {
  action: z.enum(["store", "query"]),
  text: z.string(),
}, async ({ action, text }) => {
  return { content: [{ type: "text", text: `Pinecone ${action} 已模擬執行` }] };
});

let transport: SSEServerTransport | null = null;
// 在 src/index.ts 中導入 axios
import axios from "axios";
// 6. slack下載檔案
server.tool("transcribe_audio", {
  fileUrl: z.string().url(),
}, async ({ fileUrl }) => {
  try {
    // 判斷如果是來自 Slack 的網址，就帶上 Token 下載
    const response = await axios.get(fileUrl, {
      headers: { Authorization: `Bearer ${process.env.SLACK_BOT_TOKEN}` },
      responseType: 'arraybuffer'
    });
    
    // 這裡再把下載回來的二進位數據交給 OpenAI Whisper API
    return { content: [{ type: "text", text: "成功收到 Slack 檔案並開始轉譯..." }] };
  } catch (error) {
    return { content: [{ type: "text", text: `下載失敗: ${error.message}` }] };
  }
});
// SSE 端點
app.get("/sse", async (req, res) => {
  transport = new SSEServerTransport("/messages", res);
  await server.connect(transport);
});

// 訊息接收端點
app.post("/messages", async (req, res) => {
  if (transport) {
    await transport.handlePostMessage(req, res);
  } else {
    res.status(400).send("SSE transport not initialized");
  }
});

const PORT = process.env.PORT || 3000;
app.listen(Number(PORT), "0.0.0.0", () => {
  console.log(`MCP Server 正在 0.0.0.0:${PORT} 運行`);
});