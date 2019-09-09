{smcl}
{* *! version 0.2 15 JUL 2019}{...}
{cmd:help edukit_comparefiles}{...}
{hline}

{title:Title}

{pstd}
{hi:edukit_comparefiles} {hline 2} Compares files and list all the differences

{title:Syntax}

{pstd}For this command, {it:local file} means the new file you created and is typically saved locally on your computer, and {it:shared file} means a different version of the same file that already exists and is typically saved on a network drive, in the cloud or similar. However, the command can just as well be used to compare two local files, but you pick one that will be the  {it:"shared"} file.{p_end}

{phang}
{cmd:edukit_comparefiles}, {opt localfile(filepath)} {opt sharedfile(filepath)} [{opt idvars(string)} {opt idsfromchar(string)} {opt compareboth} {opt comparelocal} {opt compareshared} {opt comparevars(string)} {opt wigglevars(string)} {opt wiggleroom(numlist)} {opt mdreport(filepath)} {opt varlistlenmax(numlist)} {opt mdevensame}]
{p_end}

{synoptset 22 tabbed}{...}
{synopthdr :Options}
{synoptline}
{syntab :Required}
{synopt :{opt localfile(filepath)}}The full file path to the local file{p_end}
{synopt :{opt sharedfile(filepath)}}The full file path to the shared file{p_end}

{p 6 6 2}One option required for specifying idvars{p_end}
{synopt :{opt idvars(string)}}The variable or set of variables that identifies both files{p_end}
{synopt :{opt idsfromchar(string)}}Get idvars from {help char} if already saved there{p_end}

{p 6 6 2}One option required for which variables to compare{p_end}
{synopt :{opt compareboth}}Compare all variables in either local or shared file{p_end}
{synopt :{opt comparelocal}}Compare all variables in local file (ignore variables only in shared){p_end}
{synopt :{opt compareshared}}Compare all variables in shared file (ignore variables only in local){p_end}
{synopt :{opt comparevars(string)}}Manually list the variables to compare{p_end}

{syntab :Optional}
{synopt :{opt wigglevars(string)}}List the variables for which a wiggle room is accepted{p_end}
{synopt :{opt wiggleroom(numlist)}}Set the size of the wiggle room accepted{p_end}
{synopt :{opt mdreport(filepath)}}File path to where to save a report in .md-format{p_end}
{synopt :{opt mdevensame}}Generate a .md report even if the files are identical{p_end}


{synoptline}

{marker description}{...}
{title:Description}

{pstd}{cmd:edukit_comparefiles} compares two files and list all differences in variable values. In the basic case this command is very similar to {help cf}, but this command does not require the observations to be sorted the same way, instead a set of uniquely and fully identifying variables are required. For a very simple case {help cf} is likely to be faster so if that commands satisfies your need and your data sets are very large then that could be a better solution for you.{p_end}

{pstd}The two data sets are merged using a 1:1 merge on the set of identifying (ID) variables, so there is no way to get around the need of ID variables. But this enables the command to be sort-order-agnostic, and provide you a report on missing or new observations that are not expected to be there.{p_end}


{title:Options}

{dlgtab:Required}

{phang}{opt localfile(filepath)}{p_end}
{phang}{opt sharedfile(filepath)}{p_end}

{pstd}One option required for specifying idvars{p_end}
{phang}{opt idvars(string)}{p_end}
{phang}{opt idsfromchar(string)}{p_end}

{pstd}One option required for which variables to compare{p_end}
{phang}{opt compareboth}{p_end}
{phang}{opt comparelocal}{p_end}
{phang}{opt compareshared}{p_end}
{phang}{opt comparevars(string)}{p_end}

{dlgtab:Optional}
{phang}{opt wigglevars(string)}{p_end}
{phang}{opt wiggleroom(numlist)}{p_end}
{phang}{opt mdreport(filepath)}{p_end}
{phang}{opt mdevensame}{p_end}

{title:Acknowledgements}

{phang}This command was developed for the EduAnalytics team at the World Bank Education Global Practice [eduanalytics@worldbank.org].{p_end}

{phang}You can also see the code, make comments to the code, see the version history of the code, and submit additions or
        edits to the code through the {browse "https://github.com/worldbank/eduanalyticstoolkit":GitHub repository of edukit}.{p_end}
