import { Router } from "express";
import { pool } from "../db.js";
import multer from "multer";
import path from "path";
import fs from "fs";
import { fileURLToPath } from "url";

const router = Router();

// Ensure upload directory exists
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
// Save uploads into the publicly served folder so Express static can serve them
const uploadsDir = path.join(__dirname, "../../public/uploads/hero");
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadsDir);
  },
  filename: function (req, file, cb) {
    const ext = path.extname(file.originalname) || ".jpg";
    const base = path.basename(file.originalname, ext).replace(/[^a-zA-Z0-9_-]/g, "_");
    const unique = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, `${base}-${unique}${ext}`);
  },
});

const upload = multer({ storage });

router.get('/', async (req, res) => {
  try{
    const { rows } = await pool.query('SELECT * FROM hero_images ORDER BY is_active DESC, sort_order, id');
    res.json(rows);
  }catch(e){ res.status(500).json({ error: e.message }); }
});

// New: upload a hero image file
router.post('/upload', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'file is required' });
    const sort_order = Number.parseInt(req.body.sort_order ?? '0', 10) || 0;
    const is_active = String(req.body.is_active ?? 'true') !== 'false';

    // Public URL path
    const publicPath = `/uploads/hero/${req.file.filename}`;

    const { rows } = await pool.query(
      'INSERT INTO hero_images (url, sort_order, is_active) VALUES ($1, $2, $3) RETURNING *',
      [publicPath, sort_order, is_active]
    );
    // bump version on success
    global.__CONFIG_VERSION = Date.now();
    res.status(201).json(rows[0]);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

router.post('/', async (req, res) => {
  try{
    const { url, sort_order, is_active } = req.body;
    if(!url) return res.status(400).json({ error: 'url is required' });
    const { rows } = await pool.query(
      'INSERT INTO hero_images (url, sort_order, is_active) VALUES ($1, COALESCE($2,0), COALESCE($3, TRUE)) RETURNING *',
      [url, sort_order, is_active]
    );
    // bump version on success
    global.__CONFIG_VERSION = Date.now();
    res.status(201).json(rows[0]);
  }catch(e){ res.status(500).json({ error: e.message }); }
});

router.put('/:id', async (req, res) => {
  try{
    const { id } = req.params;
    const { url, sort_order, is_active } = req.body;
    const { rows } = await pool.query(
      `UPDATE hero_images SET
        url = COALESCE($1, url),
        sort_order = COALESCE($2, sort_order),
        is_active = COALESCE($3, is_active)
       WHERE id=$4 RETURNING *`,
      [url, sort_order, is_active, id]
    );
    if(!rows.length) return res.status(404).json({ error: 'Not found' });
    // bump version on success
    global.__CONFIG_VERSION = Date.now();
    res.json(rows[0]);
  }catch(e){ res.status(500).json({ error: e.message }); }
});

router.delete('/:id', async (req, res) => {
  try{
    const { id } = req.params;
    const { rowCount } = await pool.query('DELETE FROM hero_images WHERE id=$1', [id]);
    if(!rowCount) return res.status(404).json({ error: 'Not found' });
    // bump version on success
    global.__CONFIG_VERSION = Date.now();
    res.json({ ok: true });
  }catch(e){ res.status(500).json({ error: e.message }); }
});

export default router;