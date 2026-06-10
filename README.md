# QuickSlot 🏸⚽️

QuickSlot is a real-time sports venue booking application that guarantees concurrency safety, ensuring that no slot is ever double-booked even when multiple users attempt to book the same slot simultaneously.

## 🔗 Links

**Live Backend:** https://swadesh-ai-hackathon.onrender.com

**APK Download:** https://drive.google.com/file/d/1QZDLQWCgukIyqJi1sp1C1SHhY7-fjHlR/view?usp=sharing

**Demo Video:** https://drive.google.com/file/d/1A9-ptgEnpTFvTuRCG0CPhbdZu5MJ6MjB/view?usp=sharing

---

# 🚀 Setup Steps

## Prerequisites

* Node.js v18+
* MongoDB
* Flutter SDK v3.19+

## Backend

```bash
cd server
npm install
npm start
```

The backend runs on:

```text
http://localhost:3000
```

## Flutter App

```bash
cd app
flutter pub get
flutter run
```

Run the app on multiple simulators/devices to observe real-time slot synchronization.

---

# 📡 API & WebSocket Endpoints

### Base URLs
* **REST API:** `https://swadesh-ai-hackathon.onrender.com` (or `http://localhost:3000`)
* **WebSocket:** `wss://swadesh-ai-hackathon.onrender.com` (or `ws://localhost:3000`)

### Authentication
Lightweight header-based authentication is used for protected routes. Send the `X-User-Id` header (e.g., `user_1`, `user_2`).

### REST Endpoints

1. **List Venues**
   * **GET** `/venues`
   * Returns a list of all available sports venues.
2. **Get Venue Slots**
   * **GET** `/venues/{id}/slots?date=YYYY-MM-DD`
   * **Query Params:** `date` (required), `timeOfDay` (optional: `morning`, `afternoon`, `evening`)
   * Returns the hourly slots for the venue on the specified date.
3. **Book a Slot**
   * **POST** `/bookings`
   * **Headers:** `X-User-Id`
   * **Body:** `{ "venue_id": 1, "date": "2026-06-12", "start_time": "09:00" }`
   * Returns 201 on success, or 409 Conflict if the slot is already booked.
4. **Get User Bookings**
   * **GET** `/users/{id}/bookings`
   * Returns a list of upcoming bookings for the specified user.
5. **Cancel Booking**
   * **DELETE** `/bookings/{id}`
   * **Headers:** `X-User-Id`
   * Cancels a specific booking.

### WebSocket Events

The server maintains a persistent WebSocket connection. When any user successfully books or cancels a slot, the server broadcasts the following event to all connected clients:

```json
{
  "event": "slot_status_changed",
  "venue_id": 1,
  "date": "2026-06-12",
  "start_time": "09:00",
  "status": "booked",
  "booking_id": "booking_123",
  "user_id": "user_1"
}
```

---

# 🏗 Architecture Note

QuickSlot uses a client-server architecture with a Flutter frontend and a Node.js/Express backend backed by MongoDB. Concurrency safety is enforced at the database level using a compound unique index that prevents duplicate bookings for the same venue and time slot. Real-time updates are delivered through WebSockets; when a booking is created, the server broadcasts a slot update event to all connected clients, allowing every device to immediately reflect the latest slot status without refreshing. The Flutter app uses Provider for state management and SharedPreferences for offline booking cache support.

### Architecture Sketch

![Architecture Sketch](/Users/deepparsania/.gemini/antigravity/brain/2dd20fa0-5411-4d4d-af41-84a31321d9e7/architecture_sketch_1781112180688.png)

---

# ⭐ Bonus Features Implemented

* Real-time slot status updates via WebSockets
* Offline read cache for My Bookings using SharedPreferences
* Slot filtering by time of day
* Automated tests (unit/widget tests)
* Multi-device live synchronization

---

# ✂️ What I Cut & Why

### Authentication System

I intentionally avoided implementing a complete authentication solution (JWT, OAuth, registration, password recovery, etc.) and instead used a lightweight user identifier approach. This allowed me to focus on solving the core challenge of concurrency-safe booking and real-time synchronization within the hackathon timeframe.

### Venue Management Dashboard

A full admin dashboard for venue owners was excluded. While valuable, it would have required significant additional work around role management, venue configuration, and reporting, which was outside the primary scope of demonstrating booking reliability.

---

# ⏳ What I'd Do With One More Day

### Better Offline Experience

* Queue booking attempts while offline
* Automatic retry when connectivity returns
* Offline status indicators

### Robust WebSocket Reconnection

* Exponential backoff reconnect strategy
* Connection health monitoring
* User-facing connection status banner

### Payments & Admin Tools

* Stripe/Razorpay integration
* Venue owner dashboard
* Booking analytics and utilization reports

---

# 🤖 AI Usage Note

### How AI Was Used

AI was used to accelerate development by helping generate Flutter UI scaffolding, Express server boilerplate, model classes, API integration code, test skeletons, and project documentation. It was also used to create the architecture sketch and speed up repetitive coding tasks.

### One Thing AI Got Wrong

While working on deployment, the AI generated an incorrect deployment configuration that referenced an environment variable that had not been properly configured. The deployment failed during testing. After reviewing the deployment logs, I identified the issue, corrected the configuration manually, and redeployed successfully. This highlighted the importance of validating AI-generated solutions rather than accepting them blindly.