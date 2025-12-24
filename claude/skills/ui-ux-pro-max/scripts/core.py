#!/usr/bin/env python3
"""
UI/UX Pro Max - BM25 Search Engine Core
Searchable database for UI styles, colors, fonts, charts, and best practices.
"""

import csv
import math
import os
import re
from collections import defaultdict
from pathlib import Path

# Configuration
DOMAIN_CONFIG = {
    "styles": {"file": "styles.csv", "search_cols": ["Style Category", "Type", "Keywords"], "output_cols": ["Style Category", "Type", "Keywords", "Primary Colors", "Secondary Colors", "Effects & Animation", "Best For", "Light Mode ✓", "Dark Mode ✓", "Framework Compatibility"]},
    "prompts": {"file": "prompts.csv", "search_cols": ["Style Category", "AI Prompt Keywords (Copy-Paste Ready)", "CSS/Technical Keywords"], "output_cols": ["Style Category", "AI Prompt Keywords (Copy-Paste Ready)", "CSS/Technical Keywords", "Implementation Checklist", "Design System Variables"]},
    "colors": {"file": "colors.csv", "search_cols": ["Product Type", "Keywords"], "output_cols": ["Product Type", "Primary (Hex)", "Secondary (Hex)", "CTA (Hex)", "Background (Hex)", "Text (Hex)", "Border (Hex)", "Notes"]},
    "charts": {"file": "charts.csv", "search_cols": ["Data Type", "Keywords"], "output_cols": ["Data Type", "Best Chart Type", "Secondary Options", "Color Guidance", "Library Recommendation", "Interactive Level"]},
    "landing": {"file": "landing.csv", "search_cols": ["Pattern Name", "Keywords"], "output_cols": ["Pattern Name", "Section Order", "Primary CTA Placement", "Color Strategy", "Recommended Effects", "Conversion Optimization"]},
    "products": {"file": "products.csv", "search_cols": ["Product Type", "Keywords"], "output_cols": ["Product Type", "Primary Style", "Secondary Style", "Landing Pattern", "Dashboard Style", "Color Palette", "Key Considerations"]},
    "ux": {"file": "ux-guidelines.csv", "search_cols": ["Category", "Issue", "Description"], "output_cols": ["Category", "Issue", "Platform", "Description", "Do", "Don't", "Code Example Good", "Code Example Bad", "Severity"]},
    "typography": {"file": "typography.csv", "search_cols": ["Font Pairing Name", "Category", "Mood/Style Keywords", "Best For"], "output_cols": ["Font Pairing Name", "Heading Font", "Body Font", "Mood/Style Keywords", "Best For", "CSS Import", "Tailwind Config"]},
}

STACK_CONFIG = {
    "html-tailwind": "html-tailwind.csv",
    "react": "react.csv",
    "nextjs": "nextjs.csv",
    "vue": "vue.csv",
    "svelte": "svelte.csv",
    "swiftui": "swiftui.csv",
    "react-native": "react-native.csv",
    "flutter": "flutter.csv",
}


class BM25:
    """BM25 ranking algorithm implementation."""

    def __init__(self, k1=1.5, b=0.75):
        self.k1 = k1
        self.b = b
        self.doc_lengths = []
        self.avg_doc_length = 0
        self.doc_freqs = defaultdict(int)
        self.idf = {}
        self.doc_vectors = []
        self.corpus_size = 0

    def _tokenize(self, text):
        """Tokenize text into lowercase words."""
        return re.findall(r"\w+", text.lower())

    def fit(self, corpus):
        """Build the BM25 index from corpus."""
        self.corpus_size = len(corpus)
        self.doc_vectors = []
        self.doc_lengths = []

        # First pass: build document frequencies
        for doc in corpus:
            tokens = self._tokenize(doc)
            self.doc_lengths.append(len(tokens))
            unique_tokens = set(tokens)
            for token in unique_tokens:
                self.doc_freqs[token] += 1

            # Store token frequencies for each document
            tf = defaultdict(int)
            for token in tokens:
                tf[token] += 1
            self.doc_vectors.append(dict(tf))

        self.avg_doc_length = sum(self.doc_lengths) / len(self.doc_lengths) if self.doc_lengths else 0

        # Calculate IDF
        for token, freq in self.doc_freqs.items():
            self.idf[token] = math.log((self.corpus_size - freq + 0.5) / (freq + 0.5) + 1)

    def score(self, query, doc_idx):
        """Calculate BM25 score for a query against a document."""
        query_tokens = self._tokenize(query)
        doc_vector = self.doc_vectors[doc_idx]
        doc_length = self.doc_lengths[doc_idx]

        score = 0
        for token in query_tokens:
            if token not in doc_vector:
                continue
            tf = doc_vector[token]
            idf = self.idf.get(token, 0)
            numerator = tf * (self.k1 + 1)
            denominator = tf + self.k1 * (1 - self.b + self.b * doc_length / self.avg_doc_length)
            score += idf * numerator / denominator

        return score

    def search(self, query, top_k=3):
        """Search and return top-k document indices with scores."""
        scores = [(i, self.score(query, i)) for i in range(self.corpus_size)]
        scores = [(i, s) for i, s in scores if s > 0]
        scores.sort(key=lambda x: x[1], reverse=True)
        return scores[:top_k]


def get_data_dir():
    """Get the data directory path."""
    script_dir = Path(__file__).parent
    return script_dir.parent / "data"


def _search_csv(query, csv_file, search_cols, output_cols, max_results=3):
    """Search a CSV file using BM25."""
    data_dir = get_data_dir()
    file_path = data_dir / csv_file

    if not file_path.exists():
        return []

    rows = []
    corpus = []

    with open(file_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            rows.append(row)
            # Combine search columns for indexing
            search_text = " ".join(str(row.get(col, "")) for col in search_cols)
            corpus.append(search_text)

    if not corpus:
        return []

    bm25 = BM25()
    bm25.fit(corpus)
    results = bm25.search(query, top_k=max_results)

    output = []
    for idx, score in results:
        row = rows[idx]
        output_row = {col: row.get(col, "") for col in output_cols if col in row}
        output.append(output_row)

    return output


def detect_domain(query):
    """Detect the most likely domain based on query keywords."""
    query_lower = query.lower()

    domain_keywords = {
        "styles": ["glassmorphism", "neumorphism", "brutalism", "minimal", "dark mode", "style", "aesthetic", "ui style"],
        "colors": ["color", "palette", "hex", "primary", "secondary", "theme"],
        "typography": ["font", "typography", "typeface", "heading", "body text", "pairing"],
        "charts": ["chart", "graph", "visualization", "data", "dashboard", "analytics"],
        "landing": ["landing", "page", "hero", "cta", "conversion", "section"],
        "products": ["saas", "ecommerce", "portfolio", "healthcare", "fintech", "product type"],
        "ux": ["ux", "accessibility", "a11y", "animation", "loading", "error", "best practice"],
        "prompts": ["prompt", "ai", "css", "implementation"],
    }

    scores = {}
    for domain, keywords in domain_keywords.items():
        score = sum(1 for kw in keywords if kw in query_lower)
        if score > 0:
            scores[domain] = score

    if scores:
        return max(scores, key=scores.get)
    return "styles"  # Default


def search(query, domain=None, max_results=3):
    """
    Search the UI/UX database.

    Args:
        query: Search query string
        domain: Optional domain to search (auto-detected if not provided)
        max_results: Maximum number of results to return

    Returns:
        List of matching records
    """
    if domain is None:
        domain = detect_domain(query)

    if domain not in DOMAIN_CONFIG:
        return {"error": f"Unknown domain: {domain}. Available: {list(DOMAIN_CONFIG.keys())}"}

    config = DOMAIN_CONFIG[domain]
    results = _search_csv(query, config["file"], config["search_cols"], config["output_cols"], max_results)

    return {"domain": domain, "query": query, "results": results, "count": len(results)}


def search_stack(query, stack="html-tailwind", max_results=3):
    """
    Search stack-specific guidelines.

    Args:
        query: Search query string
        stack: Technology stack (html-tailwind, react, nextjs, vue, svelte, swiftui, react-native, flutter)
        max_results: Maximum number of results to return

    Returns:
        List of matching guidelines
    """
    if stack not in STACK_CONFIG:
        return {"error": f"Unknown stack: {stack}. Available: {list(STACK_CONFIG.keys())}"}

    csv_file = f"stacks/{STACK_CONFIG[stack]}"
    search_cols = ["Category", "Guideline", "Description"]
    output_cols = ["Category", "Guideline", "Description", "Do", "Don't", "Code Good", "Code Bad", "Severity"]

    results = _search_csv(query, csv_file, search_cols, output_cols, max_results)

    return {"stack": stack, "query": query, "results": results, "count": len(results)}


if __name__ == "__main__":
    # Test search
    print("Testing search functionality...")
    result = search("glassmorphism modern", domain="styles", max_results=2)
    print(f"Domain search: {result}")

    result = search_stack("animation performance", stack="react", max_results=2)
    print(f"Stack search: {result}")
