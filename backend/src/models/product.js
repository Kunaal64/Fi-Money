import pool from '../utils/db.js';

export async function addProduct({ name, type, sku, image_url, description, quantity, price }) {
  const res = await pool.query(
    `INSERT INTO products (name, type, sku, image_url, description, quantity, price) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
    [name, type, sku, image_url, description, quantity, price]
  );
  return res.rows[0];
}

export async function getProducts() {
  const res = await pool.query('SELECT * FROM products');
  return res.rows;
}

export async function getProductById(id) {
  const res = await pool.query('SELECT * FROM products WHERE id = $1', [id]);
  return res.rows[0];
}

export async function updateProductQuantity(id, quantity) {
  const res = await pool.query(
    `UPDATE products SET quantity = $1 WHERE id = $2 RETURNING *`,
    [quantity, id]
  );
  return res.rows[0];
}

export async function deleteProduct(id) {
  const res = await pool.query('DELETE FROM products WHERE id = $1 RETURNING * ', [id]);
  return res.rows[0];
}
