# SaaS Recruitment Platform with AI Integration

A full-stack recruitment SaaS platform that helps hiring managers publish jobs, collect candidate applications, evaluate resumes with AI, run phone-based AI interview workflows, schedule interviews, and monitor hiring pipeline performance from a Flutter interface backed by a NestJS API.

## Project at a Glance

- **Frontend:** Flutter application for web, mobile, and desktop targets.
- **Backend:** NestJS 11 REST API written in TypeScript.
- **Database:** PostgreSQL accessed through Prisma ORM.
- **Authentication:** JWT-based authentication with manager and candidate roles.
- **AI:** Google Gemini integration for resume analysis, interview analysis, and interview question generation.
- **Storage:** Supabase Storage for private resume uploads and signed resume URLs.
- **Communications:** Twilio phone calls, voice webhooks, call-status webhooks, and WhatsApp follow-ups.
- **Deployment hints:** Backend is configured for a `/api` global prefix; frontend currently points to a Railway production API URL.

## Repository Structure

```text
.
├── backend/                 # NestJS API, Prisma schema, tests, generated Prisma client
│   ├── prisma/              # PostgreSQL Prisma schema and migrations
│   ├── src/                 # API modules, controllers, services, guards, DTOs, AI prompts
│   └── test/                # NestJS e2e test configuration
└── frontend/                # Flutter application
    ├── lib/                 # App shell, router, core API/storage/theme code, feature modules
    ├── android/ ios/ web/ windows/  # Platform targets
    └── pubspec.yaml         # Flutter dependencies and metadata
```

## Core Product Capabilities

### Authentication and Roles

- User registration and login with JWT access tokens.
- Role-aware access control for **MANAGER** and **CANDIDATE** users.
- Global JWT and roles guards on protected backend routes.
- Public endpoints for login, registration, public job browsing, job details by share token, resume upload, and applying to a job.

### Job Management

Managers can:

- Create jobs with title, description, requirements, company name, location, employment type, urgency, and skill level.
- Generate interview questions for a job using AI.
- View their own jobs.
- Update existing jobs.
- Fetch applications attached to a job.
- Share public job links using a unique share token.
- Configure default availability for scheduling.

Candidates and public users can:

- Browse active jobs.
- Open a job by its share token.
- Submit an application through the public application flow.

### Candidate Applications

The application workflow supports:

- Candidate profile capture: name, email, phone, and optional linked user account.
- Resume upload through multipart form data.
- Supabase-backed private resume storage.
- Automatic AI resume scoring against the job description.
- Application status tracking through the hiring pipeline.
- Candidate self-service view for “my applications.”
- Manager views for job applicants, application details, and candidate pipeline.
- Bulk status updates for multiple applications.

### AI Screening and Interviewing

The backend includes AI services for:

- Resume parsing and analysis.
- Resume-to-job scoring.
- Structured strengths, weaknesses, summary, and recommendation output.
- Interview transcript analysis.
- Follow-up interview question generation.
- Job-specific interview question set generation.
- A configurable AI interview threshold that determines which candidates can proceed to AI interview flow.

### Phone and WhatsApp Integrations

Twilio integration supports:

- Starting AI interview phone calls.
- Receiving Twilio voice webhook requests.
- Recording or processing candidate answers through AI interview endpoints.
- Completing AI interviews and updating application scores.
- Call status callbacks for completed, busy, no-answer, and failed calls.
- WhatsApp notifications, including missed-call follow-up messages.

### Scheduling and Availability

The project includes scheduling modules for:

- Manager availability slots.
- Specific-date or recurring availability.
- Job-specific availability.
- Generating interview schedule options for a job.
- Confirming an interview schedule.
- Creating manager interviews tied to applications.

### Dashboard and Search

Managers have dashboard and search capabilities, including:

- Active job count.
- Total and pending applications.
- Shortlisted, offered, hired, and rejected counts.
- AI interview totals and completed AI interviews.
- Scheduled and completed manager interviews.
- Average AI score.
- Seven-day sparkline data and week-over-week trend percentages.
- Candidate/job/application search endpoints and frontend search delegate support.

## Backend Overview

### Main Modules

The NestJS API is composed of these primary modules:

- `AuthModule` — registration, login, JWT strategy, role decorators, guards.
- `UsersModule` — user service/controller foundation.
- `JobsModule` — job creation, updates, public listing, share-token lookup, AI-generated interview questions.
- `ApplicationsModule` — application submission, resume upload, candidate pipeline, application details, status updates.
- `AiModule` — Gemini provider, resume parser, resume/interview analysis prompts.
- `AiInterviewModule` — phone-based AI interview lifecycle and Twilio voice handling.
- `InterviewsModule` — manager interview creation.
- `AvailabilityModule` — manager availability CRUD.
- `SchedulingModule` — schedule generation and confirmation.
- `DashboardModule` — manager dashboard summary metrics.
- `SearchModule` — manager search.
- `TwilioModule` — calls, WhatsApp, and call status handling.
- `CommonModule` / `StorageModule` — shared helpers, exception filter, file upload configuration, Supabase storage.
- `PrismaModule` — PostgreSQL database access through Prisma.

### API Prefix and Runtime Behavior

- The API uses a global `/api` prefix.
- Helmet is enabled for security headers.
- CORS is enabled.
- Global validation uses NestJS `ValidationPipe` with whitelisting, transformation, and non-whitelisted-field rejection.
- Global throttling defaults to 100 requests per 60 seconds, with stricter throttles on login, registration, and AI question generation.
- The default port is `3000`, overridable with `PORT`.

### Main API Endpoints

All routes below are under the `/api` prefix unless noted.

| Area | Method/Path | Purpose |
| --- | --- | --- |
| Health/root | `GET /` | Basic app controller endpoint |
| Auth | `POST /auth/register` | Register a user |
| Auth | `POST /auth/login` | Login and receive JWT auth data |
| Auth | `GET /auth/me` | Return current JWT user |
| Auth | `GET /auth/profile` | Return request user profile |
| Jobs | `GET /jobs` | Public active jobs list |
| Jobs | `GET /jobs/:token` | Public job lookup by share token |
| Jobs | `POST /jobs` | Manager creates a job |
| Jobs | `PATCH /jobs/:id` | Manager updates a job |
| Jobs | `GET /jobs/my` | Manager jobs |
| Jobs | `GET /jobs/default-availability` | Manager default availability |
| Jobs | `GET /jobs/:id/applications` | Manager job applications |
| Jobs | `POST /jobs/generate-interview-questions` | AI-generate questions from job details |
| Applications | `POST /applications/upload` | Public resume upload |
| Applications | `POST /applications/:shareToken` | Public/candidate application submission |
| Applications | `GET /applications/mine` | Candidate application list |
| Applications | `GET /applications/job/:jobId` | Manager job applications |
| Applications | `GET /applications/pipeline` | Manager candidate pipeline |
| Applications | `GET /applications/:applicationId` | Manager application details |
| Applications | `PATCH /applications/:applicationId/status` | Manager status update |
| Applications | `PATCH /applications/bulk-status` | Manager bulk status update |
| Availability | `POST /availability` | Create availability slot |
| Availability | `GET /availability/my` | Manager availability |
| Availability | `PATCH /availability/:id` | Update availability slot |
| Availability | `DELETE /availability/:id` | Delete availability slot |
| Scheduling | `POST /scheduler/jobs/:jobId/generate` | Generate schedule options |
| Scheduling | `POST /scheduler/jobs/:jobId/confirm` | Confirm interview schedule |
| Interviews | `POST /interviews/:applicationId` | Create manager interview |
| AI Interview | `POST /ai-interview/test-call` | Trigger test AI interview call |
| AI Interview | `POST /ai-interview/:id/start-call` | Start application AI interview call |
| AI Interview | `POST /ai-interview/complete` | Complete AI interview |
| AI Interview | `POST /ai-interview/voice` | Twilio voice webhook |
| AI Interview | `POST /ai-interview/answer` | Process AI interview answer |
| Dashboard | `GET /dashboard` | Manager dashboard summary |
| Search | `GET /search` | Manager search |
| Twilio | `POST /twilio/whatsapp` | WhatsApp webhook/handling |
| Twilio | `POST /twilio/call-status` | Twilio call status callback |

## Database Model Summary

The Prisma schema models the recruitment workflow around these entities:

- **User** — authenticated account with role, jobs, availability, interviews, and optional candidate profile.
- **Job** — manager-owned posting with public share token, status, requirements, generated questions, and availability.
- **Candidate** — candidate profile with resume filename, phone number, optional linked user account, and applications.
- **Application** — candidate submission to a job with pipeline status, AI score, manager interview, and AI interview session.
- **AIScore** — CV score, interview score, overall score, strengths, weaknesses, summary, and recommendation.
- **Availability** — manager availability slot tied optionally to a job, either recurring or date-specific.
- **Interview** — manager interview schedule and status.
- **AIInterviewSession** — phone AI interview status, transcript, question count, summary, timestamps, and duration.

Important enums include:

- `UserRole`: `MANAGER`, `CANDIDATE`
- `ApplicationStatus`: `PENDING`, `SHORTLISTED`, `INTERVIEW_SCHEDULED`, `INTERVIEW_COMPLETED`, `OFFERED`, `HIRED`, `REJECTED`, `WITHDRAWN`
- `InterviewStatus`: `PENDING`, `SCHEDULED`, `COMPLETED`, `CANCELLED`, `NO_SHOW`
- `AIInterviewStatus`: `PENDING`, `IN_PROGRESS`, `COMPLETED`, `FAILED`
- `EmploymentType`: `FULL_TIME`, `PART_TIME`, `CONTRACT`, `INTERNSHIP`, `REMOTE`
- `JobStatus`: `ACTIVE`, `EXPIRED`, `FULFILLED`
- `AvailabilityRecurrence`: `RECURRING`, `SPECIFIC`

## Frontend Overview

The Flutter app is organized by feature and uses:

- `go_router` for navigation.
- `flutter_bloc` and `equatable` for state management.
- `dio` for API calls.
- `flutter_secure_storage` and `shared_preferences` for token/session persistence.
- `file_picker` for resume upload.
- `url_launcher` for opening external links.

### Frontend Routes

| Route | Screen/Purpose |
| --- | --- |
| `/login` | Login screen |
| `/register` | Registration screen |
| `/dashboard` | Manager dashboard |
| `/jobs` | Public/candidate job list |
| `/jobs/:shareToken` | Job details |
| `/apply/:shareToken` | Application form and resume upload |
| `/manager/jobs` | Manager job list |
| `/manager/create-job` | Create job form |
| `/manager/jobs/:jobId/edit` | Edit job form |
| `/manager/jobs/:jobId/applicants` | Applicants for a job |
| `/manager/applications/:applicationId` | Application detail view |
| `/my-applications` | Candidate application history |
| `/manager/availability` | Manager availability management |
| `/manager/candidates` | Candidate pipeline |

Authenticated users are redirected by role: managers are sent toward dashboard/manager screens, while candidates are sent toward jobs and candidate screens.

## Configuration

### Backend Environment Variables

Create a backend `.env` file with the variables required by the enabled integrations:

```bash
DATABASE_URL="postgresql://USER:PASSWORD@HOST:PORT/DATABASE"
JWT_SECRET="replace-with-a-secure-secret"
GEMINI_API_KEY="your-google-genai-key"
GEMINI_MODEL="gemini-3.5-flash-lite"
AI_INTERVIEW_THRESHOLD=60
SUPABASE_URL="https://your-project.supabase.co"
SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"
SUPABASE_RESUME_BUCKET="resumes"
TWILIO_ACCOUNT_SID="your-twilio-account-sid"
TWILIO_AUTH_TOKEN="your-twilio-auth-token"
TWILIO_PHONE_NUMBER="+15555555555"
TWILIO_WHATSAPP_FROM="whatsapp:+14155238886"
TWILIO_WEBHOOK_URL="https://your-public-backend.example.com"
TWILIO_TEST_PHONE_NUMBER="+15555555555"
PORT=3000
```

Notes:

- `DATABASE_URL` is required by Prisma and the backend database adapter.
- `JWT_SECRET` is required for auth token signing and verification.
- `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are required because resume storage is initialized at runtime.
- `GEMINI_MODEL` is optional; the AI provider falls back to `gemini-3.5-flash-lite`.
- `AI_INTERVIEW_THRESHOLD` defaults to `60` when not provided by config lookups.
- `TWILIO_WEBHOOK_URL` must be a public URL reachable by Twilio for voice and call-status callbacks.

### Frontend API URL

The frontend API base URL is currently hard-coded in:

```text
frontend/lib/core/api/api_constants.dart
```

It points to a Railway production backend ending in `/api`. For local development, change it to a local backend URL such as:

```dart
static const String baseUrl = 'http://localhost:3000/api';
```

For Android emulator local backend access, use `http://10.0.2.2:3000/api`.

## Local Development

### Prerequisites

- Node.js and npm compatible with the backend dependencies.
- Flutter SDK compatible with Dart `^3.12.2`.
- PostgreSQL database.
- Supabase project/bucket for resume storage.
- Google Gemini API key.
- Twilio account and public webhook URL if testing calls/WhatsApp.

### Backend Setup

```bash
cd backend
npm install
npx prisma generate
npx prisma migrate deploy
npm run start:dev
```

Useful backend commands:

```bash
npm run build
npm run format
npm run test
npm run test:e2e
npm run test:cov
```

### Frontend Setup

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

Useful frontend commands:

```bash
flutter analyze
flutter test
flutter build web
```

## Typical User Flows

### Manager Flow

1. Register or log in as a manager.
2. Create a job and optionally generate interview questions with AI.
3. Share the public job/application link with candidates.
4. Review submitted applications and AI resume scores.
5. Shortlist candidates or update statuses in bulk.
6. Start AI interview calls for qualified candidates.
7. Review AI interview summaries and scores.
8. Configure availability and schedule manager interviews.
9. Track hiring progress from the dashboard and candidate pipeline.

### Candidate Flow

1. Register/log in or open a public job link.
2. Browse available jobs or open a shared job link.
3. Upload a resume and submit application details.
4. Track submitted applications in “My Applications” when logged in.
5. Receive AI interview calls or WhatsApp follow-up messages when triggered by the manager/backend flow.

## Testing Status and Existing Test Layout

The backend includes Jest unit test files beside most controllers/services and an e2e test under `backend/test`. The frontend includes the Flutter test dependency but no dedicated feature test files are visible in `frontend/lib`.

## Security and Privacy Notes

- Resume files are stored privately in Supabase and exposed through time-limited signed URLs.
- JWT and role guards protect manager and candidate endpoints.
- Request validation strips unknown fields and rejects non-whitelisted input.
- Helmet is enabled on the backend.
- Public endpoints should be reviewed carefully before production launch because they include resume upload and public application submission.

## Current Implementation Notes

- The backend uses ESM-style TypeScript imports with `.js` extensions.
- Prisma client output is configured under `backend/src/generated/prisma`.
- The API global prefix is `/api`, so frontend and webhook URLs should include that prefix.
- `StorageService` requires Supabase credentials at startup.
- AI functionality depends on Gemini response formats being valid JSON for analysis operations.
- The frontend currently has production backend URL configuration committed in code; consider environment-specific configuration before wider deployment.
