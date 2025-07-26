DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS products;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    sku VARCHAR(50) UNIQUE NOT NULL,
    image_url TEXT,
    description TEXT,
    quantity INTEGER NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    times_added INTEGER DEFAULT 0
); 