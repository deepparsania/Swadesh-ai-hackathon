import * as venueService from '../services/venueService.js';
import { AppError } from '../models/Booking.js';

export async function listVenues(req, res, next) {
  try {
    const venues = await venueService.getAllVenues();
    res.json(venues);
  } catch (err) {
    next(err);
  }
}

export async function getSlots(req, res, next) {
  try {
    const venueId = parseInt(req.params.id, 10);
    if (isNaN(venueId)) {
      throw new AppError('Invalid venue ID. Must be an integer.', 400, 'ValidationError');
    }

    const { date, timeOfDay } = req.query;
    if (!date) {
      throw new AppError('date query parameter is required (format YYYY-MM-DD)', 400, 'ValidationError');
    }

    const slotsData = await venueService.getSlotsForVenue(venueId, date, timeOfDay);
    res.json(slotsData);
  } catch (err) {
    next(err);
  }
}
