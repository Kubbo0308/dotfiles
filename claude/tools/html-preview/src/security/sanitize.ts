const UNSAFE_URL_PREFIXES = [
  "javascript:",
  "vbscript:",
  "data:text/html",
  "data:text/javascript",
  "data:application/javascript",
];

export const isSafeUrl = (url: string): boolean => {
  const trimmed = url.trim().toLowerCase();
  return !UNSAFE_URL_PREFIXES.some((prefix) => trimmed.startsWith(prefix));
};

export const safeUrl = (url: string): string => (isSafeUrl(url) ? url : "#blocked-unsafe-url");
