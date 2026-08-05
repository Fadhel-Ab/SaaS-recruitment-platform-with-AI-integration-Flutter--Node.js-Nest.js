# Pre Seeded Credentials

login as Manager or create an account

(Note: current phone number for this manager account is set to my personal number, for testing you can change it by clicking Profile/User icon on top right on Dashboard page)

Jasim@test.com
123456

# Testing Guide

Quick-start guide for manually testing the SaaS Recruitment Platform. This is for testers/QA/recruiters trying out the app — see [README.md](README.md) for full architecture, setup, and configuration docs.

## Test Manager Account

| Field | Value |
| --- | --- |
| Email | `<fill in>` |
| Password | `<fill in>` |
| Phone | `<fill in>` |

Log in at the app's `/login` screen with the credentials above to test manager-side flows (posting jobs, reviewing applications, scheduling interviews, dashboard).

To test candidate-side flows, either register a new candidate account or use "Browse Jobs Without an Account" on the login screen and apply to a job as a guest.

## WhatsApp Sandbox Opt-In (Required First)

**Before testing anything WhatsApp-related, send this from WhatsApp:**

> Send **`join prevent-activity`** to **+1 415-523-8886**

Do this with whichever phone number you're using to test (the manager account's phone and/or the phone number you enter on a job application) — otherwise Twilio silently won't deliver anything to that number. Full details, including why this step exists, are in [README.md § WhatsApp Sandbox Opt-In](README.md#whatsapp-sandbox-opt-in-required-for-testers-and-recruiters).

Reminder: phone fields throughout the app expect an 8-digit Bahrain number (stored as `+973XXXXXXXX`).

## What to Test

### Jobs list

- [ ] Urgent job(s) appear first in the list, at the same card size as regular jobs, with orange styling and a fire icon — no separate pinned/horizontal-scroll section.
- [ ] Changing "Sort By" (Newest/Oldest) reorders regular jobs by date but never bumps urgent jobs out of the leading position.
- [ ] Opening a job then tapping back returns to the jobs list.
- [ ] Opening a job, tapping Apply, then tapping back returns to the job details page (not straight to the list).

### Registration & login

- [ ] Selecting "Manager" on the register screen shows a required Bahrain phone field; selecting "Candidate" hides it.
- [ ] A registered manager's phone is saved and used for WhatsApp notifications.
- [ ] "Browse Jobs Without an Account" on the login screen goes straight to the public jobs list.

### Applying to a job

- [ ] Submitting an application with a resume that clearly doesn't match the job (low AI score) shows a success dialog and returns you to the jobs list — it should never leave the submit button stuck spinning.
- [ ] Submitting a strong match resume shows the AI-calling interface instead.
- [ ] The manager tied to that job receives a WhatsApp alert (requires sandbox opt-in — see above).

### Manager dashboard

- [ ] The Candidate Pipeline chart's "Shortlisted" and "Interviews Booked" segments update as an application moves through those statuses (shortlist a candidate, then schedule their interview, and confirm both segments reflect it instead of the candidate disappearing from the chart).

### Scheduling

- [ ] Interview times a manager picks and the times shown to the candidate match actual Bahrain local time (no offset).

### Mobile layout

- [ ] The bottom navigation bar on phone-width screens looks compact, not oversized with excess whitespace.

## Known Behaviors (Not Bugs)

- AI resume scoring depends on the configured Gemini model; an empty or irrelevant resume should score near 0, which is expected and is what drives the "didn't meet threshold" success-dialog path above.
- WhatsApp/AI-interview-call notifications are soft-failed server-side — if Twilio isn't configured correctly (e.g. sandbox opt-in missed), the candidate's application still submits successfully; only the notification silently fails (check backend logs).
- The AI interview phone number (**+1 908-493-4924**) is separate from the WhatsApp sandbox number above — you don't message it, you just receive/answer calls from it.
- The AI interview call sometimes takes a couple of trials to actually come through — this looks like a long-distance/carrier-routing quirk on Twilio's side rather than an app bug. If a call doesn't land on the first try, wait a bit and try again (or reply `CALL` on WhatsApp to re-trigger it) before assuming something's broken.
