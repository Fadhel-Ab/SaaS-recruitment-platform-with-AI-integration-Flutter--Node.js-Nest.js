import type { PrismaService } from '../../prisma/prisma.service.js';
import { expandAvailabilityWindows } from './expand-availability-windows.js';

export interface FindNextSlotOptions {
  jobId: string;
  managerId: string;
  durationMinutes?: number;
  minNoticeHours?: number;
  from?: Date;
}

/**
 * Finds the next free interview slot for a manager, preferring the job's own
 * availability windows and falling back to the manager's general
 * availability. If the earliest free slot is less than `minNoticeHours` away,
 * it is skipped in favor of the earliest free slot on a later calendar day,
 * so candidates always get a minimum notice window before an interview.
 */
export async function findNextAvailableSlot(
  prisma: PrismaService,
  {
    jobId,
    managerId,
    durationMinutes = 30,
    minNoticeHours = 12,
    from,
  }: FindNextSlotOptions,
): Promise<Date> {
  const now = from ?? new Date();

  const jobWindows = await prisma.availability.findMany({ where: { jobId } });
  let windows = expandAvailabilityWindows(jobWindows, { from: now });

  if (windows.length === 0) {
    const managerWindows = await prisma.availability.findMany({
      where: { managerId, jobId: null },
    });
    windows = expandAvailabilityWindows(managerWindows, { from: now });
  }

  const fallbackNextDay = () => {
    const fallback = new Date(now);
    fallback.setDate(fallback.getDate() + 1);
    return fallback;
  };

  if (windows.length === 0) {
    return fallbackNextDay();
  }

  const horizon = windows.reduce(
    (latest, w) => (w.date > latest ? w.date : latest),
    windows[0].date,
  );

  const existingInterviews = await prisma.interview.findMany({
    where: {
      managerId,
      status: { not: 'CANCELLED' },
      scheduledAt: { gte: now, lte: horizon },
    },
    select: { scheduledAt: true },
  });

  const taken = new Set(
    existingInterviews
      .filter((i) => i.scheduledAt)
      .map((i) => i.scheduledAt!.getTime()),
  );

  const freeSlots: Date[] = [];

  for (const window of windows) {
    const [startHour, startMinute] = window.startTime.split(':').map(Number);
    const [endHour, endMinute] = window.endTime.split(':').map(Number);

    const windowStart = new Date(window.date);
    windowStart.setHours(startHour, startMinute, 0, 0);

    const windowEnd = new Date(window.date);
    windowEnd.setHours(endHour, endMinute, 0, 0);

    const slot = new Date(windowStart);

    while (
      slot.getTime() + durationMinutes * 60000 <=
      windowEnd.getTime()
    ) {
      if (slot.getTime() > now.getTime() && !taken.has(slot.getTime())) {
        freeSlots.push(new Date(slot));
      }

      slot.setMinutes(slot.getMinutes() + durationMinutes);
    }
  }

  if (freeSlots.length === 0) {
    return fallbackNextDay();
  }

  const earliest = freeSlots[0];
  const minNoticeMs = minNoticeHours * 60 * 60000;

  if (earliest.getTime() - now.getTime() >= minNoticeMs) {
    return earliest;
  }

  const earliestDay = new Date(earliest);
  earliestDay.setHours(0, 0, 0, 0);

  const nextDaySlot = freeSlots.find((slot) => {
    const day = new Date(slot);
    day.setHours(0, 0, 0, 0);
    return day.getTime() > earliestDay.getTime();
  });

  return nextDaySlot ?? fallbackNextDay();
}
