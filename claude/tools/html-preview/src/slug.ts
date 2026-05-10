import { randomBytes } from "node:crypto";

const RANDOM_SUFFIX_LEN = 8;

type SlugifyOptions = {
  maxLen?: number;
  fallback?: string;
};

export const slugify = (s: string, opts: SlugifyOptions = {}): string => {
  const { maxLen, fallback = "untitled" } = opts;
  const base = s
    .normalize("NFKC")
    .toLowerCase()
    .replace(/\p{M}/gu, "")
    .replace(/[^\p{L}\p{N}\s_-]/gu, "")
    .trim()
    .replace(/[\s_-]+/g, "-")
    .replace(/^-+|-+$/g, "");
  const truncated = maxLen ? base.slice(0, maxLen) : base;
  return truncated.length > 0 ? truncated : fallback;
};

export const buildObjectPath = (slug: string): string => {
  const now = new Date();
  const ym = `${now.getUTCFullYear()}-${String(now.getUTCMonth() + 1).padStart(2, "0")}`;
  const random = randomBytes(6).toString("base64url").slice(0, RANDOM_SUFFIX_LEN).toLowerCase();
  return `outputs/${ym}/${random}-${slug}.html`;
};
