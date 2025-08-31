import { Router } from "express";
import { pool } from "../db.js";
const router = Router();

router.get("/", async (req, res) => {
  try {
    const { rows } = await pool.query("SELECT * FROM menu_items");
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Create a new menu item
router.post("/", async (req, res) => {
  try {
    const { name_ar, name_en, name_tr, price, image_url, category_id, is_available } = req.body;
    if (!name_ar || !name_en || !name_tr || !price || !image_url || !category_id) {
      return res.status(400).json({ error: "Missing required fields" });
    }
    const { rows } = await pool.query(
      `INSERT INTO menu_items (name_ar, name_en, name_tr, price, image_url, category_id, is_available)
       VALUES ($1,$2,$3,$4,$5,$6, COALESCE($7, TRUE)) RETURNING *`,
      [name_ar, name_en, name_tr, price, image_url, category_id, is_available]
    );
    res.status(201).json(rows[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Update an existing menu item
router.put("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { name_ar, name_en, name_tr, price, image_url, category_id, is_available } = req.body;

    const { rows } = await pool.query(
      `UPDATE menu_items SET
         name_ar = COALESCE($1, name_ar),
         name_en = COALESCE($2, name_en),
         name_tr = COALESCE($3, name_tr),
         price = COALESCE($4, price),
         image_url = COALESCE($5, image_url),
         category_id = COALESCE($6, category_id),
         is_available = COALESCE($7, is_available)
       WHERE id = $8
       RETURNING *`,
      [name_ar, name_en, name_tr, price, image_url, category_id, is_available, id]
    );

    if (!rows.length) return res.status(404).json({ error: "Not found" });
    res.json(rows[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Delete a menu item
router.delete("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { rowCount } = await pool.query("DELETE FROM menu_items WHERE id=$1", [id]);
    if (!rowCount) return res.status(404).json({ error: "Not found" });
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

export default router;
