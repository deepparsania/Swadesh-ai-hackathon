import { WebSocketServer } from 'ws';

let wss;
const clients = new Set();

export function initWebSocketServer(server) {
  wss = new WebSocketServer({ server });

  wss.on('connection', (ws) => {
    clients.add(ws);
    console.log(`WebSocket client connected. Total clients: ${clients.size}`);

    ws.on('close', () => {
      clients.delete(ws);
      console.log(`WebSocket client disconnected. Total clients: ${clients.size}`);
    });

    ws.on('error', (err) => {
      console.error('WebSocket error:', err);
      clients.delete(ws);
    });

    // Send a welcome message
    ws.send(JSON.stringify({ event: 'connected', message: 'Welcome to QuickSlot Live Updates' }));
  });

  return wss;
}

export function broadcastSlotUpdate(venueId, date, startTime, status, extraData = {}) {
  if (!wss) {
    console.warn('WebSocket server not initialized. Cannot broadcast.');
    return;
  }

  const message = JSON.stringify({
    event: 'slot_status_changed',
    data: {
      venue_id: Number(venueId),
      date,
      start_time: startTime,
      status,
      ...extraData
    }
  });

  for (const client of clients) {
    if (client.readyState === 1) { // WebSocket.OPEN = 1
      try {
        client.send(message);
      } catch (err) {
        console.error('Failed to send message to client:', err);
        clients.delete(client);
      }
    }
  }
}
