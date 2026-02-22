"""
Generate a wellness report from user inputs using the NVIDIA API.
Medical/wellness guardrails: only answers related to health and wellness.
"""
import json
from typing import Optional

from openai import OpenAI

from config import NVIDIA_BASE_URL, NVIDIA_API_KEY, NVIDIA_MODEL, nvidia_configured

# System prompt: restrict to medical and wellness context only. Output plain text only (no markdown).
SYSTEM_PROMPT = """You are a wellness assistant for Masika, a menstrual and reproductive health app.
Your role is to provide clear, supportive, and medically-grounded wellness information only.
- Base your response strictly on the user's provided health inputs and any lab/cycle data they share.
- Use plain language. Do not diagnose diseases or replace a doctor.
- Recommend consulting a healthcare provider when appropriate.
- Keep the tone professional, empathetic, and non-judgmental.
- Structure your response as a short wellness report: a brief summary, key observations, and simple next steps or suggestions.
- Do not answer questions unrelated to health, wellness, or the data provided.

Formatting rules (important): Write in PLAIN TEXT ONLY. Do not use any markdown or symbols:
- No asterisks (** or *) for bold. Write section headings as a short line on their own (e.g. "Summary" then a blank line then the summary text).
- No hash symbols (#) for headings.
- No hyphens (-) or asterisks (*) as bullet points. Use simple numbered lines (1. 2. 3.) or short paragraphs instead.
- No underscores for emphasis. Just use normal sentences.
Output only clean, readable text with section headings on their own line and normal paragraphs below."""


def _build_user_message(input_data: dict, prediction: str) -> str:
    """Turn form data and prediction into a single prompt for the model."""
    lines = [
        "Based on the following user inputs and screening result, write a short wellness report.",
        "",
        "Screening result: " + prediction,
        "",
        "User inputs:",
    ]
    for key, value in input_data.items():
        if value is not None and str(value).strip():
            lines.append(f"- {key}: {value}")
    lines.append("")
    lines.append(
        "Provide a concise wellness-oriented report in PLAIN TEXT ONLY: no markdown, no ** for bold, "
        "no # or - or * for lists. Use short section headings on their own line (e.g. Summary, Key observations, "
        "Next steps) followed by normal sentences. No asterisks or bullet symbols."
    )
    return "\n".join(lines)


def generate_report(input_data: dict, prediction: str) -> Optional[str]:
    """
    Call NVIDIA API to generate a wellness report from input_data and prediction.
    Returns report text or None if API is not configured or request fails.
    """
    if not nvidia_configured():
        return None

    client = OpenAI(base_url=NVIDIA_BASE_URL, api_key=NVIDIA_API_KEY)
    user_content = _build_user_message(input_data, prediction)

    try:
        completion = client.chat.completions.create(
            model=NVIDIA_MODEL,
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": user_content},
            ],
            temperature=0.5,
            top_p=0.9,
            max_tokens=2048,
            stream=False,
        )
        if completion.choices and len(completion.choices) > 0:
            content = completion.choices[0].message.content
            return (content or "").strip() or None
    except Exception:
        return None
    return None
