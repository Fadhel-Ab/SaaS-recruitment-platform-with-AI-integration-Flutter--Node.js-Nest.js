export function generateSlots(
  startTime: string,
  endTime: string,
  duration: number,
) {
  const slots: string[] = [];

  if (startTime >= endTime) {
    throw new Error('End time must be later than start time.');
  }

  let current = new Date(`2026-01-01T${startTime}:00`);

  const end = new Date(`2026-01-01T${endTime}:00`);

  while (current.getTime() + duration * 60000 <= end.getTime()) {
    slots.push(current.toTimeString().slice(0, 5));

    current = new Date(current.getTime() + duration * 60000);
  }

  return slots;
}
