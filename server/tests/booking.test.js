import { test, describe, before, after } from 'node:test';
import assert from 'node:assert';
import http from 'http';
import express from 'express';
import cors from 'cors';
import { connectDb, closeDb, getDb } from '../src/db.js';
import venuesRouter from '../src/routes/venues.js';
import bookingsRouter from '../src/routes/bookings.js';
import usersRouter from '../src/routes/users.js';

import dotenv from 'dotenv';
dotenv.config();

let server;
let serverUrl;

describe('QuickSlot Booking API Integration Tests', () => {
  before(async () => {
    // Start Express app
    const app = express();
    app.use(cors());
    app.use(express.json());
    
    app.use('/venues', venuesRouter);
    app.use('/bookings', bookingsRouter);
    app.use('/users', usersRouter);
    
    await connectDb('quickslot_test');
    
    // Clean up bookings collection before starting
    const db = getDb();
    await db.collection('bookings').deleteMany({});
    
    server = http.createServer(app);
    await new Promise((resolve) => {
      server.listen(0, 'localhost', () => {
        const address = server.address();
        serverUrl = `http://localhost:${address.port}`;
        resolve();
      });
    });
    console.log(`Test server running at ${serverUrl}`);
  });

  after(async () => {
    // Close server
    await new Promise((resolve) => server.close(resolve));
    // Close database
    await closeDb();
  });

  test('GET /venues lists all seeded venues', async () => {
    const res = await fetch(`${serverUrl}/venues`);
    assert.strictEqual(res.status, 200);
    const venues = await res.json();
    assert.ok(Array.isArray(venues));
    assert.strictEqual(venues.length, 4);
    assert.strictEqual(venues[0].name, 'Smash Arena Badminton Court');
  });

  test('GET /venues/:id/slots fails for invalid venue', async () => {
    const res = await fetch(`${serverUrl}/venues/999/slots?date=2026-06-12`);
    assert.strictEqual(res.status, 404);
  });

  test('GET /venues/:id/slots generates available hourly slots', async () => {
    const res = await fetch(`${serverUrl}/venues/1/slots?date=2026-06-12`);
    assert.strictEqual(res.status, 200);
    const data = await res.json();
    assert.strictEqual(data.venue_id, 1);
    assert.strictEqual(data.date, '2026-06-12');
    assert.ok(Array.isArray(data.slots));
    assert.strictEqual(data.slots.length, 16); // 6 AM to 10 PM is 16 slots
    assert.strictEqual(data.slots[0].start_time, '06:00');
    assert.strictEqual(data.slots[0].status, 'available');
  });

  test('GET /venues/:id/slots with timeOfDay filtering', async () => {
    const res = await fetch(`${serverUrl}/venues/1/slots?date=2026-06-12&timeOfDay=morning`);
    assert.strictEqual(res.status, 200);
    const data = await res.json();
    // Morning is 06:00 to 11:00 inclusive (6 slots)
    assert.strictEqual(data.slots.length, 6);
    assert.strictEqual(data.slots[0].start_time, '06:00');
    assert.strictEqual(data.slots[5].start_time, '11:00');
  });

  test('POST /bookings creates a booking successfully', async () => {
    const res = await fetch(`${serverUrl}/bookings`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': 'user_1'
      },
      body: JSON.stringify({
        venue_id: 1,
        date: '2026-06-12',
        start_time: '08:00'
      })
    });
    assert.strictEqual(res.status, 201);
    const data = await res.json();
    assert.strictEqual(data.message, 'Booking successful');
    assert.ok(data.booking.id);
    assert.strictEqual(data.booking.user_id, 'user_1');
    assert.strictEqual(data.booking.venue_id, 1);
    assert.strictEqual(data.booking.start_time, '08:00');
  });

  test('POST /bookings fails without X-User-Id header', async () => {
    const res = await fetch(`${serverUrl}/bookings`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        venue_id: 1,
        date: '2026-06-12',
        start_time: '08:00'
      })
    });
    assert.strictEqual(res.status, 401);
  });

  test('POST /bookings prevents duplicate booking (concurrency test)', async () => {
    // We will attempt to book the SAME slot concurrently (3 requests at the exact same instant)
    const payload = {
      venue_id: 1,
      date: '2026-06-12',
      start_time: '09:00'
    };

    const requestPromises = [1, 2, 3].map((num) => 
      fetch(`${serverUrl}/bookings`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-User-Id': `user_${num}`
        },
        body: JSON.stringify(payload)
      })
    );

    const responses = await Promise.all(requestPromises);
    const statuses = responses.map(r => r.status);

    // Filter statuses
    const successes = statuses.filter(s => s === 201);
    const conflicts = statuses.filter(s => s === 409);

    // Exactly 1 request should succeed
    assert.strictEqual(successes.length, 1);
    // Exactly 2 requests should conflict (duplicate slot)
    assert.strictEqual(conflicts.length, 2);

    // Let's also verify that in the DB we only have 1 booking for this slot
    const db = getDb();
    const count = await db.collection('bookings').countDocuments({
      venue_id: 1,
      date: '2026-06-12',
      start_time: '09:00'
    });
    assert.strictEqual(count, 1);
  });

  test('GET /users/:id/bookings fetches only that user\'s bookings with venue details', async () => {
    // Get bookings for user_1
    const res = await fetch(`${serverUrl}/users/user_1/bookings`, {
      headers: { 'X-User-Id': 'user_1' }
    });
    assert.strictEqual(res.status, 200);
    const bookings = await res.json();
    
    // We booked 1 slot (08:00) for user_1 in previous test
    assert.ok(Array.isArray(bookings));
    assert.ok(bookings.length >= 1);
    
    const user1Booking = bookings.find(b => b.start_time === '08:00');
    assert.ok(user1Booking);
    assert.strictEqual(user1Booking.venue_id, 1);
    assert.strictEqual(user1Booking.venue.name, 'Smash Arena Badminton Court');
  });

  test('DELETE /bookings/:id prevents cancellation by non-owners', async () => {
    // Find the booking for user_1
    const resList = await fetch(`${serverUrl}/users/user_1/bookings`, {
      headers: { 'X-User-Id': 'user_1' }
    });
    const bookings = await resList.json();
    const booking = bookings.find(b => b.start_time === '08:00');
    assert.ok(booking);

    // Try deleting with user_2 header
    const resDelete = await fetch(`${serverUrl}/bookings/${booking.id}`, {
      method: 'DELETE',
      headers: { 'X-User-Id': 'user_2' }
    });
    assert.strictEqual(resDelete.status, 403);
  });

  test('DELETE /bookings/:id cancels booking successfully and frees the slot', async () => {
    // Find booking
    const resList = await fetch(`${serverUrl}/users/user_1/bookings`, {
      headers: { 'X-User-Id': 'user_1' }
    });
    const bookings = await resList.json();
    const booking = bookings.find(b => b.start_time === '08:00');
    assert.ok(booking);

    // Delete booking
    const resDelete = await fetch(`${serverUrl}/bookings/${booking.id}`, {
      method: 'DELETE',
      headers: { 'X-User-Id': 'user_1' }
    });
    assert.strictEqual(resDelete.status, 200);

    // Check slot status is now available again
    const resSlots = await fetch(`${serverUrl}/venues/1/slots?date=2026-06-12`);
    const slotData = await resSlots.json();
    const slot08 = slotData.slots.find(s => s.start_time === '08:00');
    assert.strictEqual(slot08.status, 'available');
  });
});
