import { pool } from './db.mjs';
import { ok, bad, notFound, parseBody } from './utils.mjs';

function extractId(event){
  const p = event.path || '';
  const m = p.match(/\/\.netlify\/functions\/categories\/?(\d+)?$/);
  return m && m[1] ? Number(m[1]) : null;
}

export async function handler(event){
  try{
    const method = event.httpMethod;
    if (method === 'OPTIONS') return ok({ ok:true });

    if (method === 'GET'){
      const { rows } = await pool.query('SELECT * FROM categories ORDER BY sort_order, id');
      return ok(rows);
    }

    if (method === 'POST'){
      const { name_ar, name_en, name_tr, image_url, is_active, sort_order } = parseBody(event);
      const { rows } = await pool.query(
        'INSERT INTO categories (name_ar,name_en,name_tr,image_url,is_active,sort_order) VALUES ($1,$2,$3,$4, COALESCE($5, TRUE), COALESCE($6,0)) RETURNING *',
        [name_ar,name_en,name_tr,image_url,is_active,sort_order]
      );
      return { statusCode:201, headers:{'Content-Type':'application/json','Access-Control-Allow-Origin':'*'}, body: JSON.stringify(rows[0]) };
    }

    if (method === 'PUT'){
      const id = extractId(event);
      if (!id) return bad('Missing id in path', 400);
      const { name_ar, name_en, name_tr, image_url, is_active, sort_order } = parseBody(event);
      const { rows } = await pool.query(
        `UPDATE categories SET
           name_ar = COALESCE($1, name_ar),
           name_en = COALESCE($2, name_en),
           name_tr = COALESCE($3, name_tr),
           image_url = COALESCE($4, image_url),
           is_active = COALESCE($5, is_active),
           sort_order = COALESCE($6, sort_order)
         WHERE id = $7 RETURNING *`,
        [name_ar, name_en, name_tr, image_url, is_active, sort_order, id]
      );
      if (!rows.length) return notFound();
      return ok(rows[0]);
    }

    if (method === 'DELETE'){
      const id = extractId(event);
      if (!id) return bad('Missing id in path', 400);
      const { rowCount } = await pool.query('DELETE FROM categories WHERE id=$1', [id]);
      if (!rowCount) return notFound();
      return ok({ ok:true });
    }

    return bad('Method not allowed', 405);
  }catch(e){
    return bad(e, 500);
  }
}