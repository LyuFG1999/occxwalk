version 14.0
clear all
set more off

args package_dir
if `"`package_dir'"' == "" local package_dir "."
adopath ++ `"`package_dir'"'

occxwalk systems
assert strpos("`r(systems)'", "CFPS") > 0

clear
input double occ
10000
10100
10544
99999
.
end
generate long original_order = _n
occxwalk label occ, from(cFpS) replace
assert r(matched) == 3
assert r(unmatched) == 1
assert r(ambiguous) == 1
assert original_order == _n
decode occ, generate(occ_label)
assert occ_label[1] == "国家机关、党群组织、企业、事业单位负责人"

occxwalk text occ, from(cfps) generate(occ_name) field(name)
assert occ_name[1] == "国家机关、党群组织、企业、事业单位负责人"
occxwalk text occ, from(cfps) generate(occ_desc) field(description)
confirm strL variable occ_desc
assert occ_desc[1] != ""

occxwalk match occ, from(cfps) to(isco08) prefix(isco)
assert isco_code[1] == "1120"
assert isco_name[1] == "Managing Directors and Chief Executives"
assert abs(isco_confidence[1] - .62) < 1e-12

clear
input str8 isco_source
"0110"
"110"
"1111"
"bad"
""
end
occxwalk text isco_source, from(IsCo2008) generate(isco_name) field(name)
assert r(matched) == 3
assert r(unmatched) == 1
assert r(invalid) == 1
assert isco_name[1] == isco_name[2]

clear
input str12 onet
"11-1011.00"
"11-1021.00"
"bad"
""
end
occxwalk match onet, from(ONET) to(soc10) prefix(soc)
assert r(matched) == 2
assert r(unmatched) == 1
assert soc_code[1] == "11-1011"
assert soc_name[1] == "Chief Executives"
assert abs(soc_confidence[1] - .99) < 1e-12

clear
input double invalid_onet
111011
end
capture noisily occxwalk text invalid_onet, from(onet) generate(x) field(name)
assert _rc == 109

display as result "ALL_OCCXWALK_TESTS_PASSED"
exit, clear

