{smcl}
{* *! version 1.0 18 SEP 2019}{...}
{cmd:help comparefiles}{...}
{hline}

{title:Title}

{pstd}
{hi:comparefiles} {hline 2} Compares files and list all the differences

{title:Syntax}

{pstd}For this command, {it:local file} means the new file you created and is typically saved locally on your computer, and {it:shared file} means a different version of the same file that already exists and is typically saved on a network drive, in the cloud or similar. However, the command can just as well be used to compare two local files, but you pick one that will be the  {it:"shared"} file.{p_end}

{phang}
{cmd:comparefiles}, {opt localfile(filepath)} {opt sharedfile(filepath)} [{opt idvars(varlist)} {opt idsfromchar(string)} {opt compareboth} {opt comparelocal} {opt compareshared} {opt comparevars(varlist)} {opt wigglevars(varlist)} {opt wiggleroom(numlist)} {opt mdreport(filepath)} {opt varlistlenmax(numlist)} {opt mdevensame}]
{p_end}

{synoptset 22 tabbed}{...}
{synopthdr :Options}
{synoptline}
{syntab :Required}
{synopt :{opt localfile(filepath)}}The full file path to the local file{p_end}
{synopt :{opt sharedfile(filepath)}}The full file path to the shared file{p_end}

{p 6 6 2}One option required for specifying idvars{p_end}
{synopt :{opt idvars(varlist)}}The variable or set of variables that identifies both files{p_end}
{synopt :{opt idsfromchar(string)}}Get idvars from {help char} if already saved there{p_end}

{p 6 6 2}One option required for which variables to compare{p_end}
{synopt :{opt compareboth}}Compare all variables in either local or shared file{p_end}
{synopt :{opt comparelocal}}Compare all variables in local file (ignore variables only in shared){p_end}
{synopt :{opt compareshared}}Compare all variables in shared file (ignore variables only in local){p_end}
{synopt :{opt comparevars(varlist)}}Manually list the variables to compare{p_end}

{syntab :Optional}
{synopt :{opt wigglevars(varlist)}}List the variables for which a wiggle room is accepted{p_end}
{synopt :{opt wiggleroom(numlist)}}Set the size of the wiggle room accepted{p_end}
{synopt :{opt mdreport(filepath)}}File path to where to save a report in .md-format{p_end}
{synopt :{opt mdevensame}}Generate a .md report even if the files are identical{p_end}


{synoptline}

{marker description}{...}
{title:Description}

{pstd}{cmd:comparefiles} compares two files and list all differences in variable values. In the basic case this command is very similar to {help cf}, but this command does not require the observations to be sorted the same way, instead a set of uniquely and fully identifying variables are required. For a very simple case {help cf} is likely to be faster so if that commands satisfies your need and your data sets are very large then that could be a better solution for you.{p_end}

{pstd}The two data sets are merged using a 1:1 merge on the set of identifying (ID) variables, so there is no way to get around the need of ID variables. But this enables the command to be sort-order-agnostic, and provide you a report on missing or new observations that are not expected to be there.{p_end}

{title:Options}

{dlgtab:Required}

{phang}{opt localfile(filepath)} lists the full file path to the file that will be called the local file. The file does not have to be saved locally - it could be any file location that can be accessed with the {help use} command - but the intended use case is that this file is the new file to compared to an already existed shared file on a network drive or similar.{p_end}

{phang}{opt sharedfile(filepath)} lists the full file path to the file that will be called the shared file. The file does not have to be saved in a shared location - it could be any file location that can be accessed with the {help use} command - but the intended use case is that this file is a file saved on a network drive or similar that already existed and will be compared to a new file saved locally.{p_end}

{pstd}One option required for specifying ID variables:{p_end}
{phang}{opt idvars(varlist)} lists the variables that uniquely and fully identifies both the local file and the shared file.{p_end}

{phang}{opt idsfromchar(string)} reads the list of ID variables from {help char} saved to the data set. The string in this option is the name of the char saved to {it:_dta[]}. Both files must have this char, the char must be called the same thing, and the content of the char in both files must list the same variables (order does not matter).{p_end}

{pstd}One option required for which variables to compare{p_end}
{phang}{opt compareboth}, {opt comparelocal}, {opt compareshared} and {opt comparevars(varlist)} specifies which variables from the local and the shared files will be compared and listed if missing. Exactly one of these options must be specified:{p_end}

{pmore}- {opt compareboth} makes the command compare all variables that is in either one or both files.{break}
- {opt comparelocal} makes the command compare all variables in the local file regardless if they are in the shared file or not.{break}
- {opt compareshared} makes the command compare all variables in the shared file regardless if they are in the local file or not.{break}
- {opt comparevars(varlist)} explicitly lists the variables to be compared.{p_end}

{dlgtab:Optional}
{phang}{opt wigglevars(varlist)} and {opt wiggleroom(numlist)} allows variables to differ with a percental amount. This is relevant when, for example, the exact variable value depends on randomization, and restructring the code have an impact on the randomization even when the {help seed} it set. {opt wigglevars()} lists the variables where a wiggle room is accpted, and {opt wiggleroom()} specifies how much using decimal points where 0.01 means that the values are allowed to be 1% appart. {opt wiggleroom()} can only be used if {opt wigglevars()} used. If {opt wigglevars()} is not specified, then the wiggle room is defaulted to 0.0001 which means .01%.{p_end}

{phang}{opt mdreport(filepath)} specifies the path to where the report in markdown will be saved. If this option is omitted then no report will be created. If the files are identical in the which observations exists in both of them and in the values in variables compared, then no report is genreated unless option {opt mdevensame} is used.{p_end}

{phang}{opt mdevensame} tells the command to write the report specified in {opt mdreport()} even when the two files are identical. The default is that the report is only written if there are discrepancies. {p_end}

{title:Author}

{phang}Kristoffer Bjärkefur

{title:Acknowledgements}

{phang}This command was developed for the EduAnalytics team at the World Bank Education Global Practice [eduanalytics@worldbank.org].{p_end}

{phang}You can also see the code, make comments to the code, see the version history of the code, and submit additions or
        edits to the code through the {browse "https://github.com/worldbank/eduanalyticstoolkit":GitHub repository of edukit}.{p_end}
