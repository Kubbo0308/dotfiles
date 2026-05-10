#!/usr/bin/env -S npx tsx
import { readFile, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { Command } from "commander";
import { type Config, MAX_EXPIRES_DAYS, MIN_EXPIRES_DAYS, loadConfig } from "../src/config.ts";
import { CliError, EXIT, formatGcsError } from "../src/errors.ts";
import { renderHtml } from "../src/generator/markdown.ts";
import { formatFindings, scanForSecrets } from "../src/security/secretScan.ts";
import { buildObjectPath, slugify } from "../src/slug.ts";

type Options = {
  title?: string;
  content?: string;
  contentFromFile?: string;
  expires?: string;
  slug?: string;
  dryRun?: boolean;
  open?: boolean;
  allowSecrets?: boolean;
};

const STDIN_SENTINEL = "-";
const SLUG_MAX_LEN = 60;

const readStdin = async (): Promise<string> => {
  const chunks: Buffer[] = [];
  for await (const chunk of process.stdin) {
    chunks.push(chunk as Buffer);
  }
  return Buffer.concat(chunks).toString("utf8");
};

const resolveContent = async (opts: Options): Promise<string> => {
  if (opts.content !== undefined) return opts.content;
  if (opts.contentFromFile === STDIN_SENTINEL) return readStdin();
  if (opts.contentFromFile) {
    try {
      return await readFile(opts.contentFromFile, "utf8");
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      throw new CliError(`Cannot read ${opts.contentFromFile}: ${msg}`, EXIT.INPUT);
    }
  }
  throw new CliError(
    'Provide --content <markdown> or --content-from-file <path|->. Use "-" for stdin.',
    EXIT.INPUT,
  );
};

const clampDays = (n: number): number => {
  if (!Number.isFinite(n)) return MAX_EXPIRES_DAYS;
  const clamped = Math.min(MAX_EXPIRES_DAYS, Math.max(MIN_EXPIRES_DAYS, n));
  if (clamped !== n) {
    process.stderr.write(
      `Warning: --expires ${n} clamped to ${clamped} (range: ${MIN_EXPIRES_DAYS}-${MAX_EXPIRES_DAYS}).\n`,
    );
  }
  return clamped;
};

const openInBrowser = async (url: string): Promise<void> => {
  const { spawn } = await import("node:child_process");
  const cmd =
    process.platform === "darwin" ? "open" : process.platform === "win32" ? "start" : "xdg-open";
  spawn(cmd, [url], { detached: true, stdio: "ignore" }).unref();
};

const checkSecrets = (markdown: string, allowSecrets: boolean): void => {
  if (allowSecrets) return;
  const findings = scanForSecrets(markdown);
  if (findings.length === 0) return;
  process.stderr.write(`⚠️  Detected ${findings.length} potential secret(s):\n`);
  process.stderr.write(`${formatFindings(findings)}\n\n`);
  process.stderr.write("Aborted. Pass --allow-secrets if these are intentional.\n");
  throw new CliError("Secrets detected in input", EXIT.SECRETS_DETECTED, { silent: true });
};

const runDryRun = async (slug: string, html: string, openAfter: boolean): Promise<void> => {
  const out = join(tmpdir(), `html-preview-${slug}-${Date.now()}.html`);
  await writeFile(out, html, "utf8");
  console.log(`[dry-run] HTML written to: ${out}`);
  if (openAfter) await openInBrowser(`file://${out}`);
};

const runUpload = async (
  config: Config,
  title: string,
  slug: string,
  html: string,
  expiresInDays: number,
  openAfter: boolean,
): Promise<void> => {
  const objectPath = buildObjectPath(slug);
  const [{ uploadHtml }, { generateSignedUrl }] = await Promise.all([
    import("../src/storage/gcs.ts"),
    import("../src/storage/signedUrl.ts"),
  ]);

  let url: string;
  let expiresAt: Date;
  try {
    const [, signed] = await Promise.all([
      uploadHtml({ config, objectPath, html }),
      generateSignedUrl({ config, objectPath, expiresInDays }),
    ]);
    url = signed.url;
    expiresAt = signed.expiresAt;
  } catch (e) {
    throw new CliError(formatGcsError(e), EXIT.UPLOAD);
  }

  console.log(`📎 ${url}`);
  console.log(`⏰ Expires: ${expiresAt.toISOString()}`);
  console.log(`📄 Title:   ${title}`);
  console.log(`🪣 Object:  gs://${config.gcp.bucket}/${objectPath}`);

  if (openAfter) await openInBrowser(url);
};

const main = async (): Promise<void> => {
  const program = new Command();
  program
    .name("html-preview")
    .description("Convert markdown to a self-contained HTML page, upload to GCS, return a signed URL.")
    .option("-t, --title <text>", "Page title")
    .option("-c, --content <markdown>", "Inline markdown content")
    .option("-f, --content-from-file <path|->", 'Read markdown from a file (use "-" for stdin)')
    .option("-e, --expires <days>", `Signed URL validity (${MIN_EXPIRES_DAYS}-${MAX_EXPIRES_DAYS} days)`)
    .option("-s, --slug <text>", "Custom URL slug")
    .option("--dry-run", "Generate HTML locally without uploading")
    .option("--open", "Open the generated/uploaded URL in the browser")
    .option("--allow-secrets", "Skip secret detection (use with caution)");

  program.parse();
  const opts = program.opts<Options>();

  const config = loadConfig();
  const markdown = await resolveContent(opts);
  checkSecrets(markdown, opts.allowSecrets ?? false);

  const title = opts.title ?? "Untitled";
  const slug = slugify(opts.slug ?? title, { maxLen: SLUG_MAX_LEN });
  const html = renderHtml({ title, markdown });

  if (opts.dryRun) {
    await runDryRun(slug, html, opts.open ?? false);
    return;
  }

  const expiresInDays = clampDays(
    opts.expires ? Number.parseFloat(opts.expires) : config.defaults.expiresInDays,
  );
  await runUpload(config, title, slug, html, expiresInDays, opts.open ?? false);
};

main().catch((err: unknown) => {
  if (err instanceof CliError) {
    if (!err.silent) process.stderr.write(`Error: ${err.message}\n`);
    process.exit(err.exitCode);
  }
  const message = err instanceof Error ? err.message : String(err);
  process.stderr.write(`Error: ${message}\n`);
  process.exit(EXIT.GENERIC);
});
