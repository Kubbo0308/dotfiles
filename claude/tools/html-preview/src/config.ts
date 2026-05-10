import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { CliError, EXIT } from "./errors.ts";

export type Config = {
  gcp: {
    projectId: string;
    bucket: string;
    credentialsPath: string;
  };
  defaults: {
    expiresInDays: number;
  };
};

export const MAX_EXPIRES_DAYS = 7;
export const MIN_EXPIRES_DAYS = 1;

const CONFIG_PATH = join(homedir(), ".config", "html-preview", "config.json");

const expandHome = (p: string): string =>
  p.startsWith("~/") ? join(homedir(), p.slice(2)) : p;

const readConfigFile = (): string => {
  try {
    return readFileSync(CONFIG_PATH, "utf8");
  } catch (e) {
    if ((e as NodeJS.ErrnoException).code === "ENOENT") {
      throw new CliError(
        `Config not found at ${CONFIG_PATH}. Run Phase 1 setup first.`,
        EXIT.CONFIG,
      );
    }
    throw new CliError(`Cannot read ${CONFIG_PATH}: ${(e as Error).message}`, EXIT.CONFIG);
  }
};

const parseConfig = (raw: string): Partial<Config> => {
  try {
    return JSON.parse(raw) as Partial<Config>;
  } catch (e) {
    throw new CliError(`Failed to parse ${CONFIG_PATH}: ${(e as Error).message}`, EXIT.CONFIG);
  }
};

export const loadConfig = (): Config => {
  const parsed = parseConfig(readConfigFile());
  const projectId = process.env.HTML_PREVIEW_PROJECT_ID ?? parsed.gcp?.projectId;
  const bucket = process.env.HTML_PREVIEW_BUCKET ?? parsed.gcp?.bucket;
  const credentialsPath =
    process.env.GOOGLE_APPLICATION_CREDENTIALS ??
    (parsed.gcp?.credentialsPath ? expandHome(parsed.gcp.credentialsPath) : undefined);

  if (!projectId || !bucket || !credentialsPath) {
    throw new CliError(
      "Missing required config: gcp.projectId, gcp.bucket, gcp.credentialsPath",
      EXIT.CONFIG,
    );
  }

  const requested = parsed.defaults?.expiresInDays ?? MAX_EXPIRES_DAYS;
  if (requested > MAX_EXPIRES_DAYS) {
    process.stderr.write(
      `Warning: defaults.expiresInDays=${requested} exceeds GCS V4 limit (${MAX_EXPIRES_DAYS}); clamped.\n`,
    );
  }
  const expiresInDays = Math.min(MAX_EXPIRES_DAYS, requested);

  return {
    gcp: { projectId, bucket, credentialsPath },
    defaults: { expiresInDays },
  };
};
