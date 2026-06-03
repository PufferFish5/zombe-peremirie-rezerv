
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS drinks;

-- ALTER TABLE drinks ADD COLUMN series TEXT DEFAULT '';
-- ALTER TABLE products ADD COLUMN flavor_description TEXT DEFAULT '';
-- ALTER TABLE products ADD COLUMN image_path TEXT DEFAULT '';
-- ALTER TABLE products ADD COLUMN is_available INTEGER DEFAULT 1;


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

INSERT OR IGNORE INTO posts (title, body, type, event_date)
VALUES
  ('Gold Citrus – New Flagship Flavor', 'Omega Energy has released its latest masterpiece — Gold Citrus. This bold energy drink combines sharp, invigorating citrus with a vibrant neon aftertaste. It is designed for those who live on the cutting edge of technology and want maximum productivity and vivid emotions. The flavor is already available in stores and on the official online store. Position it as "the key to the energy of the future".', 'post', '2026-11-15T12:00:00'),
  ('"When City Sleeps" Noir Series – Official Launch', 'In May 2026, Omega Energy launched the mysterious noir-inspired series "When City Sleeps". The collection includes three new flavors. These drinks are created specifically for night owls, creators, and people who stay productive during twilight and nighttime hours. The official launch event took place on May 17, 2026, at the Concert Hall in Otso City. The series is now available both online and in selected retail stores.', 'event', '2026-11-15T12:00:00'),
  ('Digital Pulse – Collaboration with Chornobrivtsi', 'Omega Energy partnered with the renowned digital art studio Chornobrivtsi (specialists in retrowave/synthwave aesthetics). Together they created the unique visual art series "Digital Pulse". The artworks reflect the neon energy, movement, and futuristic spirit of the brand. The collection is available for viewing in the online gallery on the official website and appears on a limited collection of merchandise.', 'post', '2026-10-15T12:00:00'),
  ('"Retro Rewind" Instagram Photo Contest', 'Omega Energy is currently running the Retro Rewind photo and video contest on Instagram. Participants are invited to share creative photos or videos showing how Omega Energy fuels their life, creativity, or adventures in a retro-futuristic, 80s neon, or cyberpunk style. Use hashtag #OmegaRetroRewind. Prizes include exclusive merchandise and a full year’s supply of favorite Omega Energy flavors. The contest is active now.', 'event', '2026-12-15T12:00:00'),
  ('Neon Arena Championship – Official Energy Partner', 'Omega Energy became the official energy partner of one of the biggest esports events of the year — Neon Arena Championship. The brand provides energy and focus for players and actively participates in the tournament with activations, giveaways, and special prizes. This partnership continues throughout 2026.', 'post', '2026-12-15T12:00:00'),
  ('SWAG CHARGE – Limited Edition Collaboration with Omega Theft Auto', 'The biggest current campaign is the limited-edition drink SWAG CHARGE, created in collaboration with the game Omega Theft Auto. This exclusive street-energy flavor is designed for those who dominate the urban jungle. As part of the collaboration, legendary rap artist LyaShobuPodelaty released an exclusive track that plays only on the in-game radio of Omega Theft Auto. Omega Energy was the official energy sponsor of this track. "Code of Success" Contest Every specially marked can of SWAG CHARGE contains a unique promo code. Customers can enter the code on the official website or in the bot to participate in the grand prize draw.', 'event', '2026-10-15T12:00:00');


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

UPDATE posts SET image_url = 'assets/images/p1.jpg' WHERE title = 'Gold Citrus – New Flagship Flavor';
UPDATE posts SET image_url = 'assets/images/p2.png' WHERE title = '"When City Sleeps" Noir Series – Official Launch';
UPDATE posts SET image_url = 'assets/images/p3.png' WHERE title = 'Digital Pulse – Collaboration with Chornobrivtsi';
UPDATE posts SET image_url = 'assets/images/p4.png' WHERE title = '"Retro Rewind" Instagram Photo Contest';
UPDATE posts SET image_url = 'assets/images/p5.png' WHERE title = 'Neon Arena Championship – Official Energy Partner';
UPDATE posts SET image_url = 'assets/images/p6.png' WHERE title = 'SWAG CHARGE – Limited Edition Collaboration with Omega Theft Auto';