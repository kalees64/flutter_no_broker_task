import { createApp } from "./app.js";
import { env } from "./config/env.js";
import { pool } from "./database/pool.js";

const app = createApp();

async function startServer() {
  try {
    // 1. Verify PostgreSQL connection
    const testResult = await pool.query("SELECT NOW() as current_time;");
    console.log("✅ Connected to PostgreSQL database:", env.DB_NAME);
    console.log("🕒 Database time:", testResult.rows[0].current_time);

    // 2. Start HTTP server
    const server = app.listen(env.PORT, () => {
      console.log(`🚀 Server is running on port ${env.PORT}`);
      console.log(`📡 Base API URL: http://localhost:${env.PORT}/api/v1`);
      console.log(`📄 Swagger UI: http://localhost:${env.PORT}/api/v1/docs`);
      console.log(`🩺 Health check: http://localhost:${env.PORT}/health`);
    });

    // 3. Graceful shutdown handler
    const shutdown = async (signal: string) => {
      console.log(`\n🛑 Received ${signal}. Gracefully shutting down...`);
      server.close(async () => {
        console.log("🔌 HTTP server closed.");
        await pool.end();
        console.log("📦 Database connection pool closed.");
        process.exit(0);
      });
    };

    process.on("SIGTERM", () => shutdown("SIGTERM"));
    process.on("SIGINT", () => shutdown("SIGINT"));
  } catch (error) {
    console.error("❌ Failed to start server:", error);
    process.exit(1);
  }
}

startServer();
