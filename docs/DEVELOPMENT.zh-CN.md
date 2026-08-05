# 开发者说明：Python 与 model 配置

## 先明确两条流程

### 使用现成的 Stata 包

不需要 Python、不需要 API key，也不需要 model。`occxwalk.ado` 只读取随包安装的 `occxwalk_catalog.dta` 和 `occxwalk_links.dta`。

### 重新构建或重新生成映射

- 从 11 个**已经完成匹配**的 GPT56 Excel 工作簿重新生成 `.dta`：只需要 Python。
- 从原始职业清单重新调用模型、重新判断职业匹配：需要 Python、OpenAI SDK、API key 和 model；本仓库只提供连接测试与配置约定，不包含原始映射提示词和批量生成管线。

## 配置 Python 构建环境

建议使用 Python 3.10 或更高版本。

Windows PowerShell：

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r requirements-build.txt
```

macOS/Linux：

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements-build.txt
```

准备一个目录，其中包含以下 11 个文件：

```text
职业体系匹配_主体系_CFPS_GPT56.xlsx
职业体系匹配_主体系_CGSS06_GPT56.xlsx
职业体系匹配_主体系_CSS_GPT56.xlsx
职业体系匹配_主体系_GB2015_full_GPT56.xlsx
职业体系匹配_主体系_GB2015_reduce_GPT56.xlsx
职业体系匹配_主体系_GB9909_GPT56.xlsx
职业体系匹配_主体系_ISCO08_GPT56.xlsx
职业体系匹配_主体系_ISCO68_GPT56.xlsx
职业体系匹配_主体系_ISCO88_GPT56.xlsx
职业体系匹配_主体系_ONET_SOC2019_full_GPT56.xlsx
职业体系匹配_主体系_SOC2010_GPT56.xlsx
```

运行构建：

```powershell
python scripts/build_occxwalk_data.py `
  --input-dir "D:\path\to\ChatGPT" `
  --output-dir "."
```

构建脚本会：

1. 验证 11 套体系和全部必需列；
2. 对数字体系生成去除前导零的内部匹配键；
3. 按 Excel 源行顺序处理重复代码；
4. 生成 `occxwalk_catalog.dta`、`occxwalk_links.dta` 和 `occxwalk_manifest.json`；
5. 验证主键唯一、置信度位于 `[0,1]`、且每个唯一源代码具有 10 条目标体系映射。

## 配置 OpenAI API 与 model（仅可选开发流程）

安装官方 Python SDK：

```powershell
python -m pip install -r requirements-model.txt
```

在当前 PowerShell 会话中设置环境变量：

```powershell
$env:OPENAI_API_KEY = "你的 API key"
$env:OPENAI_MODEL = "gpt-5.6"
```

macOS/Linux：

```bash
export OPENAI_API_KEY="your_api_key"
export OPENAI_MODEL="gpt-5.6"
```

不要把真实 API key 写入 `.env.example`、Python 文件或 Git 提交。OpenAI 官方 SDK会自动读取 `OPENAI_API_KEY`。模型通过 `OPENAI_MODEL` 传给本仓库的可选测试脚本；如不设置，脚本默认使用 `gpt-5.6`。

运行连接测试（会产生一次很小的 API 请求并可能产生费用）：

```powershell
python scripts/model_smoke_test.py
```

OpenAI 官方参考：

- [Developer quickstart](https://developers.openai.com/api/docs/quickstart)
- [Models](https://developers.openai.com/api/docs/models)
- [Model guidance](https://developers.openai.com/api/docs/guides/latest-model)

## Stata 回归测试

从仓库根目录运行：

```stata
do tests/test_occxwalk.do .
```

测试覆盖数字值标签、职业名称、完整描述、ISCO08 前导零、ONET/SOC 文本限制、跨体系转换和 CFPS 歧义警告。

