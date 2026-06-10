import { VALID_USERS } from '../db.js';

export function authMiddleware(req, res, next) {
  const userId = req.headers['x-user-id'];
  if (!userId) {
    return res.status(401).json({ error: 'Authentication required. Missing X-User-Id header.' });
  }

  const user = VALID_USERS[userId];
  if (!user) {
    return res.status(401).json({ error: 'Unauthorized. Invalid X-User-Id header.' });
  }

  req.user = user;
  next();
}
