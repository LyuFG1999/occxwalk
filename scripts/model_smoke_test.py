"""Optional OpenAI Responses API connectivity test for occxwalk developers.

The released Stata package never imports or calls this module.
"""

from __future__ import annotations

import os

from openai import OpenAI


def main() -> None:
    model = os.getenv("OPENAI_MODEL", "gpt-5.6")
    client = OpenAI()
    response = client.responses.create(
        model=model,
        input=(
            "Reply with exactly OCCXWALK_MODEL_OK. "
            "This is a connectivity test; do not add other text."
        ),
    )
    print(f"model={model}")
    print(response.output_text)


if __name__ == "__main__":
    main()

