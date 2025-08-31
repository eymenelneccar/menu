CREATE TABLE IF NOT EXISTS categories (
  id SERIAL PRIMARY KEY,
  name_ar TEXT NOT NULL,
  name_en TEXT NOT NULL,
  name_tr TEXT NOT NULL,
  image_url TEXT NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  sort_order INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS menu_items (
  id SERIAL PRIMARY KEY,
  name_ar TEXT NOT NULL,
  name_en TEXT NOT NULL,
  name_tr TEXT NOT NULL,
  price NUMERIC(10,2) NOT NULL,
  image_url TEXT NOT NULL,
  category_id INT REFERENCES categories(id) ON DELETE CASCADE,
  is_available BOOLEAN DEFAULT TRUE
);
