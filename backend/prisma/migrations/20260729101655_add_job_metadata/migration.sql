-- CreateEnum
CREATE TYPE "SkillLevel" AS ENUM ('ENTRY', 'INTERMEDIATE', 'SENIOR', 'EXPERT');

-- CreateEnum
CREATE TYPE "JobStatus" AS ENUM ('ACTIVE', 'EXPIRED', 'FULFILLED');

-- AlterTable
ALTER TABLE "Job" ADD COLUMN     "companyName" TEXT NOT NULL DEFAULT 'anonymous',
ADD COLUMN     "skillLevel" "SkillLevel" NOT NULL DEFAULT 'ENTRY',
ADD COLUMN     "status" "JobStatus" NOT NULL DEFAULT 'ACTIVE';
