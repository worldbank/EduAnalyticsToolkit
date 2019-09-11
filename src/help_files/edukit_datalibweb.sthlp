{smcl}
{* *! version 0.2 15 JUL 2019}{...}
{cmd:help edukit_datalibweb}{...}
{hline}

{title:Title}

{pstd}
{hi:edukit_datalibweb} {hline 2} Conveniently calls datalibweb repeatedly

{title:Syntax}

{phang}
{cmd:edukit_datalibweb}, {opt D:atalibweb_syntax(string)}
{p_end}

{synoptset 30 tabbed}{...}
{synopthdr :Options}
{synoptline}
{syntab :Required}

{synopt :{opt D:atalibweb_syntax(string)}}contents should match options of original {cmd:datalibweb} syntax{p_end}

{synoptline}

{marker description}{...}
{title:Description}

{pstd}{cmd:edukit_datalibweb} calls {cmd:datalibweb} repeatedly to prevent breaking a long loop if network connection is temporarily lost/other issues while querying a file. It tentatively calls {cmd:datalibweb} 5 times, stopping as soon as a non-empty dataset is successfully loaded or displaying the original error message from {cmd:datalibweb} if all attempts failed.

{pstd}An interesting side effect of this command is suppressing the {cmd:datalibweb} header and disclaimer, normally displayed at every query.

{pstd}The command {cmd:edukit_datalibweb} borrows the exact same syntax of {cmd:datalibweb},	passed through the option {opt datalibweb_syntax()}. Thus, it is recommended that you check the original help file of {help "datalibweb"} for more info on syntax.

{pstd}Similarly to {cmd:datalibweb}, this command will only work for users logged into the World Bank network.

{title:Options}

{dlgtab:Required}

{phang}{opt D:atalibweb_syntax(string)} passes the exact same syntax of {cmd:datalibweb}. This option is required.{p_end}

{title:Examples}

{pstd}
Example in the context of GLAD:

    . foreach cnt of local countries {
      . foreach prefix in ASA ASG ASH ACG {

        . {cmd:edukit_datalibweb, d(country(WLD) year(2001) type(EDURAW) surveyid(WLD_2001_PIRLS) filename(`prefix'`cnt'.dta))}

        . // The line above is equivalent to, but more convenient than:
        . // datalibweb, country(WLD) year(2001) type(EDURAW) surveyid(WLD_2001_PIRLS) filename(`prefix'`cnt'.dta)

        . save "`temp_dir'/`prefix'.dta", replace
      . }

      . // Merge all 4 prefixes into a single cnt file
     . }

{title:Author}

{phang}Main Author: Diana Goldemberg

{title:Acknowledgements}

{phang}This command was developed for the EduAnalytics team at the World Bank Education Global Practice [eduanalytics@worldbank.org].{p_end}

{phang}You can also see the code, make comments to the code, see the version history of the code, and submit additions or
        edits to the code through the {browse "https://github.com/worldbank/eduanalyticstoolkit":GitHub repository of edukit}.{p_end}
