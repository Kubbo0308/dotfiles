export type Severity = "high" | "medium" | "low";

export type SecretFinding = {
  pattern: string;
  severity: Severity;
  preview: string;
  line: number;
};

type SecretPattern = {
  name: string;
  regex: RegExp;
  severity: Severity;
};

const PATTERNS: readonly SecretPattern[] = [
  { name: "AWS Access Key ID", regex: /\bAKIA[0-9A-Z]{16}\b/g, severity: "high" },
  { name: "Google API Key", regex: /\bAIza[0-9A-Za-z_-]{35}\b/g, severity: "high" },
  { name: "GitHub Token", regex: /\bgh[pousr]_[A-Za-z0-9]{36,}\b/g, severity: "high" },
  { name: "Slack Token", regex: /\bxox[abprs]-[A-Za-z0-9-]{10,}\b/g, severity: "high" },
  { name: "OpenAI API Key", regex: /\bsk-(?:proj-)?[A-Za-z0-9_-]{20,}\b/g, severity: "high" },
  { name: "Anthropic API Key", regex: /\bsk-ant-[A-Za-z0-9_-]{20,}\b/g, severity: "high" },
  { name: "Stripe Key", regex: /\b(?:sk|pk|rk)_(?:test|live)_[A-Za-z0-9]{20,}\b/g, severity: "high" },
  {
    name: "Private Key Block",
    regex: /-----BEGIN (?:RSA |EC |DSA |OPENSSH |PGP |ENCRYPTED )?PRIVATE KEY( BLOCK)?-----/g,
    severity: "high",
  },
  {
    name: "JWT",
    regex: /\beyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\b/g,
    severity: "medium",
  },
  {
    name: "Password Assignment",
    regex: /(?:password|passwd|pwd|secret|apikey|api_key)\s*[:=]\s*["'][^"'\s]{8,}["']/gi,
    severity: "low",
  },
  {
    name: "Inline <script> tag",
    regex: /<script\b[^>]*>[\s\S]*?<\/script>/gi,
    severity: "medium",
  },
  {
    name: "<iframe> tag",
    regex: /<iframe\b[^>]*>/gi,
    severity: "low",
  },
];

const PREVIEW_HEAD = 6;
const PREVIEW_TAIL = 4;
const SHORT_THRESHOLD = 12;

const redact = (s: string): string => {
  if (s.length <= SHORT_THRESHOLD) return `${s.slice(0, 4)}…`;
  return `${s.slice(0, PREVIEW_HEAD)}…${s.slice(-PREVIEW_TAIL)}`;
};

const lineOf = (text: string, idx: number): number => {
  let line = 1;
  for (let i = 0; i < idx; i += 1) {
    if (text.charCodeAt(i) === 10) line += 1;
  }
  return line;
};

export const scanForSecrets = (text: string): SecretFinding[] => {
  const findings: SecretFinding[] = [];
  for (const p of PATTERNS) {
    for (const m of text.matchAll(p.regex)) {
      findings.push({
        pattern: p.name,
        severity: p.severity,
        preview: redact(m[0]),
        line: lineOf(text, m.index ?? 0),
      });
    }
  }
  return findings.sort((a, b) => a.line - b.line);
};

export const formatFindings = (findings: SecretFinding[]): string => {
  return findings
    .map((f) => `  • [${f.severity.toUpperCase()}] ${f.pattern} at line ${f.line}: ${f.preview}`)
    .join("\n");
};
