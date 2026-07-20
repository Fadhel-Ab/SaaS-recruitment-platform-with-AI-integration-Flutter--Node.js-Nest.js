export function buildResumePrompt(resume: string, jobDescription: string) {
  return `
You are an experienced technical recruiter.

Analyze the resume against the job description.

Return ONLY valid JSON.

Resume:
${resume}

Job Description:
${jobDescription}

Required JSON format:

{
  "score":0,
  "strengths":[],
  "weaknesses":[],
  "summary":"",
  "recommendation":""
}
`;
}
