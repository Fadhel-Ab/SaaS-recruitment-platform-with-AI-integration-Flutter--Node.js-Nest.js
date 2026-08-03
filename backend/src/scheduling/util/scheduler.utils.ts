export function createDateFromSlot(date: string | Date, time: string): Date {
  const result = new Date(date);

  const [hour, minute] = time.split(':').map(Number);

  result.setHours(hour);
  result.setMinutes(minute);
  result.setSeconds(0);
  result.setMilliseconds(0);

  return result;
}
