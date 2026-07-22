/*
  Warnings:

  - The values [NOT_STARTED] on the enum `AIInterviewStatus` will be removed. If these variants are still used in the database, this will fail.

*/
-- AlterEnum
BEGIN;
CREATE TYPE "AIInterviewStatus_new" AS ENUM ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'FAILED');
ALTER TABLE "public"."AIInterviewSession" ALTER COLUMN "status" DROP DEFAULT;
ALTER TABLE "AIInterviewSession" ALTER COLUMN "status" TYPE "AIInterviewStatus_new" USING ("status"::text::"AIInterviewStatus_new");
ALTER TYPE "AIInterviewStatus" RENAME TO "AIInterviewStatus_old";
ALTER TYPE "AIInterviewStatus_new" RENAME TO "AIInterviewStatus";
DROP TYPE "public"."AIInterviewStatus_old";
ALTER TABLE "AIInterviewSession" ALTER COLUMN "status" SET DEFAULT 'PENDING';
COMMIT;
