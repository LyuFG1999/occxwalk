# Developer guide: Python and model configuration

## Two separate workflows

### Use the released Stata package

Python, an API key, and a model are not required. `occxwalk.ado` reads only the packaged `occxwalk_catalog.dta` and `occxwalk_links.dta` files.

### Rebuild or regenerate mappings

- Rebuilding `.dta` assets from the eleven **already matched** GPT56 Excel workbooks requires Python only.
- Regenerating occupation matches from raw occupation lists requires Python, the OpenAI SDK, an API key, and a model. This repository provides a connectivity check and configuration convention, but it does not include the original mapping prompt or a batch model-generation pipeline.

## Configure the Python build environment

Python 3.10 or newer is recommended.

Windows PowerShell:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r requirements-build.txt
```

macOS/Linux:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements-build.txt
```

Place the eleven files named `职业体系匹配_主体系_<system>_GPT56.xlsx` in one input directory, one workbook for every supported system. Then run:

```powershell
python scripts/build_occxwalk_data.py `
  --input-dir "D:\path\to\ChatGPT" `
  --output-dir "."
```

The builder validates required systems and columns, normalizes numeric-system keys, applies deterministic source-row duplicate handling, writes the two `.dta` assets and manifest, and checks key uniqueness, confidence bounds, and complete ten-target coverage.

## Configure the OpenAI API and model (optional developer workflow)

Install the official Python SDK:

```powershell
python -m pip install -r requirements-model.txt
```

Set environment variables for the current PowerShell session:

```powershell
$env:OPENAI_API_KEY = "your API key"
$env:OPENAI_MODEL = "gpt-5.6"
```

macOS/Linux:

```bash
export OPENAI_API_KEY="your_api_key"
export OPENAI_MODEL="gpt-5.6"
```

Never commit a real API key to `.env.example`, source code, or Git. The official OpenAI SDK automatically reads `OPENAI_API_KEY`. This repository's optional smoke test passes `OPENAI_MODEL` as the Responses API model and defaults to `gpt-5.6` when it is unset.

Run the connectivity check (this makes a small billable API request):

```powershell
python scripts/model_smoke_test.py
```

Official OpenAI references:

- [Developer quickstart](https://developers.openai.com/api/docs/quickstart)
- [Models](https://developers.openai.com/api/docs/models)
- [Model guidance](https://developers.openai.com/api/docs/guides/latest-model)

## Stata regression test

From the repository root, run:

```stata
do tests/test_occxwalk.do .
```

The test covers numeric value labels, names, long descriptions, ISCO08 leading zeros, ONET/SOC string restrictions, crosswalk output, and the CFPS ambiguity warning.

