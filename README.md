# occxwalk

Stata occupation-code labels, descriptions, and crosswalks for 11 coding systems.

用于 11 套职业编码体系的 Stata 值标签、职业名称/描述生成和跨体系转换工具。

[中文说明](README.zh-CN.md) · [English documentation](README.en.md)

## Quick start / 快速开始

```stata
net install occxwalk, ///
    from("https://raw.githubusercontent.com/LyuFG1999/occxwalk/main") ///
    replace

occxwalk systems
occxwalk label occupation, from(CFPS)
occxwalk text occupation, from(CFPS) generate(occupation_name) field(name)
occxwalk match occupation, from(CFPS) to(ISCO08) prefix(isco08)
```

The command runs fully offline after installation. Python, an API key, and an online model are **not** required for normal Stata use.

安装完成后命令完全离线运行。日常 Stata 使用**不需要** Python、API key 或在线模型。

## Included data / 内置数据

- 5,764 unique source occupation codes / 5,764 个唯一源职业代码
- 57,640 directed crosswalk records / 57,640 条有方向的转换记录
- Source systems: CFPS, CGSS06, CSS, GB2015_full, GB2015_reduce, GB9909, ISCO08, ISCO68, ISCO88, ONET_SOC2019_full, SOC2010
- GPT56 workbook snapshot dated 2026-07-24 / GPT56 工作簿快照日期：2026-07-24

## Repository layout / 仓库结构

- `occxwalk.ado`, `occxwalk.sthlp`: Stata command and help
- `occxwalk_catalog.dta`, `occxwalk_links.dta`: packaged offline lookup data
- `examples/occxwalk_example.do`: runnable bilingual example
- `tests/test_occxwalk.do`: Stata regression tests
- `scripts/build_occxwalk_data.py`: rebuild packaged `.dta` files from the 11 finalized Excel workbooks
- `scripts/model_smoke_test.py`: optional OpenAI API/model connectivity test for developers

## Important limitation / 重要限制

CFPS codes 10544–10548 each have two conflicting source rows distinguished by enterprise size, but the code itself is identical. The program deterministically uses the first Excel source row and prints a warning. / CFPS 代码 10544–10548 在源表中各有两条按企业规模区分的冲突记录，但代码相同；程序固定采用 Excel 首行，并在命中时警告。

