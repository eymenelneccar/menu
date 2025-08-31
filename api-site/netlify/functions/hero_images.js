import { pool } from './db.mjs';
import { ok, bad, notFound, parseBody } from './utils.mjs';

function extractId(event){
  const p = event.path || '';
  const m = p.match(/\/\.netlify\/functions\/hero_images\/?(\d+)?$/);
  return m && m[1] ? Number(m[1]) : null;
}

export async function handler(event){
  try{
    const method = event.httpMethod;
    if (method === 'OPTIONS') return ok({ ok:true });

    if (method === 'GET'){
      const { rows } = await pool.query('SELECT * FROM hero_images ORDER BY is_active DESC, sort_order, id');
      return ok(rows);
    }

    if (method === 'POST'){
      // Only URL-based insert; file uploads are done directly to Cloudinary on client.
      const { url, sort_order, is_active } = parseBody(event);
      if (!url) return bad('url is required', 400);
      const { rows } = await pool.query(
        'INSERT INTO hero_images (url, sort_order, is_active) VALUES ($1, COALESCE($2,0), COALESCE($3, TRUE)) RETURNING *',
        [url, sort_order, is_active]
      );
      return { statusCode:201, headers:{'Content-Type':'application/json','Access-Control-Allow-Origin':'*'}, body: JSON.stringify(rows[0]) };
    }

    if (method === 'PUT'){
      const id = extractId(event);
      if (!id) return bad('Missing id in path', 400);
      const { url, sort_order, is_active } = parseBody(event);
      const { rows } = await pool.query(
        `UPDATE hero_images SET
          url = COALESCE($1, url),
          sort_order = COALESCE($2, sort_order),
          is_active = COALESCE($3, is_active)
         WHERE id=$4 RETURNING *`,
        [url, sort_order, is_active, id]
      );
      if(!rows.length) return notFound();
      return ok(rows[0]);
    }

    if (method === 'DELETE'){
      const id = extractId(event);
      if (!id) return bad('Missing id in path', 400);
      const { rowCount } = await pool.query('DELETE FROM hero_images WHERE id=$1', [id]);
      if(!rowCount) return notFound();
      return ok({ ok:true });
    }

    return bad('Method not allowed', 405);
  }catch(e){
    return bad(e, 500);
  }
}