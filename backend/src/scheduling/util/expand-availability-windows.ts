import { AvailabilityRecurrence } from '../../generated/prisma/enums.js';

export type RawAvailabilityWindow = {
  recurrence: AvailabilityRecurrence;
  date: Date | null;
  dayOfWeek: number | null;
  startTime: string;
  endTime: string;
};

export type DatedAvailabilityWindow = {
  date: Date;
  startTime: string;
  endTime: string;
};

const DEFAULT_HORIZON_WEEKS = 8;

/**
 * Turns raw availability rows (some recurring by weekday, some pinned to a
 * specific calendar date) into a flat, date-sorted list of concrete
 * occurrences. Recurring windows are projected forward `horizonWeeks` weeks
 * from `from`; specific-date windows are included as-is if not already past.
 */
export function expandAvailabilityWindows(
  windows: RawAvailabilityWindow[],
  options: { from?: Date; horizonWeeks?: number } = {},
): DatedAvailabilityWindow[] {
  const from = options.from ?? new Date();
  const today = new Date(from);
  today.setHours(0, 0, 0, 0);

  const horizonWeeks = options.horizonWeeks ?? DEFAULT_HORIZON_WEEKS;
  const result: DatedAvailabilityWindow[] = [];

  for (const window of windows) {
    if (window.recurrence === AvailabilityRecurrence.SPECIFIC) {
      if (window.date && window.date >= today) {
        result.push({
          date: window.date,
          startTime: window.startTime,
          endTime: window.endTime,
        });
      }
      continue;
    }

    if (window.dayOfWeek == null) continue;

    // Stored as 1-7 (Mon-Sun); JS Date.getDay() is 0-6 (Sun-Sat).
    const targetDay = window.dayOfWeek % 7;
    const todayDow = today.getDay();
    let daysUntilFirst = targetDay - todayDow;
    if (daysUntilFirst < 0) daysUntilFirst += 7;

    for (let weekOffset = 0; weekOffset <= horizonWeeks; weekOffset++) {
      const occurrence = new Date(today);
      occurrence.setDate(occurrence.getDate() + daysUntilFirst + weekOffset * 7);
      result.push({
        date: occurrence,
        startTime: window.startTime,
        endTime: window.endTime,
      });
    }
  }

  return result.sort((a, b) => {
    const diff = a.date.getTime() - b.date.getTime();
    if (diff !== 0) return diff;
    return a.startTime.localeCompare(b.startTime);
  });
}
