-- Drop tables if they exist
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS products CASCADE;

-- Create users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL
);

-- Create products table
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    sku VARCHAR(50) UNIQUE NOT NULL,
    image_url TEXT,
    description TEXT,
    quantity INTEGER NOT NULL,
    price NUMERIC(10,2) NOT NULL
);

-- Insert sample users (passwords are hashed 'password123')
INSERT INTO users (username, password_hash) VALUES
('admin', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'), -- password123
('user1', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'), -- password123
('user2', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'); -- password123

-- Insert sample products
INSERT INTO products (name, type, sku, image_url, description, quantity, price) VALUES
-- Electronics
('Wireless Earbuds', 'Electronics', 'ELEC-001', 'https://example.com/earbuds.jpg', 'High-quality wireless earbuds with noise cancellation', 50, 99.99),
('Smartphone X', 'Electronics', 'ELEC-002', 'https://example.com/phone.jpg', 'Latest smartphone with 128GB storage', 25, 899.99),
('Bluetooth Speaker', 'Electronics', 'ELEC-003', 'https://example.com/speaker.jpg', 'Portable Bluetooth speaker with 20h battery', 35, 79.99),

-- Clothing
('Cotton T-Shirt', 'Clothing', 'CLOTH-001', 'https://example.com/tshirt.jpg', 'Comfortable 100% cotton t-shirt', 100, 19.99),
('Denim Jeans', 'Clothing', 'CLOTH-002', 'https://example.com/jeans.jpg', 'Classic blue denim jeans', 75, 49.99),
('Winter Jacket', 'Clothing', 'CLOTH-003', 'https://example.com/jacket.jpg', 'Warm winter jacket with hood', 30, 129.99),

-- Books
('The Great Novel', 'Books', 'BOOK-001', 'https://example.com/novel.jpg', 'Bestselling fiction novel', 60, 14.99),
('Programming Guide', 'Books', 'BOOK-002', 'https://example.com/progbook.jpg', 'Complete guide to modern programming', 45, 39.99),
('Cookbook', 'Books', 'BOOK-003', 'https://example.com/cookbook.jpg', 'Collection of delicious recipes', 80, 24.99),

-- Home & Kitchen
('Coffee Maker', 'Home', 'HOME-001', 'https://example.com/coffee.jpg', '12-cup programmable coffee maker', 20, 59.99),
('Air Fryer', 'Home', 'HOME-002', 'https://example.com/airfryer.jpg', '5.5L digital air fryer', 15, 89.99),
('Blender', 'Home', 'HOME-003', 'https://example.com/blender.jpg', 'High-speed blender with 6 blades', 25, 69.99),

-- Sports & Outdoors
('Yoga Mat', 'Sports', 'SPORT-001', 'https://example.com/yogamat.jpg', 'Non-slip yoga mat', 40, 29.99),
('Dumbbell Set', 'Sports', 'SPORT-002', 'https://example.com/dumbbells.jpg', 'Adjustable dumbbell set 5-25kg', 10, 149.99),
('Running Shoes', 'Sports', 'SPORT-003', 'https://example.com/shoes.jpg', 'Lightweight running shoes', 30, 89.99);