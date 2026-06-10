import { getDb } from '../db.js';
import { SLOT_TIMES, AppError } from '../models/Booking.js';

// Helper to calculate end time
function getEndTime(startTime) {
  const [hours, minutes] = startTime.split(':').map(Number);
  const endHours = hours + 1;
  return `${endHours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`;
}

export async function getAllVenues() {
  const db = getDb();
  return await db.collection('venues').find().toArray();
}

export async function getSlotsForVenue(venueId, date, timeOfDay) {
  const db = getDb();
  
  // Check if venue exists
  const venue = await db.collection('venues').findOne({ _id: venueId });
  if (!venue) {
    throw new AppError('Venue not found', 404, 'NotFoundError');
  }

  // Get bookings for this venue on this date
  const bookings = await db.collection('bookings')
    .find({ venue_id: venueId, date: date })
    .toArray();

  // Map bookings by start_time
  const bookingsMap = new Map();
  bookings.forEach(b => {
    bookingsMap.set(b.start_time, b);
  });

  // Generate slots
  let slots = SLOT_TIMES.map(time => {
    const isBooked = bookingsMap.has(time);
    const slot = {
      start_time: time,
      end_time: getEndTime(time),
      status: isBooked ? 'booked' : 'available'
    };
    
    if (isBooked) {
      const booking = bookingsMap.get(time);
      slot.booking_id = booking._id;
      slot.user_id = booking.user_id;
    }
    
    return slot;
  });

  // Filter slots by time of day if requested
  if (timeOfDay) {
    const validFilters = ['morning', 'afternoon', 'evening'];
    if (!validFilters.includes(timeOfDay.toLowerCase())) {
      throw new AppError("Invalid timeOfDay value. Must be 'morning', 'afternoon', or 'evening'.", 400, 'ValidationError');
    }

    const filter = timeOfDay.toLowerCase();
    slots = slots.filter(slot => {
      const hour = parseInt(slot.start_time.split(':')[0], 10);
      if (filter === 'morning') {
        return hour >= 6 && hour < 12;
      } else if (filter === 'afternoon') {
        return hour >= 12 && hour < 17;
      } else { // evening
        return hour >= 17 && hour < 22;
      }
    });
  }

  return {
    venue_id: venueId,
    date,
    slots
  };
}
