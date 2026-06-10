export function errorHandler(err, req, res, next) {
  console.error(`[Error Handler] ${err.stack || err.message || err}`);

  const status = err.status || 500;
  const message = err.message || 'Internal server error';

  res.status(status).json({
    error: err.name || 'Error',
    message: message
  });
}
