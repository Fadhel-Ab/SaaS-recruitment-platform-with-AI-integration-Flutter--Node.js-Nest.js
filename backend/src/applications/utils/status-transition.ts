import { ApplicationStatus } from '../../generated/prisma/enums.js';

export const allowedTransitions: Record<
  ApplicationStatus,
  ApplicationStatus[]
> = {
  PENDING: [
    ApplicationStatus.SHORTLISTED,
    ApplicationStatus.REJECTED,
    ApplicationStatus.WITHDRAWN,
  ],

  SHORTLISTED: [
    ApplicationStatus.INTERVIEW_SCHEDULED,
    ApplicationStatus.REJECTED,
  ],

  INTERVIEW_SCHEDULED: [ApplicationStatus.INTERVIEW_COMPLETED],

  INTERVIEW_COMPLETED: [ApplicationStatus.OFFERED, ApplicationStatus.REJECTED],

  OFFERED: [ApplicationStatus.HIRED, ApplicationStatus.REJECTED],

  HIRED: [],

  REJECTED: [],

  WITHDRAWN: [],
};
