import express from 'express';
import * as venueController from '../controllers/venueController.js';

const router = express.Router();

router.get('/', venueController.listVenues);
router.get('/:id/slots', venueController.getSlots);

export default router;
