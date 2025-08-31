import { Router } from "express";
import { pool } from "../db.js";
const router = Router();

router.get("/", async (req, res) => {
  try {
    const { rows } = await pool.query("SELECT * FROM categories ORDER BY sort_order, id");
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

router.post("/", async (req, res) => {
  try {
    const { name_ar, name_en, name_tr, image_url, is_active, sort_order } = req.body;
    const { rows } = await pool.query(
      "INSERT INTO categories (name_ar,name_en,name_tr,image_url,is_active,sort_order) VALUES ($1,$2,$3,$4, COALESCE($5, TRUE), COALESCE($6,0)) RETURNING *",
      [name_ar,name_en,name_tr,image_url,is_active,sort_order]
    );
    res.status(201).json(rows[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Update a category
router.put("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { name_ar, name_en, name_tr, image_url, is_active, sort_order } = req.body;
    const { rows } = await pool.query(
      `UPDATE categories SET
         name_ar = COALESCE($1, name_ar),
         name_en = COALESCE($2, name_en),
         name_tr = COALESCE($3, name_tr),
         image_url = COALESCE($4, image_url),
         is_active = COALESCE($5, is_active),
         sort_order = COALESCE($6, sort_order)
       WHERE id = $7
       RETURNING *`,
      [name_ar, name_en, name_tr, image_url, is_active, sort_order, id]
    );
    if (!rows.length) return res.status(404).json({ error: "Not found" });
    res.json(rows[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Delete a category
router.delete("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { rowCount } = await pool.query("DELETE FROM categories WHERE id=$1", [id]);
    if (!rowCount) return res.status(404).json({ error: "Not found" });
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

export default router;
