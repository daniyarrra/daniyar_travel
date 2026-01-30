-- Run this script in pgAdmin to create the necessary table

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS places (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    image_url TEXT,
    category VARCHAR(100),
    rating DECIMAL(2, 1) DEFAULT 5.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seed data for Places
INSERT INTO places (title, description, image_url, category, rating) VALUES
('Кольсайские озера', 'Система из трех озер в северном Тянь-Шане, в ущелье Кольсай.', 'https://tengrinews.kz/userdata/news/2022/news_479836/thumb_m/photo_408544.jpeg', 'Озера', 4.9),
('Чарынский каньон', 'Памятник природы, сложенный из осадочных пород, возраст которых составляет около 12 миллионов лет.', 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Charyn_Canyon_1.jpg/800px-Charyn_Canyon_1.jpg', 'Каньоны', 4.8),
('Каинды', 'Озеро в Казахстане, популярное место туризма в одном из ущелий Кунгей Алатау.', 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Kaindy_Lake.jpg/1200px-Kaindy_Lake.jpg', 'Озера', 4.7);
