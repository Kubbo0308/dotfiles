import type { Config } from "../config.ts";
import { HTML_CONTENT_TYPE, getStorage } from "./client.ts";

export type SignInput = {
  config: Config;
  objectPath: string;
  expiresInDays: number;
};

export type SignResult = {
  url: string;
  expiresAt: Date;
};

const DAY_MS = 24 * 60 * 60 * 1000;

export const generateSignedUrl = async (input: SignInput): Promise<SignResult> => {
  const { config, objectPath, expiresInDays } = input;
  const expiresAt = new Date(Date.now() + expiresInDays * DAY_MS);
  const [url] = await getStorage(config)
    .bucket(config.gcp.bucket)
    .file(objectPath)
    .getSignedUrl({
      version: "v4",
      action: "read",
      expires: expiresAt,
      responseType: HTML_CONTENT_TYPE,
      responseDisposition: "inline",
    });
  return { url, expiresAt };
};
