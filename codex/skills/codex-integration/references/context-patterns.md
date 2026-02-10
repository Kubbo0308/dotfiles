# Codex Context Passing Patterns

## 1. Stdin with Pipe

```bash
# Simple content
echo "Code: function test() {}" | codex exec --full-auto -

# File content
cat src/main.ts | codex exec --full-auto -
```

## 2. Here-doc (Recommended for Complex Context)

```bash
codex exec --full-auto - <<'EOF'
Here is the code to analyze:
$(cat src/main.ts)

Please review for potential issues.
EOF
```

## 3. Combining Multiple Sources

```bash
{
  echo "=== package.json ==="
  cat package.json
  echo ""
  echo "=== Recent changes ==="
  git diff HEAD~5
  echo ""
  echo "Task: Analyze dependencies and changes."
} | codex exec --full-auto -
```

## 4. Working Directory

```bash
# Codex can read files in specified directory
codex exec -C /path/to/project "analyze the codebase" --full-auto

# Add additional directories
codex exec --add-dir /shared/libs "check dependencies" --full-auto
```

## 5. Image Context

```bash
# Single image
codex exec -i screenshot.png "describe this UI" --full-auto

# Multiple images
codex exec -i before.png -i after.png "compare these" --full-auto
```

## Important

- Options must come BEFORE `-` marker
- Use `--full-auto` for non-interactive execution
- Combine stdin and `-C` for maximum context

