import { escapeHtml } from "./escape.ts";

export type TocEntry = {
  level: number;
  text: string;
  id: string;
};

export type WrapInput = {
  title: string;
  body: string;
  toc: TocEntry[];
  generatedAt: string;
};

const HLJS_VERSION = "11.10.0";
const MERMAID_VERSION = "11.4.1";
const CHARTJS_VERSION = "4.4.7";
const KATEX_VERSION = "0.16.11";

const renderToc = (toc: TocEntry[]): string => {
  if (toc.length < 2) return "";
  const items = toc
    .map(
      (e) =>
        `<li class="hp-toc-l${e.level}"><a href="#${escapeHtml(e.id)}" data-toc-target="${escapeHtml(e.id)}">${escapeHtml(e.text)}</a></li>`,
    )
    .join("");
  return `<nav class="hp-toc" aria-label="Table of contents"><div class="hp-toc-title">Contents</div><ul>${items}</ul></nav>`;
};

const STYLE = `
:root{--hp-bg:#fafafa;--hp-fg:#1a1a1a;--hp-muted:#57606a;--hp-border:#e5e5e5;--hp-link:#0969da;--hp-card:#fff;--hp-code-bg:#f0f0f0;--hp-pre-bg:#1e1e1e;--hp-pre-fg:#e8e8e8;--hp-shadow:0 1px 3px rgba(0,0,0,.06)}
:root.dark{--hp-bg:#0d1117;--hp-fg:#e6edf3;--hp-muted:#8d96a0;--hp-border:#30363d;--hp-link:#58a6ff;--hp-card:#161b22;--hp-code-bg:#262c36;--hp-pre-bg:#0d1117;--hp-pre-fg:#e6edf3;--hp-shadow:0 1px 3px rgba(0,0,0,.4)}
@media (prefers-color-scheme:dark){:root:not(.light){--hp-bg:#0d1117;--hp-fg:#e6edf3;--hp-muted:#8d96a0;--hp-border:#30363d;--hp-link:#58a6ff;--hp-card:#161b22;--hp-code-bg:#262c36;--hp-pre-bg:#0d1117;--hp-pre-fg:#e6edf3;--hp-shadow:0 1px 3px rgba(0,0,0,.4)}}
*,*::before,*::after{box-sizing:border-box}
html{color-scheme:light dark;-webkit-text-size-adjust:100%;scroll-behavior:smooth;scroll-padding-top:24px}
body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Hiragino Kaku Gothic ProN","Noto Sans JP",sans-serif;line-height:1.7;color:var(--hp-fg);background:var(--hp-bg);margin:0;padding:0}
.hp-layout{max-width:1200px;margin:0 auto;padding:32px 20px 96px;display:grid;grid-template-columns:1fr;gap:24px}
@media (min-width:1024px){.hp-layout{grid-template-columns:220px 1fr;gap:48px;padding:48px 32px 96px}}
main{min-width:0}
h1,h2,h3,h4{line-height:1.3;font-weight:700;margin:1.6em 0 .6em;scroll-margin-top:24px}
h1{font-size:2rem;border-bottom:1px solid var(--hp-border);padding-bottom:.4em;margin-top:0}
h2{font-size:1.5rem}
h3{font-size:1.2rem}
h4{font-size:1.05rem}
p{margin:1em 0}
a{color:var(--hp-link);text-decoration:none}
a:hover{text-decoration:underline}
code{font-family:"SFMono-Regular",Consolas,"Liberation Mono",Menlo,monospace;font-size:.9em;background:var(--hp-code-bg);padding:.15em .35em;border-radius:4px}
.hp-codeblock{position:relative;margin:1em 0}
.hp-codeblock pre{background:var(--hp-pre-bg);color:var(--hp-pre-fg);padding:16px;border-radius:8px;overflow-x:auto;line-height:1.5;font-size:.875rem;margin:0}
.hp-codeblock pre code{background:transparent;padding:0;color:inherit;font-family:inherit}
.hp-copy{position:absolute;top:8px;right:8px;background:rgba(255,255,255,.08);color:#e8e8e8;border:1px solid rgba(255,255,255,.15);border-radius:6px;padding:4px 10px;font-size:.75rem;cursor:pointer;opacity:0;transition:opacity .15s,background .15s;font-family:inherit}
.hp-codeblock:hover .hp-copy,.hp-copy:focus{opacity:1}
.hp-copy:hover{background:rgba(255,255,255,.16)}
.hp-copy.is-ok{background:#238636;border-color:#238636;color:#fff;opacity:1}
blockquote{border-left:4px solid var(--hp-border);color:var(--hp-muted);margin:1em 0;padding:.4em 1em}
ul,ol{padding-left:1.6em}
li{margin:.3em 0}
table{border-collapse:collapse;width:100%;margin:1em 0;font-size:.95rem;display:block;overflow-x:auto}
th,td{border:1px solid var(--hp-border);padding:8px 12px;text-align:left}
th{background:var(--hp-card);font-weight:600}
img{max-width:100%;height:auto;border-radius:6px;cursor:zoom-in}
hr{border:none;border-top:1px solid var(--hp-border);margin:2em 0}
.hp-meta{color:var(--hp-muted);font-size:.875rem;margin-bottom:2rem}
.hp-toc{position:sticky;top:24px;align-self:start;font-size:.875rem;max-height:calc(100vh - 48px);overflow-y:auto;padding-right:8px}
.hp-toc-title{font-weight:700;color:var(--hp-muted);text-transform:uppercase;letter-spacing:.05em;font-size:.75rem;margin-bottom:8px}
.hp-toc ul{list-style:none;padding:0;margin:0;border-left:1px solid var(--hp-border)}
.hp-toc li{margin:0}
.hp-toc a{display:block;padding:4px 12px;color:var(--hp-muted);border-left:2px solid transparent;margin-left:-1px;transition:color .15s,border-color .15s}
.hp-toc a:hover{color:var(--hp-fg);text-decoration:none}
.hp-toc a.is-active{color:var(--hp-link);border-left-color:var(--hp-link);font-weight:500}
.hp-toc-l3 a{padding-left:24px;font-size:.825rem}
@media (max-width:1023px){.hp-toc{position:static;max-height:none;border:1px solid var(--hp-border);border-radius:8px;padding:12px 16px}}
.hp-container{margin:1.2em 0;padding:12px 16px;border-radius:8px;border-left:4px solid;background:var(--hp-card);box-shadow:var(--hp-shadow)}
.hp-container-title{font-weight:700;margin-bottom:6px}
.hp-container-body>:first-child{margin-top:0}
.hp-container-body>:last-child{margin-bottom:0}
.hp-container-note{border-left-color:#0969da}.hp-container-note .hp-container-title::before{content:"💡 "}
.hp-container-tip{border-left-color:#1a7f37}.hp-container-tip .hp-container-title::before{content:"✨ "}
.hp-container-warning{border-left-color:#bf8700}.hp-container-warning .hp-container-title::before{content:"⚠️ "}
.hp-container-danger{border-left-color:#cf222e}.hp-container-danger .hp-container-title::before{content:"🚨 "}
.hp-container-info{border-left-color:#8250df}.hp-container-info .hp-container-title::before{content:"ℹ️ "}
.hp-chart{margin:1.2em 0;padding:16px;background:var(--hp-card);border:1px solid var(--hp-border);border-radius:8px}
.hp-chart canvas{max-height:400px}
.mermaid{margin:1.2em 0;padding:16px;background:var(--hp-card);border:1px solid var(--hp-border);border-radius:8px;text-align:center;overflow-x:auto}
.hp-math{margin:1.2em 0;text-align:center;overflow-x:auto}
.hp-math-error{color:#cf222e;font-family:monospace;font-size:.875rem}
.hp-theme-toggle{position:fixed;top:16px;right:16px;width:40px;height:40px;border-radius:50%;background:var(--hp-card);border:1px solid var(--hp-border);color:var(--hp-fg);cursor:pointer;font-size:1.1rem;display:flex;align-items:center;justify-content:center;box-shadow:var(--hp-shadow);z-index:10;transition:transform .15s}
.hp-theme-toggle:hover{transform:scale(1.08)}
.hp-zoom-modal{position:fixed;inset:0;background:rgba(0,0,0,.85);display:none;align-items:center;justify-content:center;z-index:100;cursor:zoom-out;padding:24px}
.hp-zoom-modal.is-open{display:flex}
.hp-zoom-modal img{max-width:100%;max-height:100%;object-fit:contain;cursor:zoom-out}
@media print{
  body{background:#fff;color:#000}
  .hp-layout{display:block;padding:0;max-width:none}
  .hp-toc,.hp-theme-toggle,.hp-copy,.hp-zoom-modal{display:none!important}
  .hp-codeblock pre{background:#f5f5f5;color:#000;border:1px solid #ddd}
  a{color:#000;text-decoration:underline}
}
`.trim();

const buildScript = (toc: TocEntry[]): string => `
(() => {
  const root = document.documentElement;
  const STORAGE_KEY = "hp-theme";
  const TOC_IDS = ${JSON.stringify(toc.map((e) => e.id))};

  // Theme: light | dark | auto
  const applyTheme = (mode) => {
    root.classList.remove("light", "dark");
    if (mode === "light") root.classList.add("light");
    if (mode === "dark") root.classList.add("dark");
    const btn = document.querySelector(".hp-theme-toggle");
    if (btn) btn.textContent = mode === "dark" ? "☀️" : mode === "light" ? "🌙" : "🌓";
    if (window.mermaid) {
      const isDark = mode === "dark" || (mode === "auto" && matchMedia("(prefers-color-scheme: dark)").matches);
      window.mermaid.initialize({ startOnLoad: false, theme: isDark ? "dark" : "default", securityLevel: "strict" });
      document.querySelectorAll(".mermaid").forEach((el) => {
        if (el.dataset.source) el.textContent = el.dataset.source;
        el.removeAttribute("data-processed");
      });
      window.mermaid.run({ querySelector: ".mermaid" }).catch(() => {});
    }
  };
  const stored = localStorage.getItem(STORAGE_KEY) || "auto";
  applyTheme(stored);

  document.addEventListener("DOMContentLoaded", () => {
    const toggle = document.createElement("button");
    toggle.className = "hp-theme-toggle";
    toggle.title = "Toggle theme (light/dark/auto)";
    toggle.setAttribute("aria-label", "Toggle theme");
    toggle.textContent = "🌓";
    toggle.addEventListener("click", () => {
      const cur = localStorage.getItem(STORAGE_KEY) || "auto";
      const next = cur === "auto" ? "light" : cur === "light" ? "dark" : "auto";
      localStorage.setItem(STORAGE_KEY, next);
      applyTheme(next);
    });
    document.body.appendChild(toggle);
    applyTheme(stored);

    // Copy buttons
    document.querySelectorAll(".hp-copy").forEach((btn) => {
      btn.addEventListener("click", async () => {
        const code = btn.parentElement?.querySelector("code");
        if (!code) return;
        try {
          await navigator.clipboard.writeText(code.textContent || "");
          btn.classList.add("is-ok");
          const orig = btn.textContent;
          btn.textContent = "Copied!";
          setTimeout(() => {
            btn.classList.remove("is-ok");
            btn.textContent = orig || "Copy";
          }, 1200);
        } catch {}
      });
    });

    // Image zoom modal
    const modal = document.createElement("div");
    modal.className = "hp-zoom-modal";
    modal.innerHTML = '<img alt="" />';
    modal.addEventListener("click", () => modal.classList.remove("is-open"));
    document.body.appendChild(modal);
    document.querySelectorAll("img[data-zoomable]").forEach((img) => {
      img.addEventListener("click", () => {
        const m = modal.querySelector("img");
        if (!m) return;
        m.src = img.src;
        m.alt = img.alt;
        modal.classList.add("is-open");
      });
    });
    document.addEventListener("keydown", (e) => {
      if (e.key === "Escape") modal.classList.remove("is-open");
    });

    // Highlight.js
    if (window.hljs) document.querySelectorAll("pre code.hljs").forEach((el) => window.hljs.highlightElement(el));

    // Chart.js
    if (window.Chart) {
      document.querySelectorAll("canvas[data-chart]").forEach((canvas) => {
        try {
          const cfg = JSON.parse(canvas.dataset.chart);
          new window.Chart(canvas, cfg);
        } catch (e) {
          canvas.outerHTML = '<div class="hp-math-error">Chart parse error: ' + (e.message || e) + '</div>';
        }
      });
    }

    // KaTeX
    if (window.katex) {
      document.querySelectorAll(".hp-math[data-math]").forEach((el) => {
        try {
          window.katex.render(el.dataset.math, el, { displayMode: true, throwOnError: false });
        } catch (e) {
          el.innerHTML = '<span class="hp-math-error">' + (e.message || e) + '</span>';
        }
      });
    }

    // Mermaid: store source for theme re-render, then run
    document.querySelectorAll(".mermaid").forEach((el) => { el.dataset.source = el.textContent; });
    if (window.mermaid) {
      const isDark = (localStorage.getItem(STORAGE_KEY) || "auto") === "dark"
        || ((localStorage.getItem(STORAGE_KEY) || "auto") === "auto" && matchMedia("(prefers-color-scheme: dark)").matches);
      window.mermaid.initialize({ startOnLoad: false, theme: isDark ? "dark" : "default", securityLevel: "strict" });
      window.mermaid.run({ querySelector: ".mermaid" }).catch(() => {});
    }

    // TOC scroll-spy
    if (TOC_IDS.length >= 2 && "IntersectionObserver" in window) {
      const links = new Map(
        Array.from(document.querySelectorAll(".hp-toc a[data-toc-target]"))
          .map((a) => [a.dataset.tocTarget, a]),
      );
      const setActive = (id) => {
        links.forEach((a, k) => a.classList.toggle("is-active", k === id));
      };
      const observed = new Map();
      const observer = new IntersectionObserver(
        (entries) => {
          entries.forEach((e) => observed.set(e.target.id, e.isIntersecting));
          const visible = TOC_IDS.find((id) => observed.get(id));
          if (visible) setActive(visible);
        },
        { rootMargin: "-10% 0px -70% 0px", threshold: 0 },
      );
      TOC_IDS.forEach((id) => {
        const el = document.getElementById(id);
        if (el) observer.observe(el);
      });
    }
  });
})();
`.trim();

export const wrapInTemplate = ({ title, body, toc, generatedAt }: WrapInput): string => {
  const tocHtml = renderToc(toc);
  const script = buildScript(toc);
  return `<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="generator" content="html-preview">
<meta name="robots" content="noindex,nofollow">
<title>${escapeHtml(title)}</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@${HLJS_VERSION}/build/styles/atom-one-dark.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@${KATEX_VERSION}/dist/katex.min.css">
<style>${STYLE}</style>
</head>
<body>
<div class="hp-layout">
${tocHtml}
<main>
<h1>${escapeHtml(title)}</h1>
<div class="hp-meta">Generated: ${escapeHtml(generatedAt)}</div>
${body}
</main>
</div>
<script src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@${HLJS_VERSION}/build/highlight.min.js" defer></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js@${CHARTJS_VERSION}/dist/chart.umd.min.js" defer></script>
<script src="https://cdn.jsdelivr.net/npm/mermaid@${MERMAID_VERSION}/dist/mermaid.min.js" defer></script>
<script src="https://cdn.jsdelivr.net/npm/katex@${KATEX_VERSION}/dist/katex.min.js" defer></script>
<script>${script}</script>
</body>
</html>
`;
};
