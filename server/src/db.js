import { MongoClient } from 'mongodb';
import dotenv from 'dotenv';

dotenv.config();

const url = process.env.MONGO_URI || 'mongodb://localhost:27017/quickslot';
let client;
let db;

export async function connectDb(dbName) {
  if (db) return db;
  client = new MongoClient(url);
  await client.connect();
  db = client.db(dbName || undefined);
  
  // Setup indexes
  await setupIndexes();
  // Seed initial data
  await seedDb();
  
  console.log('Connected to MongoDB successfully');
  return db;
}

export function getDb() {
  if (!db) {
    throw new Error('Database not initialized. Call connectDb() first.');
  }
  return db;
}

export async function closeDb() {
  if (client) {
    await client.close();
    client = null;
    db = null;
    console.log('Database connection closed');
  }
}

async function setupIndexes() {
  const bookings = db.collection('bookings');
  // Compound unique index for preventing double bookings
  await bookings.createIndex(
    { venue_id: 1, date: 1, start_time: 1 },
    { unique: true, name: 'unique_venue_slot' }
  );
  // Index for searching bookings by user
  await bookings.createIndex({ user_id: 1 });
}

async function seedDb() {
  const venuesCollection = db.collection('venues');
  const count = await venuesCollection.countDocuments();
  if (count === 0) {
    const defaultVenues = [
      {
        _id: 1,
        name: "Smash Arena Badminton Court",
        sport: "Badminton",
        location: "Downtown Sports Hub, Floor 3",
        image_url: "https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=500&auto=format&fit=crop"
      },
      {
        _id: 2,
        name: "Camp Nou Turf Ground",
        sport: "Football",
        location: "East Side Recreation Center",
        image_url: "https://images.unsplash.com/photo-1529900748604-07564a03e7a6?w=500&auto=format&fit=crop"
      },
      {
        _id: 3,
        name: "Wimbledon Tennis Club",
        sport: "Tennis",
        location: "West End Athletic Complex",
        image_url: "https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?w=500&auto=format&fit=crop"
      },
      {
        _id: 4,
        name: "Lakers Basketball Court",
        sport: "Basketball",
        location: "Central Gym, Sector 5",
        image_url: "https://images.unsplash.com/photo-1546519638-68e109498ffc?w=500&auto=format&fit=crop"
      }
    ];
    await venuesCollection.insertMany(defaultVenues);
    console.log('Database seeded with 4 venues');
  }
}

// Hardcoded valid users for light auth
export const VALID_USERS = {
  'user_1': { id: 'user_1', name: 'Alice Smith', email: 'alice@example.com' },
  'user_2': { id: 'user_2', name: 'Bob Jones', email: 'bob@example.com' },
  'user_3': { id: 'user_3', name: 'Charlie Brown', email: 'charlie@example.com' }
};
