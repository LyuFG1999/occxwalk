# occxwalk English documentation

`occxwalk` is a Stata package that converts eleven finalized GPT56 occupation-system workbooks into an offline lookup tool. It can:

1. Attach Stata value labels to numeric occupation-code variables.
2. Generate an occupation name or full description from a numeric or string code.
3. Crosswalk a source code to another coding system and create the target code, target name, and confidence score in one call.

Normal use is fully offline. The command does not access the source Excel files, Python, the OpenAI API, or an online model at runtime.

## Supported systems

| Canonical name | Common aliases | Source variable type |
|---|---|---|
| CFPS | `cfps` | numeric or string |
| CGSS06 | `cgss06`, `cgss2006`, `cgss` | numeric or string |
| CSS | `css` | numeric or string |
| GB2015_full | `gb2015`, `gb15`, `gb15f` | numeric or string |
| GB2015_reduce | `gb15r`, `gb2015r` | numeric or string |
| GB9909 | `gb99`, `gb09` | numeric or string |
| ISCO08 | `isco08`, `isco2008` | numeric or string |
| ISCO68 | `isco68`, `isco1968` | numeric or string |
| ISCO88 | `isco88`, `isco1988` | numeric or string |
| ONET_SOC2019_full | `onet`, `onet2019` | string only |
| SOC2010 | `soc10`, `soc` | string only |

System names and aliases are case-insensitive.

## Install from Stata

### GitHub `net install` (recommended)

```stata
net install occxwalk, ///
    from("https://raw.githubusercontent.com/LyuFG1999/occxwalk/main") ///
    replace
```

Verify the installation:

```stata
which occxwalk
help occxwalk
occxwalk systems
```

Run the same command with `replace` to upgrade to the current repository version.

### Local installation

After downloading or cloning the repository, add it to the current Stata session:

```stata
adopath ++ "D:/path/to/occxwalk"
```

For a permanent manual installation, copy these four core files into Stata's PERSONAL or PLUS directory:

- `occxwalk.ado`
- `occxwalk.sthlp`
- `occxwalk_catalog.dta`
- `occxwalk_links.dta`

Run `sysdir` to inspect Stata's directories. Do not copy only the `.ado`; the two `.dta` files are required offline data assets.

## Usage

### 1. Attach value labels

```stata
occxwalk label occupation, from(CFPS)
```

`label` accepts only a numeric source variable. It is unavailable for ONET_SOC2019_full and SOC2010 because those systems use punctuation-bearing string codes.

To set the value-label name or replace an existing definition:

```stata
occxwalk label occupation, from(gb15) labelname(gb15_occ) replace
```

### 2. Generate occupation text

```stata
occxwalk text occupation, from(CFPS) generate(occupation_name) field(name)
occxwalk text occupation, from(CFPS) generate(occupation_description) field(description)
```

For the nine digit-only systems, the source variable may be numeric or string. Leading zeros are normalized: numeric ISCO08 value `110` and string value `"0110"` both resolve to canonical code `0110`.

### 3. Crosswalk to another system

```stata
occxwalk match occupation, from(CFPS) to(ISCO08) prefix(isco)
```

This creates:

- `isco_code`: string target occupation code;
- `isco_name`: string target occupation name;
- `isco_confidence`: numeric GPT56 confidence.

String-code example:

```stata
occxwalk match onet_code, from(ONET) to(SOC10) prefix(soc)
```

## Returned results

Data-changing subcommands return:

- `r(matched)`: matched nonmissing observations;
- `r(unmatched)`: unmatched nonmissing observations;
- `r(ambiguous)`: observations that use a conflicting duplicate source code;
- `r(invalid)`: nondigit strings supplied for a digit-only system.

## Python and model configuration

Python and a model are not runtime dependencies. Python is needed only to rebuild the packaged `.dta` files from the eleven finalized Excel workbooks. API/model settings are needed only if a developer separately regenerates mappings with a model. See [Developer guide](docs/DEVELOPMENT.en.md).

## Data notes and limitations

- The package contains 5,764 unique source codes and 57,640 directed crosswalk records.
- The source-workbook snapshot is dated 2026-07-24; SHA-256 hashes are recorded in `occxwalk_manifest.json`.
- CFPS codes 10544–10548 each have two conflicting rows based on enterprise size, but the code itself is identical. The program therefore uses the first Excel row deterministically and prints a warning.
- Exact duplicate GB2015_full rows for 20000 and 20100 were removed without information loss.
- Confidence values are GPT56 workbook outputs and do not imply endorsement by an official statistical classification authority.

See [`examples/occxwalk_example.do`](examples/occxwalk_example.do) for a runnable example.

