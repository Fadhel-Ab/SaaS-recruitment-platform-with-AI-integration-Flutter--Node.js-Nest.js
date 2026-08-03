/*
  Warnings:

  - Adds support for two availability modes: a repeating weekday
    ("RECURRING", using `dayOfWeek`) or a one-off calendar date
    ("SPECIFIC", using `date`, as introduced in the previous migration).
  - Existing rows all have a concrete `date` already, so they default to
    "SPECIFIC" and keep their date untouched.
*/

-- CreateEnum
CREATE TYPE "AvailabilityRecurrence" AS ENUM ('RECURRING', 'SPECIFIC');

-- AlterTable: Availability
ALTER TABLE "Availability" ADD COLUMN "recurrence" "AvailabilityRecurrence" NOT NULL DEFAULT 'SPECIFIC';
ALTER TABLE "Availability" ADD COLUMN "dayOfWeek" INTEGER;
ALTER TABLE "Availability" ALTER COLUMN "date" DROP NOT NULL;

-- AlterTable: JobAvailability
ALTER TABLE "JobAvailability" ADD COLUMN "recurrence" "AvailabilityRecurrence" NOT NULL DEFAULT 'SPECIFIC';
ALTER TABLE "JobAvailability" ADD COLUMN "dayOfWeek" INTEGER;
ALTER TABLE "JobAvailability" ALTER COLUMN "date" DROP NOT NULL;
