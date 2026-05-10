import { Storage } from "@google-cloud/storage";
import type { Config } from "../config.ts";

export const HTML_CONTENT_TYPE = "text/html; charset=utf-8";

let cached: { key: string; storage: Storage } | undefined;

export const getStorage = (config: Config): Storage => {
  const key = `${config.gcp.projectId}::${config.gcp.credentialsPath}`;
  if (cached?.key === key) return cached.storage;
  const storage = new Storage({
    projectId: config.gcp.projectId,
    keyFilename: config.gcp.credentialsPath,
  });
  cached = { key, storage };
  return storage;
};
