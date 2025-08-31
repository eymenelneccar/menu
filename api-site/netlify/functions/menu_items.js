import { pool } from './db.mjs';
import { ok, bad, notFound, parseBody } from './utils.mjs';

function extractId(event){
  const p = event.path || '';
  const m = p.match(/\/\.netlify\/functions\/menu_items\/?(\d+)?$/);
  return m && m[1] ? Number(m[1]) : null;
}

export async function handler(event){
  try{
    const method = event.httpMethod;
    if (method === 'OPTIONS') return ok({ ok:true });

    if (method === 'GET'){
      const { rows } = await pool.query('SELECT * FROM menu_items');
      return ok(rows);
    }

    if (method === 'POST'){
      const { name_ar, name_en, name_tr, price, image_url, category_id, is_available } = parseBody(event);
      if (!name_ar || !name_en || !name_tr || !price || !image_url || !category_id) {
        return bad('Missing required fields', 400);
      }
      const { rows } = await pool.query(
        `INSERT INTO menu_items (name_ar, name_en, name_tr, price, image_url, category_id, is_available)
         VALUES ($1,$2,$3,$4,$5,$6, COALESCE($7, TRUE)) RETURNING *`,
        [name_ar, name_en, name_tr, price, image_url, category_id, is_available]
      );
      return { statusCode:201, headers:{'Content-Type':'application/json','Access-Control-Allow-Origin':'*'}, body: JSON.stringify(rows[0]) };
    }

    if (method === 'PUT'){
      const id = extractId(event);
      if (!id) return bad('Missing id in path', 400);
      const { name_ar, name_en, name_tr, price, image_url, category_id, is_available } = parseBody(event);
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
      if (!rows.length) return notFound();
      return ok(rows[0]);
    }

    if (method === 'DELETE'){
      const id = extractId(event);
      if (!id) return bad('Missing id in path', 400);
      const { rowCount } = await pool.query('DELETE FROM menu_items WHERE id=$1', [id]);
      if (!rowCount) return notFound();
      return ok({ ok:true });
    }

    return bad('Method not allowed', 405);
  }catch(e){
    return bad(e, 500);
  }
}