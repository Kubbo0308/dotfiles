# Fix website UI issues: /fix-ui $URL

## Goal

Analyze and fix UI issues on a website by examining the live page and making necessary corrections.

## Command Usage

```
/fix-ui https://example.com
```

## Steps

Target URL: $URL

1. **Navigate and Capture**: Use Playwright MCP to navigate to the provided URL and take a screenshot to understand the current UI state.

2. **Analyze the Page**: 
   - Extract the HTML structure using Playwright
   - Identify CSS styles and layout issues
   - Capture any JavaScript errors in the console
   - Take note of responsive design problems

3. **Identify UI Issues**:
   - Look for layout problems (misaligned elements, overflow issues)
   - Check for styling inconsistencies
   - Identify accessibility issues
   - Note any broken functionality or visual bugs

4. **Read User Feedback**: Parse any additional context provided after the URL to understand specific issues the user wants addressed.

5. **Generate Fixes**:
   - Create CSS fixes for styling issues
   - Provide HTML structure improvements if needed
   - Suggest JavaScript fixes for interactive elements
   - Recommend accessibility improvements

6. **Validate Solutions**:
   - Use Playwright to test the proposed fixes
   - Take before/after screenshots to show improvements
   - Ensure fixes don't break existing functionality

7. **Output Results**:
   - Provide a summary of identified issues
   - Present the fix code with clear explanations
   - Include visual comparisons when possible
   - Suggest implementation steps for the user

## MCP Tools Used

- **Playwright MCP**: For web navigation, screenshot capture, HTML extraction, and testing fixes. These MCP operations should be performed with multiple sub-agents for comprehensive analysis.
- **Web Search**: For researching best practices and modern UI solutions if needed

## Sub-Agent Strategy

When using MCP tools, distribute the work across multiple sub-agents:
- **Navigation Sub-Agent**: Handle initial site navigation and screenshot capture
- **Analysis Sub-Agent**: Extract HTML/CSS and identify structural issues  
- **Testing Sub-Agent**: Validate fixes and perform before/after comparisons
- **Research Sub-Agent**: Use web search for UI best practices and solutions
