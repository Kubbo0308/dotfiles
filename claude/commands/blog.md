# /blog

## Overview

Automatically generates technical blog articles based on recent implementation work and technical initiatives.

## Execution Details

1. **Implementation History Analysis**

   - Review recent git commit history
   - Analyze implementation logs in `_docs/` directory
   - Investigate changed files and their contents

2. **Research & Fact Verification**

   - Use agent teams (web-researcher, gemini-search) for data gathering
   - **CRITICAL: Verify every URL cited in the article actually exists and returns content**
   - Never cite URLs that return 404, bot protection pages, or empty content
   - Prefer primary sources (research papers, official docs) over secondary blog posts

3. **Article Structure Generation**

   - Technical challenges and solutions
   - Implementation highlights and learnings
   - Code examples and best practices
   - Applicable knowledge for other developers

4. **Blog Article Creation**
   - Generate technical articles in Markdown format
   - SEO-conscious titles and structure
   - Practical content including actual code examples
   - Save to `_docs/blog/` directory

## Writing Style

### Tone: Formal + Professional

The article should maintain a **formal, professional tone** while remaining approachable. Avoid overly casual expressions.

| NG (カジュアルすぎる) | OK (フォーマル寄り) |
|---|---|
| 〜ですよね | 〜のも事実です |
| 見てみましょう | 確認します |
| 衝撃的ですよね | 注目すべき点です |
| じゃあ〜 | それでは〜 |
| 〜なんです | 〜という事実があります |
| 始めましょう | 推奨します |

### Opening Greeting

The opening greeting is the **only casual element** allowed. Keep the personal touch here:

```
こんにちは！H×Hのセンリツ大好きエンジニアです！✌️
```

After the greeting, switch to formal tone for the rest of the article.

## Essential Elements

### Required Components

- **Format**: Markdown output
- **SEO Optimization**: Meta elements and structured content
- **Writing Style**: Formal yet approachable (maintaining technical credibility)
- **Reading Time**: In the Introduction section, measure the approximate word count and add: "この記事はおよそ〇〇字なので、○ 分で読めます！"
- **AI Disclosure**: At the end of the Introduction section, add as a blockquote: "> ※この記事はAIと2人3脚で執筆されています"

### Recommended Elements

- **Links**: Include links to related technologies and tools (verified URLs only)
- **Code Blocks**: Appropriate code samples for technical content
- **Emojis**: Use moderately in headings and callouts
- **Accordion Content**: Use `<details>/<summary>` for long code blocks or supplementary details

## Markdown Formatting Rules

### MUST Follow

1. **Code blocks MUST have language identifiers** — bare ``` without a language causes white/unstyled rendering
   - Good: ```typescript, ```yaml, ```markdown
   - Bad: ``` (no language)

2. **Do NOT use ASCII art or box-drawing characters** — they render broken on the blog. Use markdown lists instead.
   - NG: ┌──┐ │ text │ └──┘
   - OK: **Bold headers** with bullet point lists

3. **Tables must be simple** — complex multi-column tables with long content may break layout

4. **All headings use emoji** — H2 headings should include a relevant emoji at the end (e.g., `## Section Title 📊`)

5. **Do NOT use `---` (horizontal rules) between sections** — headings already provide visual separation, and `---` creates redundant lines on the blog

6. **Inline citations are MANDATORY** — when mentioning any person, study, article, or external source, always include a link to the source at or near the first mention. Readers should never encounter a name or claim without knowing where it comes from. Use `[Name (Source)](URL)` format inline, not just in the references section at the end

### Accordion Usage

Use `<details>/<summary>` for:
- Code blocks longer than ~15 lines
- Supplementary configuration examples
- Step-by-step details that aren't essential to the main narrative

```markdown
<details>
<summary>実装の詳細コード（30行）</summary>

```typescript
// code here
```

</details>
```

## URL Verification Protocol

**Every external URL in the article MUST be verified before inclusion.**

1. Use WebFetch or gemini-search agents to confirm the URL returns actual content
2. If a URL is behind bot protection (Cloudflare, Vercel security checkpoint), find an alternative source
3. Prefer these source types (in order of reliability):
   - Academic papers / research publications
   - Official documentation / company engineering blogs
   - Reputable tech publications (InfoWorld, IEEE, etc.)
   - Well-known developer blogs with established credibility
4. When citing statistics, always include the source link in a table or inline reference

## Article Structure Template

```markdown
# タイトル — サブタイトル

## この記事について 📖

**対象読者:** / **この記事で扱うこと:**

## はじめに 👋

> ※この記事はAIと2人3脚で執筆されています

挨拶 + 記事の概要（フォーマル調）

> この記事はおよそ〇〇字なので、○ 分で読めます！

## 目次 📚

1. [セクション1](#anchor)
2. [セクション2](#anchor)

## 1. セクション — サブタイトル 📊

*「セクションの要約を一文で（フォーマル調）」*

### 小見出し

本文（データ、テーブル、コード例を含む）

## まとめ 🎊

要点をリスト形式で整理

## 参考リンク 🔗

カテゴリ別にリンクを整理
```

## SEO Optimization Checklist

- [ ] Include keywords in title
- [ ] Use heading tags (H1-H6) appropriately
- [ ] Place internal links appropriately
- [ ] Include meta description equivalent introduction
- [ ] Naturally place related keywords
- [ ] Maintain appropriate word count (2000+ words recommended)
- [ ] Use accordions for long code blocks to improve readability

## Important Notes

- **Content Accuracy**: Always reference repository information and verify facts
- **Links**: Every URL must be verified as accessible before inclusion
- **No ASCII Art**: Use markdown formatting only — no box-drawing characters
- **Code Block Languages**: Always specify the language identifier
- **Currency**: Clearly state the time of writing as technical information changes

## Output

Save to: `_docs/blog/YYYY-MM-DD-title-in-kebab-case.md`

Execute after implementation completion to create articles about the day's technical work.
