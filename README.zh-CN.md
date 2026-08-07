# occxwalk 中文说明

`occxwalk` 是一个 Stata 职业编码工具，把 12 个 GPT56 职业体系匹配工作簿整理成可离线安装的数据包。它提供三项功能：

1. 为数字职业代码变量添加 Stata 值标签。
2. 根据数字或文本职业代码生成职业名称或完整职业描述。
3. 在两套职业编码体系之间转换，并一次生成目标代码、目标职业名称和匹配置信度。

程序运行时不会访问原始 Excel、Python、OpenAI API 或任何在线模型。

## 支持的职业编码体系

| 规范名称 | 常用别名 | 源变量类型 |
|---|---|---|
| CFPS | `cfps` | 数字或文本 |
| CGSS06 | `cgss06`, `cgss2006`, `cgss` | 数字或文本 |
| CSS | `css` | 数字或文本 |
| GB2015_full | `gb2015`, `gb15`, `gb15f` | 数字或文本 |
| GB2015_reduce | `gb15r`, `gb2015r` | 数字或文本 |
| GB2022 | `gb2022`, `gb22`, `gb2022full` | 数字或文本 |
| GB9909 | `gb99`, `gb09` | 数字或文本 |
| ISCO08 | `isco08`, `isco2008` | 数字或文本 |
| ISCO68 | `isco68`, `isco1968` | 数字或文本 |
| ISCO88 | `isco88`, `isco1988` | 数字或文本 |
| ONET_SOC2019_full | `onet`, `onet2019` | 仅文本 |
| SOC2010 | `soc10`, `soc` | 仅文本 |

体系名称和别名不区分大小写。

## 从 Stata 安装

### GitHub `net install`（推荐）

```stata
net install occxwalk, ///
    from("https://lyufg1999.github.io/occxwalk") ///
    replace
```

检查安装：

```stata
which occxwalk
help occxwalk
occxwalk systems
```

升级到仓库中的最新版本时，重新运行带 `replace` 的 `net install` 即可。

### 本地安装

下载或克隆仓库后，可以临时加入 ado 搜索路径：

```stata
adopath ++ "D:/path/to/occxwalk"
```

也可以把以下四个核心文件复制到 Stata 的 PERSONAL 或 PLUS 目录：

- `occxwalk.ado`
- `occxwalk.sthlp`
- `occxwalk_catalog.dta`
- `occxwalk_links.dta`

使用 `sysdir` 可查看 Stata 的安装目录。不能只复制 `.ado`，因为两个 `.dta` 文件承载离线映射数据。

## 使用方法

### 1. 添加值标签

```stata
occxwalk label occ, from(CFPS)
```

`label` 只支持数字变量，并且不支持以 ONET_SOC2019_full 或 SOC2010 作为源体系，因为这两套代码包含连字符和小数点。

可指定值标签名称；若同名值标签已经存在，使用 `replace`：

```stata
occxwalk label occ, from(gb15) labelname(gb15_occ) replace
```

### 2. 生成职业名称或描述

```stata
occxwalk text occ, from(CFPS) generate(occ_name) field(name)
occxwalk text occ, from(CFPS) generate(occ_description) field(description)
```

除 ONET_SOC2019_full 和 SOC2010 外，源变量可以是数字或文本。数字体系会自动规范化前导零，例如 ISCO08 的数字 `110` 与文本 `"0110"` 都会识别为代码 `0110`。

### 3. 跨体系转换

```stata
occxwalk match occ, from(CFPS) to(ISCO08) prefix(isco)
```

一次生成：

- `isco_code`：目标职业代码，文本变量；
- `isco_name`：目标职业名称，文本变量；
- `isco_confidence`：GPT56 匹配置信度，数字变量。

ONET/SOC 文本代码示例：

```stata
occxwalk match onet_code, from(ONET) to(SOC10) prefix(soc)
```

## 返回结果

三类数据操作都会返回：

- `r(matched)`：成功匹配的非缺失观测数；
- `r(unmatched)`：未匹配的非缺失观测数；
- `r(ambiguous)`：命中冲突重复源代码的观测数；
- `r(invalid)`：数字体系中无法识别的非数字文本观测数。

## Python 与 model 配置

日常使用 ado 不需要 Python 或 model。只有开发者需要从 12 个最终 Excel 工作簿重新生成 `.dta` 时才需要 Python；只有重新调用模型生成职业映射时才需要 API/model 配置。详见 [开发者说明](docs/DEVELOPMENT.zh-CN.md)。

## 数据说明与限制

- 内置目录有 6,214 个唯一源代码和 68,354 条有方向的跨体系映射。
- 原始工作簿快照日期为 2026-08-06，文件哈希记录在 `occxwalk_manifest.json`。
- CFPS 的 10544–10548 各有两条冲突记录：企业规模大于 25 人和小于等于 25 人，但职业代码完全相同。代码本身无法区分，因此程序采用 Excel 中第一条源行并打印警告。
- GB2015_full 的 20000、20100 是完全相同的重复行，构建时已无损去重。
- 置信度来自工作簿中的 GPT56 匹配结果，不代表官方统计分类机构的认可。

完整示例见 [`examples/occxwalk_example.do`](examples/occxwalk_example.do)。
