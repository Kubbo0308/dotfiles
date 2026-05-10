import type { Config } from "../config.ts";
import { HTML_CONTENT_TYPE, getStorage } from "./client.ts";

export type UploadInput = {
  config: Config;
  objectPath: string;
  html: string;
};

export type UploadResult = {
  bucket: string;
  objectPath: string;
};

export const uploadHtml = async (input: UploadInput): Promise<UploadResult> => {
  const { config, objectPath, html } = input;
  const file = getStorage(config).bucket(config.gcp.bucket).file(objectPath);
  await file.save(html, {
    contentType: HTML_CONTENT_TYPE,
    metadata: { cacheControl: "private, max-age=300" },
    resumable: false,
  });
  return { bucket: config.gcp.bucket, objectPath };
};
