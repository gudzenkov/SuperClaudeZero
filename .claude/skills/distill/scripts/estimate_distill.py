#!/usr/bin/env -S uvx --from claude-agent-sdk python
"""Estimate distillation metrics using Claude Agent SDK.

Usage: ./estimate_distill.py <file_path> [content_type]
Uses Claude Code subscription auth (no ANTHROPIC_API_KEY needed).
Uses ClaudeSDKClient with dual query for accurate token measurement.
Claude determines context-specific reductions from heuristics.

Returns JSON:
{
  "tokens_before": 2000,
  "levels": [
    {"level": 1, "name": "essence", "tokens_after": 200, "reduction": 90, "critical_loss": 40},
    ...
  ]
}
"""

import sys
import json
import logging
import asyncio
from pathlib import Path

logging.basicConfig(level=logging.WARNING, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions, AssistantMessage, ResultMessage, TextBlock


SYSTEM_PROMPT = """You are a content analysis expert specializing in information density and distillation.
Analyze content and provide distillation metrics as JSON only. No explanations."""

ANALYSIS_PROMPT = """Analyze this {content_type} content for distillation.

Criticality heuristics for {content_type} (ordered by importance):
{heuristics}

For each distillation level, determine:
1. Appropriate reduction percentage based on heuristics (not fixed values!)
2. Critical information loss percentage

Levels:
- essence: Keep identity only (highest reduction)
- summary: + behavior
- condensed: + reasoning
- detailed: + context
- minimal: Dedup/formatting only (lowest reduction)

IMPORTANT: Reduction percentages should vary based on content structure and heuristics.
For example, code with many comments might have higher minimal reduction than dense code.

Return ONLY valid JSON:
{{
  "levels": [
    {{"level": 1, "name": "essence", "reduction": <int>, "critical_loss": <int>}},
    {{"level": 2, "name": "summary", "reduction": <int>, "critical_loss": <int>}},
    {{"level": 3, "name": "condensed", "reduction": <int>, "critical_loss": <int>}},
    {{"level": 4, "name": "detailed", "reduction": <int>, "critical_loss": <int>}},
    {{"level": 5, "name": "minimal", "reduction": <int>, "critical_loss": <int>}}
  ]
}}

Content:
{content}
"""

HEURISTICS = {
    "policy": "Rules > Priority > Rationale > Examples > Detection",
    "code": "Signatures > Logic > Types > Comments > Formatting",
    "memory": "Facts > Decisions > Reasoning > Timestamps > Verbose",
    "artifacts": "Requirements > Criteria > Rationale > Background > Examples",
    "default": "Critical > Important > Helpful > Context > Lossy"
}


def detect_content_type(file_path: str) -> str:
    """Detect content type from file path."""
    path = Path(file_path).name.lower()

    if any(x in path for x in ['rules', 'principles', 'guidelines', 'policy']):
        return "policy"
    if any(x in path for x in ['prd', 'architecture', 'adr', 'roadmap', 'backlog']):
        return "artifacts"
    if path.endswith(('.py', '.js', '.ts', '.go', '.rs', '.java', '.c', '.cpp', '.h')):
        return "code"
    if 'memory' in path or path.endswith('.jsonl'):
        return "memory"
    return "default"


def get_input_tokens(usage) -> int:
    """Extract input tokens from usage object/dict."""
    if hasattr(usage, 'input_tokens'):
        return (
            getattr(usage, 'input_tokens', 0) +
            getattr(usage, 'cache_creation_input_tokens', 0) +
            getattr(usage, 'cache_read_input_tokens', 0)
        )
    elif isinstance(usage, dict):
        return (
            usage.get('input_tokens', 0) +
            usage.get('cache_creation_input_tokens', 0) +
            usage.get('cache_read_input_tokens', 0)
        )
    return 0


async def estimate_distill(file_path: str, content_type: str | None = None) -> dict:
    """Estimate distillation metrics using ClaudeSDKClient with dual query."""
    with open(file_path, 'r') as f:
        content = f.read()

    if content_type is None:
        content_type = detect_content_type(file_path)

    heuristics = HEURISTICS.get(content_type, HEURISTICS["default"])

    options = ClaudeAgentOptions(
        system_prompt=SYSTEM_PROMPT,
        max_turns=1,
        tools=None,
        allowed_tools=[]
    )

    baseline_tokens = 0
    total_tokens = 0
    result_text = ""

    async with ClaudeSDKClient(options=options) as client:
        # Query 1: Baseline (system + heuristics, no content)
        baseline_prompt = ANALYSIS_PROMPT.format(
            content_type=content_type,
            heuristics=heuristics,
            content=""
        )
        await client.query(baseline_prompt)

        async for message in client.receive_response():
            if isinstance(message, ResultMessage):
                if hasattr(message, 'usage') and message.usage:
                    baseline_tokens = get_input_tokens(message.usage)

        # Query 2: Full analysis with content
        analysis_prompt = ANALYSIS_PROMPT.format(
            content_type=content_type,
            heuristics=heuristics,
            content=f"```{content}```"
        )
        await client.query(analysis_prompt)

        async for message in client.receive_response():
            if isinstance(message, AssistantMessage):
                for block in message.content:
                    if isinstance(block, TextBlock):
                        result_text += block.text
            elif isinstance(message, ResultMessage):
                if hasattr(message, 'usage') and message.usage:
                    total_tokens = get_input_tokens(message.usage)

    # Content tokens = total - baseline
    content_tokens = max(total_tokens - baseline_tokens, 100)

    # Parse quality/reduction estimates from Claude
    levels = []
    try:
        if "```" in result_text:
            result_text = result_text.split("```")[1]
            if result_text.startswith("json"):
                result_text = result_text[4:]
        parsed = json.loads(result_text.strip())

        for level_data in parsed.get("levels", []):
            reduction = level_data.get("reduction", 50)
            levels.append({
                "level": level_data.get("level"),
                "name": level_data.get("name"),
                "tokens_after": int(content_tokens * (100 - reduction) / 100),
                "reduction": reduction,
                "critical_loss": level_data.get("critical_loss", 0)
            })
    except json.JSONDecodeError as e:
        logger.warning(f"Failed to parse estimates: {e}")
        # Fallback with default estimates
        defaults = [
            ("essence", 90, 45), ("summary", 75, 25), ("condensed", 50, 12),
            ("detailed", 25, 5), ("minimal", 10, 2)
        ]
        for i, (name, reduction, loss) in enumerate(defaults):
            levels.append({
                "level": i + 1,
                "name": name,
                "tokens_after": int(content_tokens * (100 - reduction) / 100),
                "reduction": reduction,
                "critical_loss": loss
            })

    return {
        "tokens_before": content_tokens,
        "_baseline_tokens": baseline_tokens,
        "_total_tokens": total_tokens,
        "content_type": content_type,
        "levels": levels
    }


async def main():
    if len(sys.argv) < 2:
        print("Usage: ./estimate_distill.py <file_path> [content_type]", file=sys.stderr)
        sys.exit(1)

    file_path = sys.argv[1]
    content_type = sys.argv[2] if len(sys.argv) > 2 else None

    if not Path(file_path).exists():
        logger.error(f"File not found: {file_path}")
        sys.exit(1)

    try:
        result = await estimate_distill(file_path, content_type)
        print(json.dumps(result, indent=2))
    except Exception as e:
        logger.error(f"Estimation failed ({type(e).__name__}): {e}")
        sys.exit(1)


if __name__ == "__main__":
    asyncio.run(main())
