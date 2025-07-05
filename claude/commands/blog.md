# /blog

## Overview

Automatically generates technical blog articles based on recent implementation work and technical initiatives.

## Execution Details

1. **Implementation History Analysis**
   - Review recent git commit history
   - Analyze implementation logs in `_docs/` directory
   - Investigate changed files and their contents

2. **Article Structure Generation**
   - Technical challenges and solutions
   - Implementation highlights and learnings
   - Code examples and best practices
   - Applicable knowledge for other developers

3. **Blog Article Creation**
   - Generate technical articles in Markdown format
   - SEO-conscious titles and structure
   - Practical content including actual code examples
   - Save to `_docs/blog/` directory

## AI Writing Prompt Template

When generating articles, use this effective prompt template for **Japanese articles**:

```
Please write an article about [TARGET SITE/PRODUCT] in Markdown format in Japanese.

## Requirements
- Create an SEO-conscious structure
- Include a table of contents
- Use a slightly casual but respectful tone (polite Japanese style)
- Include emojis and decorative elements (colors, bold, italics) for engagement
- Avoid Kansai dialect
- Make it as rich and readable as possible
- Write entirely in Japanese

## Article Overview
- [Overview Point 1]
- [Overview Point 2] 
- [Overview Point 3]

## Instructions
I'll provide only the overview, so fill in details by referencing repository information.
Feel free to insert images and links throughout to make it as rich and readable as possible.
All content should be written in Japanese.
```

## Essential Elements

### Required Components
- **Format**: Markdown output
- **SEO Optimization**: Meta elements and structured content
- **Table of Contents**: Essential for readability and SEO
- **Writing Style**: Friendly yet professional (maintaining technical credibility)
- **First Comment**: In the Introduction section, measure the approximate word count of this article and how long it will take to read it, then add the text "この記事はおよそ〇〇字なので、○分で読めます！"
- **Add Warning**: At the end of the Introduction section, add the following text:　"※この記事は7割程度がAIによって執筆されています。"

### Recommended Elements
- **Image Integration**: Utilize images from `/public` directory or external sources
- **Links**: Include links to related technologies and tools
- **Code Blocks**: Appropriate code samples for technical content
- **Emojis**: Use moderately to create approachability
- **Short Description**: Add a brief explanation of each section (including the H3 section), using humor occasionally.

### Writing Style Patterns

#### Pattern 1: Polite + Casual (Recommended)
```
# Example Opening Greeting (in Japanese)
こんにちは！H×Hのセンリツ大好きエンジニアです！✌️
```

## SEO Optimization Checklist

### Essential Items
- [ ] Include keywords in title
- [ ] Structure with table of contents
- [ ] Use heading tags (H1-H6) appropriately
- [ ] Set alt attributes for images
- [ ] Place internal links appropriately
- [ ] Include meta description equivalent introduction

### Recommended Items
- [ ] Naturally place related keywords
- [ ] Create readable text structure
- [ ] Maintain appropriate word count (2000+ words recommended)
- [ ] Include social sharing images

## Article Structure Template (Japanese)

````markdown
# メインタイトル - キーワード含む魅力的なタイトル

## 目次

1. [はじめに](#はじめに)
2. [【対象】とは？](#対象とは)
3. [特徴・機能](#特徴機能)
4. [技術スタック](#技術スタック)
5. [制作のポイント](#制作のポイント)
6. [今後の展望](#今後の展望)
7. [まとめ](#まとめ)

## はじめに

親しみやすい挨拶と記事の概要

![関連画像](path/to/image.png)

## 【対象】とは？

対象の説明と特徴

### 主な目的

- 目的 1
- 目的 2
- 目的 3

> 💡 **ポイント**: 重要な情報をコールアウトで強調

## 技術的な詳細

コードブロックや技術的説明

```typescript
// サンプルコード
interface Example {
  property: string;
}
```

## まとめ

記事の要点をまとめ
````

## Common Revision Patterns

### Frequent Revision Requests
1. **Custom Greetings**: Change to personalized greetings
2. **Technical Detail Addition**: More specific implementation methods
3. **Image Addition**: More visual elements
4. **SEO Enhancement**: Keyword density and structure optimization

### Revision Request Template
```
Please change the opening greeting to "[CUSTOM GREETING]".
Also, change from [ORIGINAL STYLE] to [DESIRED STYLE].
Keep the same tone for emojis and !? punctuation.
All content should remain in Japanese.
```

## Target Content

- React/Next.js component development
- Type-safe implementation with TypeScript
- Test-Driven Development (TDD) practices
- Performance optimization
- User experience improvements
- Development tool utilization

## Important Notes

- **Content Accuracy**: Always reference repository information
- **Image Paths**: Specify actually existing paths
- **Links**: Use valid URLs
- **Copyright**: Pay attention to rights of images and content used
- **Currency**: Clearly state the time of writing as technical information changes

## Output Example

```
_docs/blog/2025-06-19-Jest-test-environment-setup-and-comprehensive-test-suite.md
```

## Usage Example

```
/blog
```

Execute after implementation completion to create articles about the day's technical work.
