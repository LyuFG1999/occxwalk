*! occxwalk 1.0.0  04aug2026
*! Occupation-code labels, descriptions, and GPT56 crosswalks

program define occxwalk, rclass
    version 14.0
    gettoken action 0 : 0, parse(" ,")
    local action = lower("`action'")

    if "`action'" == "label" {
        _occxwalk_label `0'
        return add
        exit
    }
    if inlist("`action'", "text", "describe", "description") {
        _occxwalk_text `0'
        return add
        exit
    }
    if inlist("`action'", "match", "crosswalk", "convert") {
        _occxwalk_match `0'
        return add
        exit
    }
    if inlist("`action'", "systems", "list") {
        _occxwalk_systems
        return add
        exit
    }

    di as err "unknown occxwalk subcommand: `action'"
    di as txt "syntax:  occxwalk label varname, from(system)"
    di as txt "         occxwalk text  varname, from(system) generate(newvar) field(name|description)"
    di as txt "         occxwalk match varname, from(system) to(system) prefix(prefix)"
    di as txt "         occxwalk systems"
    exit 198
end


program define _occxwalk_systems, rclass
    version 14.0
    di as txt "Supported occupation coding systems"
    di as result "  CFPS  CGSS06  CSS  GB2015_full  GB2015_reduce  GB9909"
    di as result "  ISCO08  ISCO68  ISCO88  ONET_SOC2019_full  SOC2010"
    di as txt "Text-code-only systems: ONET_SOC2019_full and SOC2010"
    return local systems "CFPS CGSS06 CSS GB2015_full GB2015_reduce GB9909 ISCO08 ISCO68 ISCO88 ONET_SOC2019_full SOC2010"
end


program define _occxwalk_resolve_system, rclass
    version 14.0
    syntax , Value(string)

    local raw = ustrlower(ustrtrim(`"`value'"'))
    local key : subinstr local raw "_" "", all
    local key : subinstr local key "-" "", all
    local key : subinstr local key " " "", all
    local system ""
    local textonly 0

    if "`key'" == "cfps" local system "CFPS"
    else if inlist("`key'", "cgss06", "cgss2006", "cgss") local system "CGSS06"
    else if "`key'" == "css" local system "CSS"
    else if inlist("`key'", "gb2015full", "gb2015", "gb15", "gb15f", "gb2015f") local system "GB2015_full"
    else if inlist("`key'", "gb2015reduce", "gb15r", "gb2015r", "gb15reduce", "gb2015reduced") local system "GB2015_reduce"
    else if inlist("`key'", "gb9909", "gb99", "gb09", "gb1999", "gb2009") local system "GB9909"
    else if inlist("`key'", "isco08", "isco2008") local system "ISCO08"
    else if inlist("`key'", "isco68", "isco1968") local system "ISCO68"
    else if inlist("`key'", "isco88", "isco1988") local system "ISCO88"
    else if inlist("`key'", "onetsoc2019full", "onetsoc2019", "onet2019", "onetsoc19", "onet19", "onet") {
        local system "ONET_SOC2019_full"
        local textonly 1
    }
    else if inlist("`key'", "soc2010", "soc10", "soc") {
        local system "SOC2010"
        local textonly 1
    }

    if "`system'" == "" {
        di as err "unknown occupation coding system: `value'"
        di as txt "run {cmd:occxwalk systems} to list supported systems"
        exit 198
    }
    return local system "`system'"
    return scalar textonly = `textonly'
end


program define _occxwalk_make_key, rclass
    version 14.0
    syntax varname, Generate(name) CANONical(string) TEXTOnly(integer)

    capture confirm numeric variable `varlist'
    local input_numeric = (_rc == 0)

    if `textonly' {
        if `input_numeric' {
            di as err "`canonical' codes must be stored in a string variable"
            exit 109
        }
        quietly generate str20 `generate' = upper(ustrtrim(`varlist'))
        return scalar invalid = 0
        return scalar input_numeric = 0
        exit
    }

    if `input_numeric' {
        quietly count if !missing(`varlist') & `varlist' != floor(`varlist')
        if r(N) {
            di as err "numeric occupation codes must be integers; found " r(N) " noninteger observation(s)"
            exit 459
        }
        quietly generate str20 `generate' = strtrim(string(`varlist', "%21.0f")) if !missing(`varlist')
        return scalar invalid = 0
        return scalar input_numeric = 1
        exit
    }

    quietly generate str20 `generate' = ustrtrim(`varlist')
    quietly count if `generate' != "" & !regexm(`generate', "^[0-9]+$")
    local invalid = r(N)
    tempvar numeric_key
    quietly generate double `numeric_key' = real(`generate') if regexm(`generate', "^[0-9]+$")
    quietly replace `generate' = strtrim(string(`numeric_key', "%21.0f")) if regexm(`generate', "^[0-9]+$")
    return scalar invalid = `invalid'
    return scalar input_numeric = 0
end


program define _occxwalk_find_data, rclass
    version 14.0
    syntax , Filename(string)

    capture quietly findfile `filename'
    if !_rc {
        local located `"`r(fn)'"'
        return local fn `"`located'"'
        exit
    }

    capture quietly findfile occxwalk.ado
    if _rc {
        di as err "occxwalk.ado is not on the current ado-path"
        exit 601
    }
    local adofile `"`r(fn)'"'
    local directory = substr(`"`adofile'"', 1, strlen(`"`adofile'"') - strlen("occxwalk.ado"))
    local candidate `"`directory'`filename'"'
    capture confirm file `"`candidate'"'
    if _rc {
        di as err "`filename' not found beside the installed occxwalk.ado"
        di as txt "reinstall the complete package with {cmd:net install occxwalk, ..., replace}"
        exit 601
    }
    return local fn `"`candidate'"'
end


program define _occxwalk_label, rclass
    version 14.0
    syntax varname, [FROM(string) SYSTEM(string) LABELName(name) REPLACE]

    if (`"`from'"' == "" & `"`system'"' == "") | (`"`from'"' != "" & `"`system'"' != "") {
        di as err "specify exactly one of from() or system()"
        exit 198
    }
    local requested `"`from'`system'"'
    quietly _occxwalk_resolve_system, value(`"`requested'"')
    local source "`r(system)'"
    local textonly = r(textonly)

    capture confirm numeric variable `varlist'
    if _rc {
        di as err "occxwalk label requires a numeric variable"
        exit 109
    }
    if `textonly' {
        di as err "value labels are not supported for `source' because its codes are textual"
        exit 109
    }

    if "`labelname'" == "" {
        local labelname = substr("occx_" + lower("`source'") + "_`varlist'", 1, 32)
    }
    capture quietly label list `labelname'
    if !_rc & "`replace'" == "" {
        di as err "value label `labelname' already exists; specify replace or choose labelname()"
        exit 110
    }

    _occxwalk_find_data, filename(occxwalk_catalog.dta)
    local catalog `"`r(fn)'"'

    tempvar key mapname mapamb order tag
    tempfile lookup
    preserve
        quietly use `"`catalog'"', clear
        quietly keep if system == "`source'"
        quietly keep key name ambiguous
        quietly rename key `key'
        quietly rename name `mapname'
        quietly rename ambiguous `mapamb'
        quietly save `"`lookup'"', replace
    restore

    quietly generate long `order' = _n
    quietly _occxwalk_make_key `varlist', generate(`key') canonical("`source'") textonly(0)
    local invalid = r(invalid)
    quietly merge m:1 `key' using `"`lookup'"', nogen keep(master match) keepusing(`mapname' `mapamb')
    quietly sort `order'
    quietly count if !missing(`varlist') & `mapname' != ""
    local matched = r(N)
    quietly count if !missing(`varlist') & `mapname' == ""
    local unmatched = r(N)
    quietly count if !missing(`varlist') & `mapamb' == 1
    local ambiguous = r(N)

    if `matched' == 0 {
        quietly drop `key' `mapname' `mapamb' `order'
        di as err "no nonmissing occupation codes matched `source'"
        exit 459
    }

    if "`replace'" != "" capture label drop `labelname'
    quietly egen byte `tag' = tag(`varlist') if `mapname' != ""
    local first 1
    forvalues i = 1/`=_N' {
        if `tag'[`i'] == 1 {
            local code = `varlist'[`i']
            local labeltext = `mapname'[`i']
            if `first' {
                quietly label define `labelname' `code' `"`labeltext'"'
                local first 0
            }
            else quietly label define `labelname' `code' `"`labeltext'"', add
        }
    }
    label values `varlist' `labelname'
    quietly drop `key' `mapname' `mapamb' `order' `tag'

    if `unmatched' di as txt "note: `unmatched' nonmissing observation(s) did not match `source'"
    if `ambiguous' di as err "warning: `ambiguous' observation(s) use a duplicated CFPS code; the first Excel source row was used"
    di as result "value label `labelname' attached to `varlist' (`matched' matched observation(s))"
    return scalar matched = `matched'
    return scalar unmatched = `unmatched'
    return scalar ambiguous = `ambiguous'
    return scalar invalid = `invalid'
    return local system "`source'"
    return local labelname "`labelname'"
end


program define _occxwalk_text, rclass
    version 14.0
    syntax varname, [FROM(string) SYSTEM(string)] GENerate(name) FIELD(string) [REPLACE]

    if (`"`from'"' == "" & `"`system'"' == "") | (`"`from'"' != "" & `"`system'"' != "") {
        di as err "specify exactly one of from() or system()"
        exit 198
    }
    local requested `"`from'`system'"'
    quietly _occxwalk_resolve_system, value(`"`requested'"')
    local source "`r(system)'"
    local textonly = r(textonly)

    local field = lower(ustrtrim(`"`field'"'))
    if inlist("`field'", "desc", "description") local field "description"
    else if inlist("`field'", "name", "label") local field "name"
    else {
        di as err "field() must be name or description"
        exit 198
    }

    if "`generate'" == "`varlist'" {
        di as err "generate() must name a variable different from the source variable"
        exit 198
    }
    capture confirm variable `generate'
    if !_rc & "`replace'" == "" {
        di as err "variable `generate' already exists; specify replace"
        exit 110
    }

    _occxwalk_find_data, filename(occxwalk_catalog.dta)
    local catalog `"`r(fn)'"'

    tempvar key mapvalue mapamb order
    tempfile lookup
    preserve
        quietly use `"`catalog'"', clear
        quietly keep if system == "`source'"
        quietly keep key `field' ambiguous
        quietly rename key `key'
        quietly rename `field' `mapvalue'
        quietly rename ambiguous `mapamb'
        quietly save `"`lookup'"', replace
    restore

    quietly generate long `order' = _n
    quietly _occxwalk_make_key `varlist', generate(`key') canonical("`source'") textonly(`textonly')
    local invalid = r(invalid)
    quietly merge m:1 `key' using `"`lookup'"', nogen keep(master match) keepusing(`mapvalue' `mapamb')
    quietly sort `order'
    quietly count if `key' != "" & `mapvalue' != ""
    local matched = r(N)
    quietly count if `key' != "" & `mapvalue' == ""
    local unmatched = r(N)
    quietly count if `key' != "" & `mapamb' == 1
    local ambiguous = r(N)

    if "`replace'" != "" capture quietly drop `generate'
    quietly rename `mapvalue' `generate'
    if "`field'" == "name" label variable `generate' "Occupation name (`source')"
    else label variable `generate' "Occupation description (`source')"
    quietly drop `key' `mapamb' `order'

    if `invalid' di as txt "note: `invalid' observation(s) contain nondigit text and could not match numeric system `source'"
    if `unmatched' di as txt "note: `unmatched' nonmissing observation(s) did not match `source'"
    if `ambiguous' di as err "warning: `ambiguous' observation(s) use a duplicated CFPS code; the first Excel source row was used"
    di as result "generated `generate' (`matched' matched observation(s))"
    return scalar matched = `matched'
    return scalar unmatched = `unmatched'
    return scalar ambiguous = `ambiguous'
    return scalar invalid = `invalid'
    return local system "`source'"
    return local field "`field'"
    return local generated "`generate'"
end


program define _occxwalk_match, rclass
    version 14.0
    syntax varname, [FROM(string) SYSTEM(string)] TO(string) PREFIX(name) [REPLACE]

    if (`"`from'"' == "" & `"`system'"' == "") | (`"`from'"' != "" & `"`system'"' != "") {
        di as err "specify exactly one of from() or system()"
        exit 198
    }
    local requested `"`from'`system'"'
    quietly _occxwalk_resolve_system, value(`"`requested'"')
    local source "`r(system)'"
    local textonly = r(textonly)
    quietly _occxwalk_resolve_system, value(`"`to'"')
    local target "`r(system)'"

    if "`source'" == "`target'" {
        di as err "from() and to() must identify different coding systems"
        exit 198
    }

    local codevar "`prefix'_code"
    local namevar "`prefix'_name"
    local confvar "`prefix'_confidence"
    foreach output in `codevar' `namevar' `confvar' {
        capture confirm name `output'
        if _rc {
            di as err "prefix() is too long or produces invalid variable name `output'"
            exit 198
        }
        if "`output'" == "`varlist'" {
            di as err "prefix() would overwrite source variable `varlist'"
            exit 198
        }
    }
    local collision 0
    foreach output in `codevar' `namevar' `confvar' {
        capture confirm variable `output'
        if !_rc local collision 1
    }
    if `collision' & "`replace'" == "" {
        di as err "one or more output variables already exist; specify replace"
        exit 110
    }

    _occxwalk_find_data, filename(occxwalk_links.dta)
    local links `"`r(fn)'"'

    tempvar key mapcode mapname mapconf mapamb order
    tempfile lookup
    preserve
        quietly use `"`links'"', clear
        quietly keep if from_system == "`source'" & to_system == "`target'"
        quietly keep from_key to_code to_name confidence ambiguous
        quietly rename from_key `key'
        quietly rename to_code `mapcode'
        quietly rename to_name `mapname'
        quietly rename confidence `mapconf'
        quietly rename ambiguous `mapamb'
        quietly save `"`lookup'"', replace
    restore

    quietly generate long `order' = _n
    quietly _occxwalk_make_key `varlist', generate(`key') canonical("`source'") textonly(`textonly')
    local invalid = r(invalid)
    quietly merge m:1 `key' using `"`lookup'"', nogen keep(master match) keepusing(`mapcode' `mapname' `mapconf' `mapamb')
    quietly sort `order'
    quietly count if `key' != "" & `mapcode' != ""
    local matched = r(N)
    quietly count if `key' != "" & `mapcode' == ""
    local unmatched = r(N)
    quietly count if `key' != "" & `mapamb' == 1
    local ambiguous = r(N)

    if "`replace'" != "" capture quietly drop `codevar' `namevar' `confvar'
    quietly rename `mapcode' `codevar'
    quietly rename `mapname' `namevar'
    quietly rename `mapconf' `confvar'
    label variable `codevar' "Matched `target' occupation code"
    label variable `namevar' "Matched `target' occupation name"
    label variable `confvar' "GPT56 match confidence: `source' to `target'"
    format `confvar' %6.3f
    quietly drop `key' `mapamb' `order'

    if `invalid' di as txt "note: `invalid' observation(s) contain nondigit text and could not match numeric system `source'"
    if `unmatched' di as txt "note: `unmatched' nonmissing observation(s) did not match `source'"
    if `ambiguous' di as err "warning: `ambiguous' observation(s) use a duplicated CFPS code; the first Excel source row was used"
    di as result "generated `codevar', `namevar', and `confvar' (`matched' matched observation(s))"
    return scalar matched = `matched'
    return scalar unmatched = `unmatched'
    return scalar ambiguous = `ambiguous'
    return scalar invalid = `invalid'
    return local from "`source'"
    return local to "`target'"
    return local codevar "`codevar'"
    return local namevar "`namevar'"
    return local confidencevar "`confvar'"
end
