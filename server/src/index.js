import express from 'express';
import http from 'http';
import cors from 'cors';
import dotenv from 'dotenv';
import { connectDb, closeDb } from './db.js';
import { initWebSocketServer } from './ws.js';
import venuesRouter from './routes/venues.js';
import bookingsRouter from './routes/bookings.js';
import usersRouter from './routes/users.js';
import { errorHandler } from './middlewares/errorHandler.js';

dotenv.config();

const app = express();
const server = http.createServer(app);
const port = process.env.PORT || 3000;

// Setup middlewares
app.use(cors());
app.use(express.json());

// Custom request logger
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.originalUrl}`);
  next();
});

// Register routes
app.use('/venues', venuesRouter);
app.use('/bookings', bookingsRouter);
app.use('/users', usersRouter);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date() });
});

// Global error handler
app.use(errorHandler);

async function startServer() {
  try {
    // 1. Connect to DB and seed initial data
    await connectDb();

    // 2. Initialize WebSocket server sharing the HTTP port
    initWebSocketServer(server);

    // 3. Start listening
    server.listen(port, () => {
      console.log(`Server is running on http://localhost:${port}`);
      console.log(`WebSocket server is active on ws://localhost:${port}`);
    });
  } catch (err) {
    console.error('Failed to start server:', err);
    process.exit(1);
  }
}

// Graceful shutdown handling
const gracefulShutdown = async () => {
  console.log('Shutting down gracefully...');
  server.close(async () => {
    console.log('HTTP server closed.');
    await closeDb();
    process.exit(0);
  });

  // Force close after 10s if graceful fails
  setTimeout(() => {
    console.error('Could not close connections in time, forcefully shutting down');
    process.exit(1);
  }, 10000);
};

process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);

startServer();
