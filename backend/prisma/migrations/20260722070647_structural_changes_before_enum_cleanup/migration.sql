/*
  Warnings:

  - You are about to drop the `AIInterview` table. If the table is not empty, all the data it contains will be lost.

*/
-- AlterEnum
ALTER TYPE "AIInterviewStatus" ADD VALUE 'PENDING';

-- DropForeignKey
ALTER TABLE "AIInterview" DROP CONSTRAINT "AIInterview_applicationId_fkey";

-- DropTable
DROP TABLE "AIInterview";

-- CreateTable
CREATE TABLE "AIInterviewSession" (
    "id" TEXT NOT NULL,
    "applicationId" TEXT NOT NULL,
    "status" "AIInterviewStatus" NOT NULL DEFAULT 'PENDING',
    "transcript" TEXT,
    "summary" TEXT,
    "startedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "duration" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AIInterviewSession_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "AIInterviewSession_applicationId_key" ON "AIInterviewSession"("applicationId");

-- AddForeignKey
ALTER TABLE "AIInterviewSession" ADD CONSTRAINT "AIInterviewSession_applicationId_fkey" FOREIGN KEY ("applicationId") REFERENCES "Application"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
