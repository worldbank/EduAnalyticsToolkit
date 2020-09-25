{smcl}
{* *! version 1.0 8 SEP 2020}{...}
{cmd:help nestweight}{...}
{right:also see: {help "weights"} {help "tabstat"} {help "edukit"} }
{hline}

{title:Title}

{pstd}
{hi:nestweight} {hline 2} Redistributes weights from missing nested observations

{title:Syntax}

{p 8 15 2}
{cmd:nestweight} {it:{help "varname"}} [{it:{help "if"}}] [{it:{help "in"}}] [{it:{help "weights"}}], {opt by}({it:{help "varname"}}{cmd:)} [{opt gen:erate}({it:{help "newvar"}}{cmd:)}] [{opt only}({it:string}{cmd:)}]
{p_end}

{synoptset 30 tabbed}{...}
{synopthdr :Options}
{synoptline}
{syntab :Required}
{synopt :{opt varname}}variable whose missing values trigger the redistribution of weights{p_end}
{synopt :{opt by}({it:varname}{cmd:)}}nesting variable, within which the weights will be redistributed{p_end}

{syntab :Optional}
{synopt :{opt gen:erate}({it:newvar}{cmd:)}}store the new weight variable, after redistribution{p_end}
{synopt :{opt only}({it:string}{cmd:)}}expression to force only some observations to be considered on overall estimate, as if others was forced to missing{p_end}

{synoptline}


{marker description}{...}
{title:Description}

{pstd} {cmd:nestweight} produces overall estimates for nested observations with missing values when the nested level may be correlated with the variable of interest. If your variable of interest is never missing or its values are missing completely at random (MCAR), this program is not for you.

{pstd} For example: a country has 50 states nested in 4 regions. You want a population-weighted national estimate for {it:myvar}, recorded at the state level, with some missing values. You believe that {it:myvar} in states with missing data would be more similar to their regional average than the national average. This program distributes the weights of states where {it: myvar} is missing to non-missing states within the same region.


{title:Options}

{dlgtab:Required}

{phang} {cmdab:varname} variable that, when missing, will trigger the redistribution of weights

{phang} {cmdab:by(}{it:varname}{cmd:)} nesting variable, within which the weights are redistributed

{dlgtab:Optional}

{phang} {cmdab:gen:erate(}{it:newvar}{cmd:)} by default, {cmd:nestweight} does not alter the original dataset. To store the new weight variable used to produced the overall estimate, you must specify this option

{phang} {cmdab:only(}{it:string}{cmd:)} gives extra flexibility to keep only observations based on some criteria, treating others as if {it:myvar} was missing. It can be specified through {it:[if]} and/or {it:[in]} statements. While the main {it:if} and {it:in} statements (before the comma) will affect both the numerator and denominator of the weight adjustment factor, {it:if} and {it:in} statements inside option {it:only} affect only the denominator.


{title:Examples}

{phang} General example:{p_end}

{phang} Dataset of the USA, with 50 observations (states), nested in 4 regions{p_end}
{phang2} {cmd:. sysuse census, clear}{p_end}

{phang} Creates some variable with missing observations{p_end}
{phang2} {cmd:. gen myvar = marriage/divorce if _n > 15}{p_end}

{phang} National unweighted average{p_end}
{phang2} {cmd:. tabstat    myvar, by(region)}{p_end}
{phang2} {cmd:. nestweight myvar, by(region)}{p_end}

{phang} National population-weighted average{p_end}
{phang2} {cmd:. tabstat    myvar [fw = pop], by(region)}{p_end}
{phang2} {cmd:. nestweight myvar [fw = pop], by(region)}{p_end}

{phang} Difference between {cmd:nestweight} and {cmd:tabstat} when generating national estimate:{p_end}
{phang} - tabstat implicitly assumes missing completely at random{p_end}
{phang} - nestweight approximates states with missing values by the region average{p_end}
{phang} Note: regional values are the same, only the national estimate changes{p_end}


{phang} Example in the context of Learning Poverty:{p_end}

{phang2} {cmd:. nestweight learningpoverty if lendingtype != "LNX" [fw = population], by(region) only(if year_assessment >= 2011)}{p_end}

{title:Stored results}

{phang}{cmd:nestweight} stores the following in r():{p_end}

{phang}Scalars{p_end}
{phang2}r(mean) overall mean after weight redistribution{p_end}

{title:Author}

{phang}Diana Goldemberg

{title:Acknowledgements}

{phang}This command was developed for the EduAnalytics team at the World Bank Education Global Practice [eduanalytics@worldbank.org].{p_end}

{phang}You can see the code, make comments, see the version history, and submit additions or
        edits through our {browse "https://github.com/worldbank/eduanalyticstoolkit":GitHub repository}.{p_end}
