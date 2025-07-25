import { addProduct, updateProductQuantity, getProducts, getProductById, deleteProduct, incrementTimesAdded, getMostAddedProducts } from '../models/product.js';
import { validationResult } from 'express-validator';

export async function createProduct(req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ error: errors.array()[0].msg });
  }
  const { name, type, sku, image_url, description, quantity, price } = req.body;
  try {
    const product = await addProduct({ name, type, sku, image_url, description, quantity, price });
    // Increment times_added for the product
    await incrementTimesAdded(product.id); // Assuming product.id is returned from addProduct
    res.status(201).json({ product_id: product.id, message: 'Product created' });
  } catch (err) {
    if (err.code === '23505') { // unique violation
      res.status(409).json({ error: 'SKU already exists' });
    } else {
      next(err);
    }
  }
}

export async function updateQuantity(req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ error: errors.array()[0].msg });
  }
  const id = req.params.id;
  const { quantity } = req.body;
  try {
    const updated = await updateProductQuantity(id, quantity);
    if (!updated) return res.status(404).json({ error: 'Product not found' });
    res.json(updated);
  } catch (err) {
    next(err);
  }
}

export async function getMostAdded(req, res, next) {
  try {
    const limit = parseInt(req.query.limit) || 5;
    const products = await getMostAddedProducts(limit);
    res.json(products);
  } catch (err) {
    next(err);
  }
}

export async function listProducts(req, res, next) {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const offset = parseInt(req.query.offset) || 0;
    const products = await getProducts(limit, offset);
    res.json(products);
  } catch (err) {
    next(err);
  }
}

export async function removeProduct(req, res, next) {
  try {
    const id = req.params.id;
    const deleted = await deleteProduct(id);
    if (!deleted) return res.status(404).json({ error: 'Product not found' });
    res.json({ message: 'Product deleted' });
  } catch (err) {
    next(err);
  }
}
