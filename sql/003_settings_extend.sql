-- Extend settings with more UI-controllable texts
ALTER TABLE settings
  ADD COLUMN IF NOT EXISTS app_title_ar TEXT,
  ADD COLUMN IF NOT EXISTS app_title_en TEXT,
  ADD COLUMN IF NOT EXISTS app_title_tr TEXT,
  ADD COLUMN IF NOT EXISTS subtitle_ar TEXT,
  ADD COLUMN IF NOT EXISTS subtitle_en TEXT,
  ADD COLUMN IF NOT EXISTS subtitle_tr TEXT,
  ADD COLUMN IF NOT EXISTS view_menu_label_ar TEXT,
  ADD COLUMN IF NOT EXISTS view_menu_label_en TEXT,
  ADD COLUMN IF NOT EXISTS view_menu_label_tr TEXT,
  ADD COLUMN IF NOT EXISTS order_now_label_ar TEXT,
  ADD COLUMN IF NOT EXISTS order_now_label_en TEXT,
  ADD COLUMN IF NOT EXISTS order_now_label_tr TEXT;