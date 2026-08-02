/// Mirrors backend/src/applications/utils/status-transition.ts so the UI only
/// offers status actions the server will actually accept.
const Map<String, List<String>> allowedStatusTransitions = {
  'PENDING': ['SHORTLISTED', 'REJECTED', 'WITHDRAWN'],
  'SHORTLISTED': ['INTERVIEW_SCHEDULED', 'REJECTED'],
  'INTERVIEW_SCHEDULED': ['INTERVIEW_COMPLETED'],
  'INTERVIEW_COMPLETED': ['OFFERED', 'REJECTED'],
  'OFFERED': ['HIRED', 'REJECTED'],
  'HIRED': [],
  'REJECTED': [],
  'WITHDRAWN': [],
};

String statusLabel(String status) {
  switch (status) {
    case 'PENDING':
      return 'Pending';
    case 'SHORTLISTED':
      return 'Shortlisted';
    case 'INTERVIEW_SCHEDULED':
      return 'Interview Scheduled';
    case 'INTERVIEW_COMPLETED':
      return 'Interview Completed';
    case 'OFFERED':
      return 'Offered';
    case 'HIRED':
      return 'Hired';
    case 'REJECTED':
      return 'Rejected';
    case 'WITHDRAWN':
      return 'Withdrawn';
    default:
      return status;
  }
}
