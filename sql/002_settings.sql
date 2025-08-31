-- Settings and hero images

CREATE TABLE IF NOT EXISTS settings (
  id INTEGER PRIMARY KEY DEFAULT 1,
  menu_title_ar TEXT NOT NULL DEFAULT 'المنيو',
  menu_title_en TEXT NOT NULL DEFAULT 'Menu',
  menu_title_tr TEXT NOT NULL DEFAULT 'Menü',
  hero_text_ar TEXT DEFAULT '',
  hero_text_en TEXT DEFAULT '',
  hero_text_tr TEXT DEFAULT ''
);

-- ensure single row exists
INSERT INTO settings (id)
VALUES (1)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS hero_images (
  id SERIAL PRIMARY KEY,
  url TEXT NOT NULL,
  sort_order INT DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE
);