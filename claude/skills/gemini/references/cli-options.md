# Gemini CLI Options Reference

## Basic Usage

```bash
# Single-line prompt
gemini -p "your prompt here"

# File input
gemini --prompt="your prompt" --file="path/to/file"

# Multiple files
gemini --prompt="your prompt" --file="file1" --file="file2"

# Heredoc (recommended for complex prompts)
gemini <<EOF
Your multi-line prompt here
$(cat file.ts)
EOF

# Pipe stdin
cat file.ts | gemini -p "Review this code"
git diff | gemini -p "Review this diff"
```

## Web Search

```bash
# Standard web search
gemini -p "WebSearch: your query"

# Site-specific search
gemini -p "WebSearch: site:x.com query"
gemini -p "WebSearch: site:github.com query"
gemini -p "WebSearch: site:stackoverflow.com query"
```

## Configuration

### Environment Variables

```bash
export GEMINI_API_KEY="your-api-key"
export GEMINI_MODEL="gemini-2.5-pro"
```

### `.geminirc` Config File

```
model=gemini-2.5-pro
temperature=0.3
max_tokens=4096
```

## Tips

- Use `-p` for automation (non-interactive single prompt)
- Heredoc (`<<EOF`) is best for complex prompts with embedded code
- Pipe (`|`) is best for passing file contents or command output
- `--file` is best when Gemini needs to read files directly
