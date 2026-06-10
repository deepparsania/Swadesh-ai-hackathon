import express from 'express';
import * as bookingController from '../controllers/bookingController.js';
import { authMiddleware } from '../middlewares/auth.js';

const router = express.Router();

router.post('/', authMiddleware, bookingController.createBooking);
router.delete('/:id', authMiddleware, bookingController.deleteBooking);

export default router;
