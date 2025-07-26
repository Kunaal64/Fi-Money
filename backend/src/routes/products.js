import { Router } from 'express';
import { authenticateToken } from '../middleware/auth.js';
import { createProduct, updateQuantity, listProducts, removeProduct } from '../controllers/productController.js';
import { body, param } from 'express-validator';

const router = Router();

router.post(
  '/',
  authenticateToken,
  [
    body('name').isString().notEmpty().withMessage('Name is required'),
    body('type').isString().notEmpty().withMessage('Type is required'),
    body('sku').isString().notEmpty().withMessage('SKU is required'),
    body('quantity').isInt({ min: 0 }).withMessage('Quantity must be a non-negative integer'),
    body('price').isNumeric().withMessage('Price must be a number'),
    body('image_url').optional().isString(),
    body('description').optional().isString(),
  ],
  createProduct
);

router.put(
  '/:id/quantity',
  authenticateToken,
  [
    param('id').isInt().withMessage('Invalid product ID'),
    body('quantity').isInt({ min: 0 }).withMessage('Quantity must be a non-negative integer'),
  ],
  updateQuantity
);

router.get('/', authenticateToken, listProducts);
// Analytics route
// router.get('/analytics/most-added', authenticateToken, getMostAdded);
router.delete('/:id', authenticateToken, removeProduct);

export default router;
