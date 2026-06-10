# QuickSlot 🏸⚽️

QuickSlot is a real-time sports venue booking application that guarantees concurrency safety—so no slot is ever double-booked!

## 🚀 Setup Steps

### Prerequisites
- Node.js (v18+)
- MongoDB (running locally on port 27017 or provide a `MONGO_URI` in `.env`)
- Flutter SDK (v3.19+)

### 1. Backend Setup
```bash
cd server
npm install
# Ensure MongoDB is running locally
npm start
```
*The server will start on `http://localhost:3000` and seed 4 default venues into the database automatically.*

### 2. Flutter App Setup
```bash
cd app
flutter pub get
flutter run
```
*The app is configured to point to `localhost:3000` for both REST and WebSockets. Run it on two different simulators to see real-time booking updates!*

## 🏗 Architecture Note

QuickSlot utilizes a decoupled client-server architecture. The backend is a lightweight Node.js/Express server backed by MongoDB, using a compound unique index to guarantee absolute concurrency safety at the database level. For real-time functionality, the server maintains a WebSocket connection with the clients. 

The Flutter frontend uses the `Provider` pattern for state management. When a user books a slot via the REST API, the backend broadcasts a WebSocket event (`slot_status_changed`) to all connected clients, allowing the Flutter app to instantly update the UI grid without requiring a heavy re-fetch of the endpoint.

![Architecture Sketch](/Users/deepparsania/.gemini/antigravity/brain/2dd20fa0-5411-4d4d-af41-84a31321d9e7/architecture_sketch_1781112180688.png)

## ✂️ What I Cut & Why

1. **Full Authentication (JWT/OAuth):** We cut a robust login system in favor of a lightweight `X-User-Id` header. Building auth flows, token refresh logic, and user registration would burn precious hackathon time without demonstrating the core technical challenge (concurrency and real-time updates).
2. **Dynamic Slot Generation Engine:** Instead of building a complex admin panel to define custom operating hours for each venue, we seeded standard 6 AM - 10 PM hourly slots. This kept the database schema simpler and allowed us to focus directly on the booking UI.

## ⏳ What I'd Do With One More Day

- **Robust WebSocket Reconnection:** I would implement an exponential backoff reconnection strategy for the WebSockets in Flutter, along with an "offline" UI banner.
- **Payment Gateway Integration:** Integrate Stripe to actually charge users before locking the slot.
- **Admin Dashboard:** A simple web portal for venue owners to view bookings, cancel them, and block out maintenance times.

## 🤖 AI Usage Note

**How AI was used:** AI (specifically the agentic coding assistant) was used to rapidly scaffold the Flutter UI, generate the initial mock API service, write the Express boilerplate, and handle the repetitive task of mapping the JSON models into Dart classes. It was also used to generate the whiteboard architecture sketch above!

**What it got wrong & how I fixed it:** 
When asked to configure the backend for Vercel deployment, the AI confidently generated a `vercel.json` config that included an environment variable reference to a Vercel Secret (`"MONGO_URI": "@quickslot-mongo-uri"`). This caused an immediate deployment failure because that secret had not been created via the Vercel CLI. I caught the error from the deployment logs, stripped the invalid `"env"` block from the config file, and correctly set the variable in the Vercel dashboard UI instead.