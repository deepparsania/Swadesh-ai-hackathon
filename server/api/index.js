import express from 'express';
import cors from 'cors';
import { connectDb } from '../src/db.js';
import venuesRouter from '../src/routes/venues.js';
import bookingsRouter from '../src/routes/bookings.js';
import usersRouter from '../src/routes/users.js';
import { errorHandler } from '../src/middlewares/errorHandler.js';

const app = express();

app.use(cors());
app.use(express.json());

// Ensure DB is connected for serverless environment
app.use(async (req, res, next) => {
  try {
    await connectDb();
    next();
  } catch (err) {
    next(err);
  }
});

app.use('/venues', venuesRouter);
app.use('/bookings', bookingsRouter);
app.use('/users', usersRouter);

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date() });
});

app.use(errorHandler);

export default app;
