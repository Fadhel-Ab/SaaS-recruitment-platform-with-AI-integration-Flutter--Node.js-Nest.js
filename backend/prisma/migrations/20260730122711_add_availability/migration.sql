/*
  Warnings:

  - You are about to drop the column `createdAt` on the `Availability` table. All the data in the column will be lost.
  - You are about to drop the column `updatedAt` on the `Availability` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "Availability" DROP COLUMN "createdAt",
DROP COLUMN "updatedAt",
ALTER COLUMN "dayOfWeek" SET DATA TYPE TEXT;
