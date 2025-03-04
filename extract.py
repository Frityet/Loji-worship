#!/usr/bin/env python3
import sys
import re
from bs4 import BeautifulSoup

def extract_reasoning(html):
    """
    Extracts paragraphs from the HTML that seem to be actual reasoning bits.
    In this example, we filter out paragraphs that start with or contain
    phrases like "Searched for" (which are assumed to be query logs) and only
    return those that are more like internal thought or code reasoning.
    """
    soup = BeautifulSoup(html, 'html.parser')
    reasoning_bits = []

    # Find all paragraph tags
    for p in soup.find_all('p'):
        text = p.get_text(strip=True)
        # Skip empty paragraphs
        if not text:
            continue
        # Filter out lines that appear to be search queries or metadata
        # (Adjust the regex as needed for your particular HTML)
        if re.search(r"(?i)^(Searched for|Search for)", text):
            continue
        reasoning_bits.append(text)
    return reasoning_bits

def main():
    if len(sys.argv) != 2:
        print("Usage: python extract_reasoning.py <html_file>")
        sys.exit(1)
    
    html_file = sys.argv[1]
    try:
        with open(html_file, 'r', encoding='utf-8') as f:
            html = f.read()
    except Exception as e:
        print(f"Error reading file: {e}")
        sys.exit(1)

    reasoning = extract_reasoning(html)
    
    # Print each reasoning bit (you can also write these to a file)
    for line in reasoning:
        print(line)
        print("-" * 80)  # separator for clarity

if __name__ == "__main__":
    main()
