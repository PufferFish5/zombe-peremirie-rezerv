-- ════════════════════════════════════
-- КРОК 1: Видалити зайві таблиці від бота
-- ════════════════════════════════════
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS drinks;

-- ════════════════════════════════════
-- КРОК 2: Адаптувати таблицю products
-- Якщо потрібно додати стовпці — ALTER TABLE
-- Видалити стовпець в SQLite складніше (нижче пояснення)
-- ════════════════════════════════════

-- Додати нові поля якщо їх немає:
-- ALTER TABLE drinks ADD COLUMN series TEXT DEFAULT '';
-- ALTER TABLE products ADD COLUMN flavor_description TEXT DEFAULT '';
-- ALTER TABLE products ADD COLUMN image_path TEXT DEFAULT '';
-- ALTER TABLE products ADD COLUMN is_available INTEGER DEFAULT 1;

-- ════════════════════════════════════
-- КРОК 3: Видалення стовпців в SQLite
-- SQLite не підтримує DROP COLUMN до версії 3.35
-- Тому: створюємо нову таблицю → копіюємо потрібне → видаляємо стару
-- ════════════════════════════════════

-- Приклад: прибираємо telegram_id та chat_id з products
CREATE TABLE drinks (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  name            TEXT    NOT NULL,
  series          TEXT    NOT NULL DEFAULT '',
  price           REAL    NOT NULL DEFAULT 0.0,
  category        TEXT    NOT NULL DEFAULT '',
  flavor_profile  TEXT    NOT NULL DEFAULT '',
  description     TEXT    NOT NULL DEFAULT '',
  image_path      TEXT    DEFAULT '',
  is_available    INTEGER NOT NULL DEFAULT 1
);
CREATE TABLE users (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  name        TEXT    NOT NULL,
  email       TEXT    NOT NULL DEFAULT '',
  phone       INTEGER NOT NULL DEFAULT 0,
  created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
  google_id    TEXT    DEFAULT '',
  is_google_connected INTEGER DEFAULT 0
);

CREATE TABLE orders (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id     INTEGER NOT NULL,
  drink_id    INTEGER NOT NULL,
  quantity    INTEGER NOT NULL DEFAULT 1,
  status      TEXT    NOT NULL DEFAULT 'pending',
  created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (drink_id) REFERENCES drinks(id)
);

CREATE TABLE IF NOT EXISTS posts (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  title       TEXT    NOT NULL,
  body        TEXT    NOT NULL DEFAULT '',
  type        TEXT    NOT NULL DEFAULT 'news', -- 'news' | 'event' | 'promo' | 'contest'
  image_url   TEXT    DEFAULT '',
  event_date  TEXT    DEFAULT NULL,            -- ISO 8601: '2025-12-31T18:00:00'
  created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

INSERT INTO drinks (name, series, price, category, flavor_profile, description) VALUES
('Tropical Burst', 'tropical', 60.0, 'Tropical', 'mango pineapple passion fruit sweet tropical', 'Explosive blend of ripe mango pineapple and passion fruit creates a bright sweet tropical explosion that instantly lifts your mood and gives powerful energy.'),
('Electric Berry', 'tropical', 50.0, 'Berry', 'blueberry raspberry electric sour sweet', 'Vibrant mix of blueberry and raspberry with a refreshing electric sour note delivers bold berry taste and strong energizing effect.'),
('Cooling Watermelon', 'tropical', 45.0, 'Fruit', 'watermelon fresh cooling juicy sweet', 'Juicy ripe watermelon with a pronounced cooling effect offers light sweet taste and excellent refreshment.'),
('Neon Mango', 'tropical', 40.0, 'Tropical', 'mango citrus neon bright sweet', 'Intensely sweet mango combined with bright citrus creates a neon tropical experience full of sunshine and energy.'),
('Black Coffee', 'noir', 60.0, 'Strong', 'black coffee robust bitter dark', 'Powerful black coffee energy drink with rich robust taste and strong bitter coffee notes for maximum focus and alertness.'),
('Mysterious Blackberry', 'noir', 50.0, 'Berry', 'blackberry dark mysterious deep sweet', 'Dark mysterious blackberry with deep rich flavor profile delivers premium berry taste and long lasting energy.'),
('Deep Cherry', 'noir', 45.0, 'Berry', 'cherry dark sweet tart rich', 'Intense deep cherry flavor with sweet tart balance and rich dark notes creates a seductive and powerful energy experience.'),
('Sharp Lemon', 'noir', 40.0, 'Citrus', 'lemon sharp sour fresh citrus', 'Sharp refreshing lemon with pronounced sour citrus taste provides clean bright energy and perfect thirst quenching.'),
('Bold Grape', 'thug', 60.0, 'Fruit', 'grape bold dark sweet strong', 'Bold and powerful grape flavor with dark sweet notes designed for those who want maximum strength and confidence.'),
('Gold Citrus', 'thug', 50.0, 'Citrus', 'citrus orange gold bright sweet', 'Premium gold citrus blend with sweet orange and grapefruit creates luxurious bright and powerful taste.'),
('Rich Pineapple', 'thug', 45.0, 'Tropical', 'pineapple rich sweet tropical bold', 'Extra rich and sweet pineapple with deep tropical character delivers bold juicy flavor and strong energy.'),
('Hustling Lime', 'thug', 40.0, 'Citrus', 'lime sour fresh zesty bold', 'Sharp hustling lime with strong sour zesty character designed for active people who move forward non stop.'),
('Miyagoda Rofls', 'og', 100.0, 'Signature', 'exotic mystery legendary sweet bold', 'Legendary signature edition that combines the best flavors into one ultimate powerful and unforgettable energy experience.');

-- INSERT OR IGNORE INTO posts (title, body, type, event_date)
-- VALUES
--   ('Новий смак вже в магазинах', 'Omega Blaze тепер доступний у всіх точках продажу.', 'news', NULL),
--   ('Турнір Omega Cup 2025', 'Реєструйся та виграй річний запас Omega Energy!', 'event', '2025-11-15T12:00:00');

UPDATE drinks SET image_path = 'assets/images/products/d1.png' WHERE name = 'Tropical Burst';
UPDATE drinks SET image_path = 'assets/images/products/d2.png' WHERE name = 'Electric Berry';
UPDATE drinks SET image_path = 'assets/images/products/d3.png' WHERE name = 'Cooling Watermelon';
UPDATE drinks SET image_path = 'assets/images/products/d4.png' WHERE name = 'Neon Mango';
UPDATE drinks SET image_path = 'assets/images/products/d5.png' WHERE name = 'Black Coffee';
UPDATE drinks SET image_path = 'assets/images/products/d6.png' WHERE name = 'Mysterious Blackberry';
UPDATE drinks SET image_path = 'assets/images/products/d7.png' WHERE name = 'Deep Cherry';
UPDATE drinks SET image_path = 'assets/images/products/d8.png' WHERE name = 'Sharp Lemon';
UPDATE drinks SET image_path = 'assets/images/products/d9.png' WHERE name = 'Bold Grape';
UPDATE drinks SET image_path = 'assets/images/products/d10.png' WHERE name = 'Gold Citrus';
UPDATE drinks SET image_path = 'assets/images/products/d11.png' WHERE name = 'Rich Pineapple';
UPDATE drinks SET image_path = 'assets/images/products/d12.png' WHERE name = 'Hustling Lime';
UPDATE drinks SET image_path = 'assets/images/products/d13.png' WHERE name = 'Miyagoda Rofls';