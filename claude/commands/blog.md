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
- **Writing Style**: Friendly yet professional (maintaining technical credibility)
- **First Comment**: In the Introduction section, measure the approximate word count of this article and how long it will take to read it, then add the text "この記事はおよそ〇〇字なので、○ 分で読めます！"
- **Add Warning**: At the end of the Introduction section, add the following text:"※この記事は 7 割程度が AI によって執筆されています。"

### Recommended Elements

- **Image Integration**: Utilize images from `/public` directory or external sources
- **Links**: Include links to related technologies and tools
- **Code Blocks**: Appropriate code samples for technical content
- **Emojis**: Use moderately to create approachability
- **Short Description**: Add a brief explanation of each section (including the H3 section), using humor occasionally.
- **Accordion Content**: Use accordions for long code blocks or detailed explanations to improve readability

### Writing Style Patterns

#### Pattern 1: Polite + Casual (Recommended)

```
# Example Opening Greeting (in Japanese)
こんにちは！H×Hのセンリツ大好きエンジニアです！✌️
```

## SEO Optimization Checklist

### Essential Items

- [ ] Include keywords in title
- [ ] Use heading tags (H1-H6) appropriately
- [ ] Set alt attributes for images
- [ ] Place internal links appropriately
- [ ] Include meta description equivalent introduction

### Recommended Items

- [ ] Naturally place related keywords
- [ ] Create readable text structure
- [ ] Maintain appropriate word count (2000+ words recommended)
- [ ] Include social sharing images
- [ ] Use accordions for long code blocks and detailed explanations to improve readability

## Article Structure Template (Japanese)

````markdown
# メインタイトル - キーワード含む魅力的なタイトル

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

## Accordion Usage Guidelines

### When to Use Accordions

Use accordions to improve article readability in the following scenarios:

#### 1. Long Code Blocks (Automatic)
- Code blocks with 15+ lines automatically become collapsible
- Shows language, line count, and copy functionality
- Provides expand/collapse controls for better content scanning

#### 2. Detailed Explanations (Manual)
Use `<details>` and `<summary>` tags for:
- Step-by-step tutorials that might overwhelm readers
- Optional advanced configuration details
- Troubleshooting sections
- Additional examples or variations
- Background information that's helpful but not essential

### Accordion Syntax

#### Details/Summary Accordion
```markdown
<details>
<summary>長いコード例やクリック時に表示したい内容のタイトル</summary>

ここに詳細な説明やコードを記述します。

```python
# 長いコード例
def complex_function():
    # 実装詳細
    pass
```

追加の説明文もここに含めることができます。
</details>
```

#### Best Practices for Accordion Content

1. **Clear Summary Titles**: Use descriptive titles that explain what's inside
   ```markdown
   <summary>認証機能の詳細実装コード (50行)</summary>
   <summary>エラーハンドリングのベストプラクティス</summary>
   <summary>パフォーマンス最適化の追加手法</summary>
   ```

2. **Appropriate Content**: Use accordions for:
   - Complete code files or large code blocks
   - Detailed configuration examples
   - Advanced usage patterns
   - Debugging information
   - Reference materials

3. **Content Organization**: Structure accordion content well:
   ```markdown
   <details>
   <summary>データベース設定の詳細</summary>
   
   ## 環境別設定
   
   ### 開発環境
   ```yaml
   database:
     host: localhost
     port: 5432
   ```
   
   ### 本番環境
   ```yaml
   database:
     host: prod-server
     port: 5432
   ```
   
   ## 接続プールの設定
   
   詳細な説明...
   </details>
   ```

### Content Flow Guidelines

1. **Main Content First**: Keep essential information outside accordions
2. **Progressive Disclosure**: Use accordions for additional depth
3. **Logical Grouping**: Group related information in single accordions
4. **Scannable Structure**: Ensure article remains readable when accordions are collapsed

### Examples in Context

#### Good Usage:
```markdown
## API の実装

基本的な API エンドポイントを作成します：

```javascript
app.get('/api/users', (req, res) => {
  res.json({ users: [] });
});
```

<details>
<summary>エラーハンドリングとバリデーションを含む完全版</summary>

```javascript
app.get('/api/users', async (req, res) => {
  try {
    // バリデーション
    const { page = 1, limit = 10 } = req.query;
    
    // データ取得
    const users = await User.findAll({
      offset: (page - 1) * limit,
      limit: parseInt(limit)
    });
    
    res.json({
      users,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: await User.count()
      }
    });
  } catch (error) {
    console.error('Users API Error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});
```

この実装には以下の改善点が含まれています：
- リクエストパラメータのバリデーション
- ページネーション機能
- エラーハンドリング
- ログ出力
</details>
```

#### Avoid:
- Using accordions for essential information readers need
- Creating too many nested accordions
- Using accordions for short content (< 5 lines)
- Unclear or generic summary titles

## Common Revision Patterns

### Frequent Revision Requests

1. **Custom Greetings**: Change to personalized greetings
2. **Technical Detail Addition**: More specific implementation methods
3. **Image Addition**: More visual elements
4. **SEO Enhancement**: Keyword density and structure optimization
5. **Content Organization**: Adding accordions for better content flow and readability

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
