/*
  Warnings:

  - Replaces the recurring `dayOfWeek` (1-7, Mon-Sun) column on `Availability`
    and `JobAvailability` with a real calendar `date` column. Existing rows
    are backfilled to the next upcoming occurrence of their old weekday so no
    data is silently dropped, but going forward slots represent one specific
    date rather than a repeating weekday.
*/

-- AlterTable: Availability
ALTER TABLE "Availability" ADD COLUMN "date" DATE;

UPDATE "Availability"
SET "date" = CURRENT_DATE + ((("dayOfWeek" % 7) - EXTRACT(DOW FROM CURRENT_DATE)::int + 7) % 7);

ALTER TABLE "Availability" ALTER COLUMN "date" SET NOT NULL;
ALTER TABLE "Availability" DROP COLUMN "dayOfWeek";

-- AlterTable: JobAvailability
ALTER TABLE "JobAvailability" ADD COLUMN "date" DATE;

UPDATE "JobAvailability"
SET "date" = CURRENT_DATE + ((("dayOfWeek" % 7) - EXTRACT(DOW FROM CURRENT_DATE)::int + 7) % 7);

ALTER TABLE "JobAvailability" ALTER COLUMN "date" SET NOT NULL;
ALTER TABLE "JobAvailability" DROP COLUMN "dayOfWeek";
