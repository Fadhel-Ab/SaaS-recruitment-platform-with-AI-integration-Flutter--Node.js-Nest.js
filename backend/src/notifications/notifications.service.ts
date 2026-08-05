import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { PrismaService } from '../prisma/prisma.service.js';
import { TwilioService } from '../twilio/twilio.service.js';
import { InterviewStatus } from '../generated/prisma/enums.js';
import { DEFAULT_MIN_NOTICE_HOURS } from '../scheduling/util/find-next-slot.js';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(
    private prisma: PrismaService,
    private twilio: TwilioService,
  ) {}

  /**
   * Every morning at 8am, tells each manager how many interviews they have
   * scheduled today, with candidate names and AI summary scores, over
   * WhatsApp. Only covers interviews already SCHEDULED (i.e. candidates the
   * manager previously approved and got auto-booked), grouped by manager.
   */
  @Cron('0 8 * * *')
  async sendManagerDailyDigest() {
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const endOfDay = new Date(startOfDay);
    endOfDay.setDate(endOfDay.getDate() + 1);

    const interviews = await this.prisma.interview.findMany({
      where: {
        status: InterviewStatus.SCHEDULED,
        scheduledAt: { gte: startOfDay, lt: endOfDay },
      },
      include: {
        manager: true,
        application: {
          include: {
            candidate: true,
            aiScore: true,
          },
        },
      },
      orderBy: { scheduledAt: 'asc' },
    });

    const byManager = new Map<string, typeof interviews>();

    for (const interview of interviews) {
      const list = byManager.get(interview.managerId) ?? [];
      list.push(interview);
      byManager.set(interview.managerId, list);
    }

    for (const [managerId, managerInterviews] of byManager) {
      const manager = managerInterviews[0].manager;

      if (!manager.phone) {
        this.logger.warn(
          `Manager ${managerId} has ${managerInterviews.length} interview(s) today but no phone on file, skipping digest`,
        );
        continue;
      }

      const lines = managerInterviews.map((interview, index) => {
        const time = interview.scheduledAt!.toLocaleTimeString('en-US', {
          hour: 'numeric',
          minute: '2-digit',
        });
        const name = interview.application.candidate.fullName;
        const score = interview.application.aiScore?.overallScore;

        return `${index + 1}. ${name} at ${time}${score != null ? ` — AI score: ${score}%` : ''}`;
      });

      const message =
        `Good morning ${manager.fullName}! You have ${managerInterviews.length} interview${managerInterviews.length === 1 ? '' : 's'} scheduled today:\n\n` +
        lines.join('\n');

      try {
        await this.twilio.sendWhatsApp(manager.phone, message);
      } catch (error) {
        this.logger.error(
          `Failed to send daily digest to manager ${managerId}`,
          error instanceof Error ? error.stack : error,
        );
      }
    }
  }

  /**
   * Every 15 minutes, WhatsApps a reminder to any candidate whose interview
   * has crossed the `DEFAULT_MIN_NOTICE_HOURS`-before mark (the same notice
   * window candidates were promised when the slot was booked - see
   * find-next-slot.ts). `reminderSentAt` guards against re-sending on the
   * next tick.
   */
  @Cron('*/15 * * * *')
  async sendInterviewReminders() {
    const now = new Date();
    const reminderThreshold = new Date(
      now.getTime() + DEFAULT_MIN_NOTICE_HOURS * 60 * 60000,
    );

    const interviews = await this.prisma.interview.findMany({
      where: {
        status: InterviewStatus.SCHEDULED,
        reminderSentAt: null,
        scheduledAt: { gte: now, lte: reminderThreshold },
      },
      include: {
        application: {
          include: { candidate: true, job: true },
        },
      },
    });

    for (const interview of interviews) {
      const { candidate, job } = interview.application;

      if (!candidate.phone) {
        this.logger.debug(
          `Interview ${interview.id} candidate has no phone on file, skipping reminder`,
        );
        continue;
      }

      try {
        await this.twilio.sendInterviewReminder(
          candidate.phone,
          candidate.fullName,
          job.title,
          interview.scheduledAt!,
        );

        await this.prisma.interview.update({
          where: { id: interview.id },
          data: { reminderSentAt: now },
        });
      } catch (error) {
        this.logger.error(
          `Failed to send interview reminder for interview ${interview.id}`,
          error instanceof Error ? error.stack : error,
        );
      }
    }
  }
}
