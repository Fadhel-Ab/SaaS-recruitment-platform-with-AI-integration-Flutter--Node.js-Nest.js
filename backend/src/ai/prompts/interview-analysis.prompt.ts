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
