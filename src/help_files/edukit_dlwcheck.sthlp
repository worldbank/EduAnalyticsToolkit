{smcl}
{* *! version 1.0 18 SEP 2019}{...}
{cmd:help edukit_dlwcheck}{...}
{hline}

{title:Title}

{pstd}
{hi:edukit_dlwcheck} {hline 2} Validates file and folders structures in EduAnalytics' {help datalibweb:DatalibWeb} folder.

{title:Syntax}

{pstd} Loops over all folders in the CNT folder and test that everything is exactly according to the agreed standard and lists all exceptions.{p_end}

{phang}
{cmd:edukit_dlwcheck}, {opt cntfolder(filepath)} [{opt country(string)} {opt survey(string)} {opt reportfolder(filepath)} {opt showoptional}]
{p_end}

{synoptset 24 tabbed}{...}
{synopthdr :Options}
{synoptline}
{syntab :Required}
{synopt :{opt cntfolder(filepath)}}The full folder path to the {it:CNT} root folder{p_end}

{syntab :Optional}
{synopt :{opt country(string)}}Validates file and folders for only one {bf:country}{p_end}
{synopt :{opt survey(string)}}Validates file and folders for only one {bf:survey}{p_end}
{synopt :{opt reportfolder(filepath)}}File path to where the .txt report will be saved{p_end}
{synopt :{opt showoptional}}Show also optional folders that are missing{p_end}

{synoptline}

{marker description}{...}
{title:Description}

{pstd}{cmd:edukit_dlwcheck} is a command very specific to our work in EduAnalytcis, and might not be applicable in any other case outside our team. We regardless want to want to publish it so that anyone can draw inspiration from it and perhaps even use it.{p_end}

{pstd}The command loops over all content of the {it:CNT} folder and validates its content. The {it:CNT} folder is the top folder in the drive where EduAnalytics stores files for DatalibWeb. In the {it:CNT} folder there are region and country folders, and in the region and country folders there are survey folders. The default behavior of this command is to validate the content of all region and country folders, but using the {opt country()} option the command can be run on all survey folders for a single country only, or by using the {opt survey()} option the command can be run on a single survey folder only.{p_end}

{pstd}When the command validates the content of a folder and its subfolders it performs the following tests:{p_end}

{pmore} (1) All folders and files are named correctly{p_end}
{pmore} (2) All folders and files are saved in the correct location{p_end}
{pmore} (3) All files saved in the correct format (when applicable){p_end}
{pmore} (4) No required files and folders are missing{p_end}
{pmore} (5) No additional exists that should not be there{p_end}

{pstd}A report file is generated that can be saved for future documentation if the option {opt reportfolder()} is used.

{title:Options}

{dlgtab:Required}

{phang}{opt cntfolder(filepath)} specifies the full folder path to the {it:CNT} root folder. This is typically the folder on the network drive where DatalibWeb is reading the EduAnalytics data from, but could just as well be a local path where you want to test folders yet to be published to DatalibWeb. The command will not generate, modify or delete anything in this folder (unless the {opt reportfolder()} option is used to intentionally create reports in this folder).{p_end}

{dlgtab:Optional}

{phang}{opt country(string)} tells the command to only validate content of the survey folders for a specific country or World Bank admin region. Only the World Bank three letter abbreviations may be used, for example {bf:BRA} for {it:Brazil} or {bf:SSA} for {it:Sub-Saharan Africa (excluding high income)}.{p_end}

{phang}{opt survey(string)} tells the command to only validate the content of a single survey folder. The survey name must be given on the format {it:CCC_YYYY_surveyname}, where {it:CCC} is the World Bank three letter admin region or country abbreviation, {it:YYYY} is the year, and {it:surveyname} is one of the following assessment abbreviations: EGRA, LLECE, NLA, PASEC, PIRLS, PISA, PISAD, SACMEQ or TIMSS{p_end}

{phang}{opt reportfolder(filepath)}The full folder path to where the report will be saved. If the option is omitted then no report is generated.{p_end}

{phang}{opt showoptional} includes optional folders in the output. Sub-folders in collections can be either optional or required. If optional folders are missing they are by default not listed in the output. Optional folders are also listed if this option is used.{p_end}

{title:Acknowledgements}

{phang}This command was developed for the EduAnalytics team at the World Bank Education Global Practice [eduanalytics@worldbank.org].{p_end}

{phang}You can also see the code, make comments to the code, see the version history of the code, and submit additions or
        edits to the code through the {browse "https://github.com/worldbank/eduanalyticstoolkit":GitHub repository of edukit}.{p_end}
