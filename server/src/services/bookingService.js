import { ObjectId } from 'mongodb';
import { getDb } from '../db.js';
import { broadcastSlotUpdate } from '../ws.js';
import { AppError, validateDateFormat, validateSlotTime } from '../models/Booking.js';

export async function createBooking(venueId, date, startTime, userId) {
  // Input validations
  if (venueId === undefined || !date || !startTime) {
    throw new AppError('venue_id, date, and start_time are required fields.', 400, 'ValidationError');
  }

  const venueIdInt = parseInt(venueId, 10);
  if (isNaN(venueIdInt)) {
    throw new AppError('venue_id must be an integer.', 400, 'ValidationError');
  }

  if (!validateDateFormat(date)) {
    throw new AppError('date must be in YYYY-MM-DD format.', 400, 'ValidationError');
  }

  if (!validateSlotTime(startTime)) {
    throw new AppError('Invalid start_time. Must be an hourly slot between 06:00 and 21:00.', 400, 'ValidationError');
  }

  const db = getDb();

  // Verify venue exists
  const venue = await db.collection('venues').findOne({ _id: venueIdInt });
  if (!venue) {
    throw new AppError('Venue not found.', 404, 'NotFoundError');
  }

  const bookingDoc = {
    venue_id: venueIdInt,
    date,
    start_time: startTime,
    user_id: userId,
    created_at: new Date()
  };

  try {
    const result = await db.collection('bookings').insertOne(bookingDoc);
    const bookingId = result.insertedId;

    // Broadcast status change
    broadcastSlotUpdate(venueIdInt, date, startTime, 'booked', {
      booking_id: bookingId,
      user_id: userId
    });

    return {
      id: bookingId,
      ...bookingDoc
    };
  } catch (err) {
    if (err.code === 11000) {
      throw new AppError('This slot was just booked by another user. Please choose a different time.', 409, 'ConflictError');
    }
    throw err;
  }
}

export async function cancelBooking(bookingIdStr, userId) {
  if (!ObjectId.isValid(bookingIdStr)) {
    throw new AppError('Invalid booking ID format.', 400, 'ValidationError');
  }

  const bookingId = new ObjectId(bookingIdStr);
  const db = getDb();

  // Find booking to verify ownership
  const booking = await db.collection('bookings').findOne({ _id: bookingId });
  if (!booking) {
    throw new AppError('Booking not found.', 404, 'NotFoundError');
  }

  if (booking.user_id !== userId) {
    throw new AppError('Forbidden. You cannot cancel another user\'s booking.', 403, 'ForbiddenError');
  }

  // Delete
  await db.collection('bookings').deleteOne({ _id: bookingId });

  // Broadcast slot is available
  broadcastSlotUpdate(booking.venue_id, booking.date, booking.start_time, 'available');

  return {
    message: 'Booking cancelled successfully',
    booking_id: bookingIdStr
  };
}
