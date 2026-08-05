// Bahrain is UTC+3 year-round (no DST). Managers/candidates always enter
// and read availability/interview times as Bahrain wall-clock time, so we
// bake that offset in explicitly rather than using Date's setHours/
// setMinutes, which apply in whatever timezone the server process happens
// to run in (e.g. UTC on most cloud hosts) - that mismatch was shifting
// every scheduled time by the server/Bahrain offset.
const BAHRAIN_UTC_OFFSET = '+03:00';

export function createDateFromSlot(date: string | Date, time: string): Date {
  const d = typeof date === 'string' ? new Date(date) : date;

  // Read the calendar date via UTC getters: availability windows are
  // generated with UTC day boundaries upstream, so this is the calendar
  // date that was actually intended.
  const year = d.getUTCFullYear();
  const month = String(d.getUTCMonth() + 1).padStart(2, '0');
  const day = String(d.getUTCDate()).padStart(2, '0');

  const [hour, minute] = time.split(':').map(Number);
  const hh = String(hour).padStart(2, '0');
  const mm = String(minute).padStart(2, '0');

  return new Date(`${year}-${month}-${day}T${hh}:${mm}:00${BAHRAIN_UTC_OFFSET}`);
}
