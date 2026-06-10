import * as bookingService from '../services/bookingService.js';

export async function createBooking(req, res, next) {
  try {
    const userId = req.user.id;
    const { venue_id, date, start_time } = req.body;

    const result = await bookingService.createBooking(venue_id, date, start_time, userId);
    
    res.status(201).json({
      message: 'Booking successful',
      booking: result
    });
  } catch (err) {
    next(err);
  }
}

export async function deleteBooking(req, res, next) {
  try {
    const userId = req.user.id;
    const bookingIdStr = req.params.id;

    const result = await bookingService.cancelBooking(bookingIdStr, userId);
    res.json(result);
  } catch (err) {
    next(err);
  }
}
