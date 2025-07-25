import { Router } from 'express';
import { register, login } from '../controllers/authController.js';
import { body } from 'express-validator';

const router = Router();

router.post(
  '/register',
  [
    body('username').isString().notEmpty().withMessage('Username is required'),
    body('password').isString().notEmpty().withMessage('Password is required'),
  ],
  register
);

router.post(
  '/login',
  [
    body('username').isString().notEmpty().withMessage('Username is required'),
    body('password').isString().notEmpty().withMessage('Password is required'),
  ],
  login
);

export default router;
