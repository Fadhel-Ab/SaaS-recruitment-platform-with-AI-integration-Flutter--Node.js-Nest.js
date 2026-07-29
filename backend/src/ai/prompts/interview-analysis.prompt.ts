export function buildInterviewPrompt(transcript: string): string {
  return `
You are a senior technical recruiter.

Evaluate the following interview transcript.

Give a score from 0-100 for:

- Communication
- Technical Knowledge
- Confidence
- Problem Solving

Return ONLY JSON.

{
  "communication":90,
  "technical":82,
  "confidence":88,
  "problemSolving":84,
  "summary":"..."
}

Transcript:

${transcript}
`;
}
export function buildInterviewQuestionPrompt(
  jobDescription: string,
  transcript: string,
) {
  return `
You are conducting a professional phone interview.

Job Description:

${jobDescription}

Conversation so far:

${transcript || 'No previous answers.'}

Generate ONLY the next interview question.

Rules:
- Ask only one question.
- Maximum 20 words.
- Do not greet.
- Do not evaluate.
- Do not number the question.
- Return plain text only.
`;
}
  