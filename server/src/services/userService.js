import { getDb } from '../db.js';

export async function getUserBookings(userId) {
  const db = getDb();
  
  const bookings = await db.collection('bookings').aggregate([
    { $match: { user_id: userId } },
    {
      $lookup: {
        from: 'venues',
        localField: 'venue_id',
        foreignField: '_id',
        as: 'venue_details'
      }
    },
    {
      $unwind: {
        path: '$venue_details',
        preserveNullAndEmptyArrays: true
      }
    },
    {
      $sort: { date: 1, start_time: 1 }
    }
  ]).toArray();

  return bookings.map(b => ({
    id: b._id,
    venue_id: b.venue_id,
    date: b.date,
    start_time: b.start_time,
    created_at: b.created_at,
    venue: b.venue_details ? {
      id: b.venue_details._id,
      name: b.venue_details.name,
      sport: b.venue_details.sport,
      location: b.venue_details.location,
      image_url: b.venue_details.image_url
    } : null
  }));
}
