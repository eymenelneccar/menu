import "dotenv/config";
import express from "express";
import cors from "cors";
import morgan from "morgan";
import { pool } from "./db.js";
import categoriesRouter from "./routes/categories.js";
import menuItemsRouter from "./routes/menuItems.js";
import settingsRouter from "./routes/settings.js";
import heroImagesRouter from "./routes/heroImages.js";
import path from "path";
import { fileURLToPath } from "url";

const app = express();
app.use(cors());
app.use(express.json());
app.use(morgan("dev"));

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Replace landing route to serve HTML file
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "../public/index.html"));
});

app.get("/health", async (req, res) => {
  try {
    await pool.query("select 1");
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

// Simple version endpoint so frontend can detect config changes and auto-refresh
app.get("/version", (req, res) => {
  res.json({ version: global.__CONFIG_VERSION || 0 });
});

// Mount API routes BEFORE static to avoid 404 from static middleware
app.use("/categories", categoriesRouter);
app.use("/menu_items", menuItemsRouter);
app.use("/settings", settingsRouter);
app.use("/hero_images", heroImagesRouter);

// Serve static assets last
app.use(express.static(path.join(__dirname, "../public")));

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => console.log(`API running on http://localhost:${PORT}/`));
