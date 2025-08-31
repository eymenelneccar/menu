import { Router } from "express";
import { pool } from "../db.js";

const router = Router();

// Get settings (single row with id=1)
router.get('/', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM settings WHERE id=1');
    if (!rows.length){
      // Ensure row exists
      const { rows: created } = await pool.query("INSERT INTO settings (id) VALUES (1) ON CONFLICT (id) DO NOTHING RETURNING *");
      if (created && created.length) return res.json(created[0]);
      const { rows: again } = await pool.query('SELECT * FROM settings WHERE id=1');
      return res.json(again[0] || {});
    }
    res.json(rows[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Update settings
router.put('/', async (req, res) => {
  try {
    const {
      menu_title_ar, menu_title_en, menu_title_tr,
      hero_text_ar, hero_text_en, hero_text_tr,
      app_title_ar, app_title_en, app_title_tr,
      subtitle_ar, subtitle_en, subtitle_tr,
      view_menu_label_ar, view_menu_label_en, view_menu_label_tr,
      order_now_label_ar, order_now_label_en, order_now_label_tr,
    } = req.body;

    const { rows } = await pool.query(
      `UPDATE settings SET
        menu_title_ar = COALESCE($1, menu_title_ar),
        menu_title_en = COALESCE($2, menu_title_en),
        menu_title_tr = COALESCE($3, menu_title_tr),
        hero_text_ar = COALESCE($4, hero_text_ar),
        hero_text_en = COALESCE($5, hero_text_en),
        hero_text_tr = COALESCE($6, hero_text_tr),
        app_title_ar = COALESCE($7, app_title_ar),
        app_title_en = COALESCE($8, app_title_en),
        app_title_tr = COALESCE($9, app_title_tr),
        subtitle_ar = COALESCE($10, subtitle_ar),
        subtitle_en = COALESCE($11, subtitle_en),
        subtitle_tr = COALESCE($12, subtitle_tr),
        view_menu_label_ar = COALESCE($13, view_menu_label_ar),
        view_menu_label_en = COALESCE($14, view_menu_label_en),
        view_menu_label_tr = COALESCE($15, view_menu_label_tr),
        order_now_label_ar = COALESCE($16, order_now_label_ar),
        order_now_label_en = COALESCE($17, order_now_label_en),
        order_now_label_tr = COALESCE($18, order_now_label_tr)
       WHERE id = 1
       RETURNING *`,
      [
        menu_title_ar, menu_title_en, menu_title_tr,
        hero_text_ar, hero_text_en, hero_text_tr,
        app_title_ar, app_title_en, app_title_tr,
        subtitle_ar, subtitle_en, subtitle_tr,
        view_menu_label_ar, view_menu_label_en, view_menu_label_tr,
        order_now_label_ar, order_now_label_en, order_now_label_tr,
      ]
    );
    if (!rows.length){
      await pool.query('INSERT INTO settings (id) VALUES (1) ON CONFLICT (id) DO NOTHING');
      const { rows: again } = await pool.query('SELECT * FROM settings WHERE id=1');
      // bump version as well
      global.__CONFIG_VERSION = Date.now();
      return res.json(again[0] || {});
    }
    // bump version on success
    global.__CONFIG_VERSION = Date.now();
    res.json(rows[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

export default router;