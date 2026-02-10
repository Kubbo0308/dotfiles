# X (Twitter) Verification Process

## Why Verification is Critical

X content can be:
- Outdated or superseded
- Incorrect or misunderstood
- Taken out of context
- From unreliable sources

## Verification Steps

### 1. Account Credibility Check
- Is it an official account? (verified badge, official website link)
- Is the person a known expert in this field?
- Check follower count and engagement quality
- Look at account history and reputation

### 2. Cross-Reference with Official Sources
```bash
# After finding X info, verify with:
WebSearch: "{topic} official documentation"
WebSearch: "{topic} {company} blog"
```

### 3. Date Verification
- When was the post made?
- Is the information still current?
- Has there been a newer announcement?

### 4. Community Feedback
- Read replies for corrections
- Check quote tweets for context
- Look for follow-up posts from the author

### 5. Multiple Source Confirmation
- Find at least 2 independent sources
- Prefer official documentation over social media
- Check GitHub issues/discussions for technical claims

## Red Flags 🚩

- No official source confirmation
- Single source only
- Old post (>6 months for tech topics)
- Corrections in replies
- Anonymous or low-credibility account
- Sensational language

## Verification Decision Tree

```
Is the account official/verified?
├── Yes → Still verify with docs
└── No → Is the person a known expert?
    ├── Yes → Cross-reference required
    └── No → Do NOT trust without multiple confirmations
```

## Example Workflow

```bash
# 1. Find X post about React 19 feature
WebSearch: "site:x.com react 19 new feature"

# 2. Verify with official React docs
WebSearch: "react 19 official documentation"

# 3. Check React team blog
WebSearch: "site:react.dev blog react 19"

# 4. Confirm or reject the X claim
```

