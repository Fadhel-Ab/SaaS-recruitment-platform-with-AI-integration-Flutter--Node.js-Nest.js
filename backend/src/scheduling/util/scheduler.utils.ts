export function createDateFromSlot(dayOfWeek: number, time: string): Date {
  const now = new Date();

  const date = new Date(now);

  const daysUntil = (dayOfWeek - date.getDay() + 7) % 7;

  date.setDate(date.getDate() + daysUntil);

  const [hour, minute] = time.split(':').map(Number);

  date.setHours(hour);
  date.setMinutes(minute);
  date.setSeconds(0);
  date.setMilliseconds(0);

  return date;
}
