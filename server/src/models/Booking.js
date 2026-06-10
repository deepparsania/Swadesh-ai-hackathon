export const SLOT_TIMES = [
  "06:00", "07:00", "08:00", "09:00", "10:00", "11:00",
  "12:00", "13:00", "14:00", "15:00", "16:00", "17:00",
  "18:00", "19:00", "20:00", "21:00"
];

export class AppError extends Error {
  constructor(message, status = 500, name = 'AppError') {
    super(message);
    this.status = status;
    this.name = name;
  }
}

export function validateDateFormat(date) {
  const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
  return dateRegex.test(date);
}

export function validateSlotTime(time) {
  return SLOT_TIMES.includes(time);
}
