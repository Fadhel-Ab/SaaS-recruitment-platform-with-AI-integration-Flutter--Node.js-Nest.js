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
  "score": number,
  "summary": string,
  "recommendation": string
}

Transcript:

${transcript}
`;
}
export function buildInterviewQuestionSetPrompt(
  jobDescription: string,
  count: number,
): string {
  return `
You are a senior technical recruiter preparing a phone interview.

Job Description:

${jobDescription}

Generate exactly ${count} distinct interview questions for this role.

Rules:
- Cover a mix of role-specific and behavioral questions.
- Each question maximum 20 words.
- Do not number the questions.
- Do not repeat or rephrase the same question.
- Return ONLY a JSON array of ${count} strings, e.g. ["question one", "question two"].
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
