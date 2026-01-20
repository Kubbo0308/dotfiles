#!/usr/bin/env python3
"""
UI Pro Max Search - CLI Tool
BM25-based search engine for UI/UX style guides.

Usage:
    python search.py "<query>" [options]

Examples:
    python search.py "glassmorphism" --domain style
    python search.py "animation" --stack react
    python search.py "saas dashboard" --domain product -n 5
"""

import argparse
import json
import sys
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent))

from core import search, search_stack, DOMAIN_CONFIG, STACK_CONFIG


def format_output(result, is_stack=False):
    """Format search results for Claude-friendly output."""
    output_lines = []

    if "error" in result:
        return f"Error: {result['error']}"

    if is_stack:
        output_lines.append(f"## Stack: {result['stack']}")
    else:
        output_lines.append(f"## Domain: {result['domain']}")

    output_lines.append(f"Query: {result['query']}")
    output_lines.append(f"Results: {result['count']}")
    output_lines.append("")

    for i, item in enumerate(result["results"], 1):
        output_lines.append(f"### Result {i}")
        for key, value in item.items():
            if value:
                # Truncate long values
                value_str = str(value)
                if len(value_str) > 300:
                    value_str = value_str[:300] + "..."
                output_lines.append(f"- **{key}**: {value_str}")
        output_lines.append("")

    return "\n".join(output_lines)


def main():
    parser = argparse.ArgumentParser(
        description="UI Pro Max Search - BM25 search for UI/UX guides",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Domains: style, prompt, color, chart, landing, product, ux, typography
Stacks: html-tailwind, react, nextjs, vue, svelte, swiftui, react-native, flutter

Examples:
  python search.py "glassmorphism" --domain style
  python search.py "animation" --stack react
  python search.py "saas" --domain product -n 5
        """,
    )

    parser.add_argument("query", help="Search query")
    parser.add_argument(
        "--domain",
        "-d",
        choices=list(DOMAIN_CONFIG.keys()),
        help="Domain to search (auto-detected if not specified)",
    )
    parser.add_argument(
        "--stack",
        "-s",
        choices=list(STACK_CONFIG.keys()),
        help="Stack-specific guidelines (takes priority over domain)",
    )
    parser.add_argument(
        "-n",
        "--max-results",
        type=int,
        default=3,
        help="Maximum results to return (default: 3)",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output as JSON instead of formatted markdown",
    )

    args = parser.parse_args()

    # Stack search takes priority
    if args.stack:
        result = search_stack(args.query, args.stack, args.max_results)
        is_stack = True
    else:
        result = search(args.query, args.domain, args.max_results)
        is_stack = False

    if args.json:
        print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        print(format_output(result, is_stack))


if __name__ == "__main__":
    main()
