import { ok } from './utils.mjs';

export async function handler(event) {
  if (event.httpMethod === 'OPTIONS') return ok({ ok: true });
  return ok({ ok: true, source: 'netlify-functions' });
}