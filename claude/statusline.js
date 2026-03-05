#!/usr/bin/env node

const path = require('path');
const { execSync } = require('child_process');

// Auto-compact threshold percentage (env var override or default 80%)
const COMPACT_PCT = parseInt(process.env.CLAUDE_AUTOCOMPACT_PCT_OVERRIDE || '80');
const COMPACT_MARKER_AT = Math.max(10, Math.min(90, Math.floor(COMPACT_PCT / 10) * 10));

// Bar config: 10 segments x 2 chars = 20 fill chars + 9 separators + 2 brackets
const SEGMENT_WIDTH = 2;
const NUM_SEGMENTS = 10;

// ANSI colors
const C = {
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
  cyan: '\x1b[36m',
  dim: '\x1b[2m',
  bold: '\x1b[1m',
  reset: '\x1b[0m',
};

let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  try {
    if (!input.trim()) {
      console.log(`📁 ${path.basename(process.cwd())} | ⚠️  No input data`);
      return;
    }

    const data = JSON.parse(input);

    const model = data.model?.display_name || data.model?.id || 'Unknown';
    const workingDir = data.workspace?.current_dir || data.cwd || process.cwd();
    const currentDir = path.basename(workingDir);
    const branch = getGitBranch(workingDir);

    // Context window data from Claude Code
    const ctx = data.context_window || {};
    const usedPct = ctx.used_percentage || 0;
    const windowSize = ctx.context_window_size || 200000;
    const currentTokens = Math.round(usedPct / 100 * windowSize);

    const bar = renderUsageBar(usedPct);
    const pctDisplay = colorize(Math.round(usedPct) + '%', usedPct);
    const tokenDisplay = formatTokens(currentTokens);
    const branchPart = branch ? ` | 🌿 ${branch}` : '';

    const windowDisplay = formatTokens(windowSize);
    console.log(`📁 ${currentDir}${branchPart} | 🤖 ${model} | ${bar} ${pctDisplay} ${tokenDisplay}/${windowDisplay}`);
  } catch (error) {
    console.log(`📁 ${path.basename(process.cwd())} | ⚠️  ${error.message}`);
  }
});

function renderUsageBar(usedPct) {
  const pct = Math.min(100, Math.max(0, usedPct));
  const fillColor = pct < 50 ? C.green : pct < COMPACT_PCT ? C.yellow : C.red;

  let bar = C.dim + '[' + C.reset;

  for (let seg = 0; seg < NUM_SEGMENTS; seg++) {
    const segStartPct = seg * 10;

    // Fill characters for this segment
    for (let c = 0; c < SEGMENT_WIDTH; c++) {
      const charPct = segStartPct + (c + 0.5) * (10 / SEGMENT_WIDTH);
      bar += charPct <= pct
        ? fillColor + '█' + C.reset
        : C.dim + '░' + C.reset;
    }

    // Separator after segment (not after last)
    if (seg < NUM_SEGMENTS - 1) {
      const boundaryPct = (seg + 1) * 10;
      bar += boundaryPct === COMPACT_MARKER_AT
        ? C.cyan + C.bold + '┃' + C.reset
        : C.dim + '│' + C.reset;
    }
  }

  bar += C.dim + ']' + C.reset;
  return bar;
}

function colorize(text, pct) {
  const color = pct < 50 ? C.green : pct < COMPACT_PCT ? C.yellow : C.red;
  return color + text + C.reset;
}

function formatTokens(tokens) {
  if (tokens >= 1000000) return `${(tokens / 1000000).toFixed(1)}M`;
  if (tokens >= 1000) return `${(tokens / 1000).toFixed(1)}K`;
  return tokens.toString();
}

function getGitBranch(cwd) {
  try {
    return execSync('git branch --show-current', {
      cwd, encoding: 'utf8', stdio: ['pipe', 'pipe', 'pipe']
    }).trim() || null;
  } catch { return null; }
}
