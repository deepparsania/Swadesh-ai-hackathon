import express from 'express';
import * as userController from '../controllers/userController.js';
import { authMiddleware } from '../middlewares/auth.js';

const router = express.Router();

router.get('/:id/bookings', authMiddleware, userController.getBookings);

export default router;
