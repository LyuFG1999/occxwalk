{smcl}
{* *! version 1.0.0 04aug2026}{...}
{vieweralsosee "occxwalk" "help occxwalk"}{...}

{title:Title}

{phang}
{bf:occxwalk} {hline 2} label, describe, and crosswalk occupation codes using the embedded GPT56 tables


{title:Syntax}

{p 8 16 2}
{cmd:occxwalk label} {it:varname}{cmd:,} {cmd:from(}{it:system}{cmd:)}
[{cmd:labelname(}{it:name}{cmd:)} {cmd:replace}]

{p 8 16 2}
{cmd:occxwalk text} {it:varname}{cmd:,} {cmd:from(}{it:system}{cmd:)}
{cmd:generate(}{it:newvar}{cmd:)} {cmd:field(name|description)} [{cmd:replace}]

{p 8 16 2}
{cmd:occxwalk match} {it:varname}{cmd:,} {cmd:from(}{it:system}{cmd:)}
{cmd:to(}{it:system}{cmd:)} {cmd:prefix(}{it:prefix}{cmd:)} [{cmd:replace}]

{p 8 16 2}
{cmd:occxwalk systems}

{pstd}
{cmd:system()} may be used instead of {cmd:from()}.  System names and aliases are case-insensitive.


{title:Description}

{pstd}
{cmd:occxwalk label} attaches a Stata value label to a numeric occupation-code variable.
It is not available for ONET_SOC2019_full or SOC2010, whose codes contain punctuation and must be strings.

{pstd}
{cmd:occxwalk text} creates either the occupation name or the full occupation description.
Numeric and string variables are accepted for digit-only systems.  ONET_SOC2019_full and SOC2010 require a string source variable.

{pstd}
{cmd:occxwalk match} creates three variables:
{it:prefix}{cmd:_code} (string target code),
{it:prefix}{cmd:_name} (string target occupation name), and
{it:prefix}{cmd:_confidence} (numeric GPT56 confidence).


{title:Systems and aliases}

{p2colset 9 29 31 2}{...}
{p2col:{bf:Canonical}}{bf:Accepted examples}{p_end}
{p2line}
{p2col:CFPS}cfps{p_end}
{p2col:CGSS06}cgss06, cgss2006, cgss{p_end}
{p2col:CSS}css{p_end}
{p2col:GB2015_full}gb2015_full, gb2015, gb15, gb15f{p_end}
{p2col:GB2015_reduce}gb2015_reduce, gb15r, gb2015r{p_end}
{p2col:GB9909}gb9909, gb99, gb09{p_end}
{p2col:ISCO08}isco08, isco2008{p_end}
{p2col:ISCO68}isco68, isco1968{p_end}
{p2col:ISCO88}isco88, isco1988{p_end}
{p2col:ONET_SOC2019_full}onet_soc2019_full, onet2019, onet{p_end}
{p2col:SOC2010}soc2010, soc10, soc{p_end}
{p2line}
{p2colreset}{...}


{title:Options}

{phang}
{cmd:from(}{it:system}{cmd:)} specifies the source coding system.  {cmd:system()} is an equivalent spelling.

{phang}
{cmd:to(}{it:system}{cmd:)} specifies the target coding system for {cmd:match}.

{phang}
{cmd:generate(}{it:newvar}{cmd:)} names the variable created by {cmd:text}.

{phang}
{cmd:field(name|description)} selects the short occupation name or full description.

{phang}
{cmd:prefix(}{it:prefix}{cmd:)} supplies the common prefix for the three variables created by {cmd:match}.

{phang}
{cmd:labelname(}{it:name}{cmd:)} overrides the automatically generated value-label name.

{phang}
{cmd:replace} permits replacement of an existing output variable or value-label definition.


{title:Examples}

{phang2}{cmd:. occxwalk label occ, from(CFPS)}

{phang2}{cmd:. occxwalk text occ, from(gb15r) generate(occ_name) field(name)}

{phang2}{cmd:. occxwalk text onet_code, from(ONET) generate(onet_desc) field(description)}

{phang2}{cmd:. occxwalk match occ, from(cfps) to(isco08) prefix(isco)}

{phang2}{cmd:. occxwalk match soc_code, from(soc10) to(gb2015) prefix(gb15)}


{title:Code normalization and source-data notes}

{pstd}
For digit-only systems, leading zeros are normalized for matching.  Thus numeric ISCO08 value 110 and string value "0110" both match canonical code 0110.

{pstd}
The CFPS source workbook contains conflicting duplicate rows for codes 10544 through 10548 (business size above 25 versus at most 25 employees).
Because the code alone cannot distinguish them, {cmd:occxwalk} uses the first Excel source row and prints a warning when an input observation uses one of these codes.
Two exact duplicate GB2015_full rows were removed without loss.


{title:Stored results}

{pstd}
All data-changing subcommands return:

{synoptset 22 tabbed}{...}
{synopt:{cmd:r(matched)}}number of matched nonmissing observations{p_end}
{synopt:{cmd:r(unmatched)}}number of unmatched nonmissing observations{p_end}
{synopt:{cmd:r(ambiguous)}}number of observations using a conflicting duplicate source code{p_end}
{synopt:{cmd:r(invalid)}}number of nondigit strings supplied for a digit-only system{p_end}


{title:Data provenance}

{pstd}
The package data were generated from the eleven files named
{it:职业体系匹配_主体系_<system>_GPT56.xlsx}, dated 24 July 2026.
The workbooks are not required at run time; the packaged .dta files contain all names, descriptions, target codes, target names, and confidence values used by the command.

