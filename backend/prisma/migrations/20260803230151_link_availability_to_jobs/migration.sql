/*
  Warnings:

  - You are about to drop the `JobAvailability` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "JobAvailability" DROP CONSTRAINT "JobAvailability_jobId_fkey";

-- AlterTable
ALTER TABLE "Availability" ADD COLUMN     "jobId" TEXT;

-- Preserve existing per-job slots before the table is dropped
INSERT INTO "Availability" (id, "managerId", "jobId", recurrence, date, "dayOfWeek", "startTime", "endTime")
SELECT ja.id, j."managerId", ja."jobId", ja.recurrence, ja.date, ja."dayOfWeek", ja."startTime", ja."endTime"
FROM "JobAvailability" ja JOIN "Job" j ON j.id = ja."jobId";

-- DropTable
DROP TABLE "JobAvailability";

-- AddForeignKey
ALTER TABLE "Availability" ADD CONSTRAINT "Availability_jobId_fkey" FOREIGN KEY ("jobId") REFERENCES "Job"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- CreateIndex
CREATE INDEX "Availability_jobId_idx" ON "Availability"("jobId");
