import pool from '../utils/db.js';

export async function addProduct(product) {
  const { name, type, sku, image_url, description, quantity, price } = product;
  const res = await pool.query(
    `INSERT INTO products (name, type, sku, image_url, description, quantity, price, times_added)
     VALUES ($1, $2, $3, $4, $5, $6, $7, 1) RETURNING id, name`,
    [name, type, sku, image_url, description, quantity, price]
  );
  return res.rows[0];
}

export async function updateProductQuantity(id, quantity) {
  const res = await pool.query(
    `UPDATE products SET quantity = $1 WHERE id = $2 RETURNING *`,
    [quantity, id]
  );
  return res.rows[0];
}

export async function getProducts(limit = 10, offset = 0) {
  const res = await pool.query(
    `SELECT * FROM products ORDER BY id LIMIT $1 OFFSET $2`,
    [limit, offset]
  );
  return res.rows;
}

export async function incrementTimesAdded(id) {
  const res = await pool.query(
    `UPDATE products SET times_added = times_added + 1 WHERE id = $1 RETURNING *`,
    [id]
  );
  return res.rows[0];
}

export async function getMostAddedProducts(limit = 5) {
  const res = await pool.query(
    `SELECT id, name, times_added FROM products ORDER BY times_added DESC LIMIT $1`,
    [limit]
  );
  return res.rows;
}

export async function getProductById(id) {
  const res = await pool.query('SELECT * FROM products WHERE id = $1', [id]);
  return res.rows[0];
}

export async function deleteProduct(id) {
  const res = await pool.query('DELETE FROM products WHERE id = $1 RETURNING *', [id]);
  return res.rows[0];
}
