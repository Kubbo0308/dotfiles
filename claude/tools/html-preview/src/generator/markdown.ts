import { Marked, type RendererThis, type TokenizerAndRendererExtension, type Tokens } from "marked";
import { safeUrl } from "../security/sanitize.ts";
import { slugify } from "../slug.ts";
import { escapeHtml } from "./escape.ts";
import { type TocEntry, wrapInTemplate } from "./template.ts";

export type RenderInput = {
  title: string;
  markdown: string;
};

const VALID_CONTAINERS = ["note", "tip", "warning", "danger", "info"] as const;
type ContainerKind = (typeof VALID_CONTAINERS)[number];

const isValidContainerKind = (k: string): k is ContainerKind =>
  (VALID_CONTAINERS as readonly string[]).includes(k);

const stripHtmlTags = (html: string): string => html.replace(/<[^>]+>/g, "");

const containerExtension: TokenizerAndRendererExtension = {
  name: "container",
  level: "block",
  start(src: string): number | undefined {
    const idx = src.search(/^:::/m);
    return idx === -1 ? undefined : idx;
  },
  tokenizer(src: string) {
    const match = /^:::([a-z]+)(?:[ \t]+([^\n]+))?\n([\s\S]*?)\n:::(?:\n|$)/.exec(src);
    if (!match) return undefined;
    const [raw, kindRaw, titleRaw, contents] = match;
    const kind: ContainerKind = isValidContainerKind(kindRaw ?? "")
      ? (kindRaw as ContainerKind)
      : "note";
    return {
      type: "container",
      raw,
      kind,
      ttl: titleRaw?.trim() ?? "",
      tokens: this.lexer.blockTokens(contents ?? "", []),
    };
  },
  renderer(token) {
    const t = token as Tokens.Generic & { kind: ContainerKind; ttl: string; tokens: Tokens.Generic[] };
    const inner = this.parser.parse(t.tokens);
    const titleHtml = t.ttl
      ? `<div class="hp-container-title">${escapeHtml(t.ttl)}</div>`
      : "";
    return `<div class="hp-container hp-container-${t.kind}">${titleHtml}<div class="hp-container-body">${inner}</div></div>\n`;
  },
};

const mathExtension: TokenizerAndRendererExtension = {
  name: "blockMath",
  level: "block",
  start(src: string): number | undefined {
    const idx = src.indexOf("$$");
    return idx === -1 ? undefined : idx;
  },
  tokenizer(src: string) {
    const match = /^\$\$\n?([\s\S]+?)\n?\$\$(?:\n|$)/.exec(src);
    if (!match) return undefined;
    return { type: "blockMath", raw: match[0], text: (match[1] ?? "").trim() };
  },
  renderer(token) {
    const t = token as Tokens.Generic & { text: string };
    return `<div class="hp-math" data-math="${escapeHtml(t.text)}"></div>\n`;
  },
};

const buildMarked = (toc: TocEntry[], usedIds: Set<string>): Marked => {
  const m = new Marked();

  m.use({
    extensions: [containerExtension, mathExtension],
    renderer: {
      heading(this: RendererThis, { tokens, depth }: Tokens.Heading): string {
        const inline = this.parser.parseInline(tokens);
        const plain = stripHtmlTags(inline);
        const baseId = slugify(plain, { fallback: "section" });
        let id = baseId;
        let n = 1;
        while (usedIds.has(id)) {
          n += 1;
          id = `${baseId}-${n}`;
        }
        usedIds.add(id);
        if (depth >= 2 && depth <= 3) {
          toc.push({ level: depth, text: plain, id });
        }
        return `<h${depth} id="${escapeHtml(id)}">${inline}</h${depth}>\n`;
      },
      code({ text, lang }: Tokens.Code): string {
        if (lang === "chart") {
          return `<div class="hp-chart"><canvas data-chart="${escapeHtml(text)}"></canvas></div>\n`;
        }
        if (lang === "mermaid") {
          return `<pre class="mermaid">${escapeHtml(text)}</pre>\n`;
        }
        const langClass = lang ? ` language-${escapeHtml(lang)}` : "";
        return `<div class="hp-codeblock"><button type="button" class="hp-copy" aria-label="Copy code">Copy</button><pre><code class="hljs${langClass}">${escapeHtml(text)}</code></pre></div>\n`;
      },
      image({ href, title, text }: Tokens.Image): string {
        const titleAttr = title ? ` title="${escapeHtml(title)}"` : "";
        return `<img src="${escapeHtml(safeUrl(href))}" alt="${escapeHtml(text)}"${titleAttr} loading="lazy" data-zoomable>`;
      },
      link(this: RendererThis, { href, title, tokens }: Tokens.Link): string {
        const titleAttr = title ? ` title="${escapeHtml(title)}"` : "";
        const inner = this.parser.parseInline(tokens);
        return `<a href="${escapeHtml(safeUrl(href))}"${titleAttr} rel="noopener noreferrer">${inner}</a>`;
      },
    },
  });

  return m;
};

export const renderHtml = (input: RenderInput): string => {
  const toc: TocEntry[] = [];
  const usedIds = new Set<string>();
  const marked = buildMarked(toc, usedIds);
  const body = marked.parse(input.markdown, {
    async: false,
    gfm: true,
    breaks: false,
  }) as string;
  return wrapInTemplate({
    title: input.title,
    body,
    toc,
    generatedAt: new Date().toISOString(),
  });
};
