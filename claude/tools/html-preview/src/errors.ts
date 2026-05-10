export const EXIT = {
  SUCCESS: 0,
  GENERIC: 1,
  CONFIG: 2,
  SECRETS_DETECTED: 3,
  UPLOAD: 4,
  INPUT: 5,
} as const;

export type ExitCode = (typeof EXIT)[keyof typeof EXIT];

export type CliErrorOptions = {
  silent?: boolean;
};

export class CliError extends Error {
  readonly exitCode: ExitCode;
  readonly silent: boolean;
  constructor(message: string, exitCode: ExitCode = EXIT.GENERIC, opts: CliErrorOptions = {}) {
    super(message);
    this.name = "CliError";
    this.exitCode = exitCode;
    this.silent = opts.silent ?? false;
  }
}

const isObject = (v: unknown): v is Record<string, unknown> =>
  typeof v === "object" && v !== null;

const codeOf = (e: unknown): string | undefined => {
  if (!isObject(e)) return undefined;
  const c = e.code;
  return typeof c === "string" ? c : undefined;
};

const statusOf = (e: unknown): number | undefined => {
  if (!isObject(e)) return undefined;
  const code = e.code;
  if (typeof code === "number") return code;
  const status = (e as { status?: unknown }).status;
  return typeof status === "number" ? status : undefined;
};

const NETWORK_CODES = new Set(["ENOTFOUND", "ECONNREFUSED", "ETIMEDOUT", "EAI_AGAIN"]);

export const formatGcsError = (e: unknown): string => {
  const status = statusOf(e);
  const errCode = codeOf(e);
  const baseMsg = e instanceof Error ? e.message : String(e);

  switch (status) {
    case 401:
    case 403:
      return `Authentication failed (HTTP ${status}). Verify ~/.config/html-preview/sa.json and that the SA has roles/storage.objectAdmin on the bucket.\n  Underlying: ${baseMsg}`;
    case 404:
      return `Bucket or object not found (HTTP 404). Check gcp.bucket in config.json.\n  Underlying: ${baseMsg}`;
  }
  if (errCode && NETWORK_CODES.has(errCode)) {
    return `Network error (${errCode}). Check your internet connection.\n  Underlying: ${baseMsg}`;
  }
  return baseMsg;
};
