version 14.0
clear all
set more off

* occxwalk bilingual example / occxwalk 中英文示例
* Install once / 首次安装：
* net install occxwalk, from("https://raw.githubusercontent.com/LyuFG1999/occxwalk/main") replace

* List supported systems / 列出支持的编码体系
occxwalk systems

* ------------------------------------------------------------
* 1. Numeric value labels / 给数字变量添加值标签
* ------------------------------------------------------------
clear
input long cfps_code
10000
10100
10544
99999
.
end

occxwalk label cfps_code, from(CFPS) replace
list cfps_code, noobs
return list

* ------------------------------------------------------------
* 2. Generate occupation name and description
*    生成职业名称和完整描述
* ------------------------------------------------------------
occxwalk text cfps_code, from(cfps) ///
    generate(cfps_name) field(name)
occxwalk text cfps_code, from(cfps) ///
    generate(cfps_description) field(description)
list cfps_code cfps_name in 1/4, noobs abbreviate(24)

* ------------------------------------------------------------
* 3. Crosswalk CFPS to ISCO08
*    将 CFPS 转换为 ISCO08
* ------------------------------------------------------------
occxwalk match cfps_code, from(cfps) to(isco08) prefix(isco08)
list cfps_code isco08_code isco08_name isco08_confidence, ///
    noobs abbreviate(28)

* ------------------------------------------------------------
* 4. Leading-zero normalization / 前导零规范化
* ------------------------------------------------------------
clear
input str8 isco_source
"0110"
"110"
"1111"
"bad"
""
end

occxwalk text isco_source, from(isco2008) ///
    generate(isco_name) field(name)
list, noobs

* ------------------------------------------------------------
* 5. String-code systems / 文本代码体系
* ------------------------------------------------------------
clear
input str12 onet_code
"11-1011.00"
"11-1021.00"
"11-1031.00"
""
end

occxwalk match onet_code, from(ONET) to(SOC10) prefix(soc)
list, noobs abbreviate(28)

display as result "occxwalk example completed / 示例运行完成"

