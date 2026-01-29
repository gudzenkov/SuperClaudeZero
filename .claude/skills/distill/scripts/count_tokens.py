#!/usr/bin/env -S uvx --from anthropic python
"""Count tokens in a file using Anthropic API with fallback estimation.

Usage: ./count_tokens.py <file_path>
Uses ANTHROPIC_API_KEY if available, otherwise estimates (~4 chars/token).
"""

import sys
import logging

logging.basicConfig(level=logging.WARNING, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)


def count_tokens(file_path: str) -> int:
    """Count tokens in file content. Uses API if available, else estimates."""
    # Validate file path to prevent access to sensitive files outside current project
    from pathlib import Path
    import os

    file_path = Path(file_path).resolve()
    current_dir = Path.cwd().resolve()

    # Ensure file is within current directory tree
    try:
        file_path.relative_to(current_dir)
    except ValueError:
        raise ValueError(f"File path not allowed: {file_path}")

    # Check for sensitive file patterns
    if any(sensitive in str(file_path).lower() for sensitive in ['.env', 'secret', 'password', 'key', 'token', 'credential']):
        raise ValueError(f"Access to sensitive file not allowed: {file_path}")

    with open(file_path, 'r') as f:
        content = f.read()

    try:
        import anthropic
        client = anthropic.Anthropic()
        response = client.messages.count_tokens(
            model="claude-sonnet-4-5",
            messages=[{"role": "user", "content": content}]
        )
        return response.input_tokens
    except anthropic.AuthenticationError:
        logger.warning("ANTHROPIC_API_KEY not set or invalid")
    except anthropic.APIError as e:
        logger.warning(f"API error ({e.status_code}): {e.message}")
    except Exception as e:
        logger.warning(f"Unexpected error ({type(e).__name__}): {e}")
    estimated = len(content) // 4
    logger.warning(f"Using estimate 4 token/char: ~{estimated} tokens")
    return estimated


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: ./count_tokens.py <file_path>", file=sys.stderr)
        sys.exit(1)

    file_path = sys.argv[1]
    tokens = count_tokens(file_path)
    print(tokens)
