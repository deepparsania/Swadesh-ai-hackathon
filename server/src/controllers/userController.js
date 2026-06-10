import * as userService from '../services/userService.js';
import { AppError } from '../models/Booking.js';

export async function getBookings(req, res, next) {
  try {
    const requestUserId = req.user.id;
    const targetUserId = req.params.id;

    if (requestUserId !== targetUserId) {
      throw new AppError('Forbidden. You can only view your own bookings.', 403, 'ForbiddenError');
    }

    const bookings = await userService.getUserBookings(targetUserId);
    res.json(bookings);
  } catch (err) {
    next(err);
  }
}
