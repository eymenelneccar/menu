export const json = (status, body) => ({
  statusCode: status,
  headers: {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type,Authorization'
  },
  body: JSON.stringify(body)
});

export const ok = (body) => json(200, body);
export const bad = (err, code = 400) => json(code, { error: err?.message || String(err) });
export const notFound = () => json(404, { error: 'Not found' });

export function parseBody(event) {
  try {
    return event.body ? JSON.parse(event.body) : {};
  } catch (e) {
    return {};
  }
}