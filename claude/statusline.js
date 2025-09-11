#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const readline = require('readline');

// Constants
const COMPACTION_THRESHOLD = 200000 * 0.8

// Read JSON from stdin
let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', async () => {
  try {
    // Handle empty input
    if (!input.trim()) {
      console.log(`📁 ${path.basename(process.cwd())} | ⚠️  No input data`);
      return;
    }

    const data = JSON.parse(input);

    // Extract values with better fallbacks
    const model = data.model?.display_name || data.model?.id || 'Unknown';
    const currentDir = path.basename(data.workspace?.current_dir || data.cwd || process.cwd());
    const sessionId = data.session_id;

    // Calculate token usage for current session
    let totalTokens = 0;

    if (sessionId) {
      // Find all transcript files
      const projectsDir = path.join(process.env.HOME, '.claude', 'projects');

      if (fs.existsSync(projectsDir)) {
        // Get all project directories
        const projectDirs = fs.readdirSync(projectsDir)
          .map(dir => path.join(projectsDir, dir))
          .filter(dir => fs.statSync(dir).isDirectory());

        // Search for the current session's transcript file
        for (const projectDir of projectDirs) {
          const transcriptFile = path.join(projectDir, `${sessionId}.jsonl`);

          if (fs.existsSync(transcriptFile)) {
            totalTokens = await calculateTokensFromTranscript(transcriptFile);
            break;
          }
        }
      }
    }

    // Format token count with K suffix
    const tokenDisplay = totalTokens > 0 ? formatTokens(totalTokens) : '0';

    // Calculate percentage of tokens used against compaction threshold
    const percentage = Math.min(100, Math.round((totalTokens / COMPACTION_THRESHOLD) * 100));
    
    // Color coding for percentage
    let percentageDisplay;
    if (percentage < 70) {
      percentageDisplay = `\x1b[32m${percentage}%\x1b[0m`; // Green
    } else if (percentage < 90) {
      percentageDisplay = `\x1b[33m${percentage}%\x1b[0m`; // Yellow
    } else {
      percentageDisplay = `\x1b[31m${percentage}%\x1b[0m`; // Red
    }

    // Create status line
    const statusLine = `📁 ${currentDir} | 🤖 ${model} | 🎫 ${tokenDisplay} (${percentageDisplay})`;

    console.log(statusLine);
  } catch (error) {
    // More helpful error message that includes current directory
    const fallbackDir = path.basename(process.cwd());
    console.log(`📁 ${fallbackDir} | ⚠️  Error: ${error.message}`);
  }
});

async function calculateTokensFromTranscript(transcriptFile) {
  try {
    const fileStream = fs.createReadStream(transcriptFile);
    const rl = readline.createInterface({
      input: fileStream,
      crlfDelay: Infinity
    });

    let totalTokens = 0;

    for await (const line of rl) {
      try {
        const entry = JSON.parse(line);
        
        // Check for usage in both top level and message level
        const usage = entry.usage || entry.message?.usage;
        
        if (usage) {
          // Add all input token types
          if (usage.input_tokens) {
            totalTokens += usage.input_tokens;
          }
          if (usage.cache_creation_input_tokens) {
            totalTokens += usage.cache_creation_input_tokens;
          }
          if (usage.cache_read_input_tokens) {
            totalTokens += usage.cache_read_input_tokens;
          }
          // Add output tokens
          if (usage.output_tokens) {
            totalTokens += usage.output_tokens;
          }
        }
      } catch (parseError) {
        // Skip invalid JSON lines
        continue;
      }
    }

    return totalTokens;
  } catch (error) {
    return 0;
  }
}

function formatTokens(tokens) {
  if (tokens >= 1000) {
    return `${(tokens / 1000).toFixed(1)}K`;
  }
  return tokens.toString();
}