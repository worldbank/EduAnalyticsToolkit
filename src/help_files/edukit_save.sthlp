{smcl}
{* *! version 1.0 18 SEP 2019}{...}
{cmd:help edukit_save}{...}
{right:also see:  {help "save"} {help "char"} {help "dyntext"} {help "isid"} }
{hline}

{title:Title}

{pstd}
{hi:edukit_save} {hline 2} Saves a dataset with metadata

{title:Syntax}

{pstd} Saves a dataset after performing checks/special commands and storing metadata

{p 8 15 2}
{cmd:edukit_save}, {opt filename(string)} {opt path(path)} {opt idvars(varlist)} [{opt varclasses(string)} {opt metadata(string)} {opt dir2delete(path)} {opt collection(string)}]
{p_end}

{synoptset 30 tabbed}{...}
{synopthdr :Options}
{synoptline}
{syntab :Required}
{synopt :{opt file:name}({it:string}{cmd:)}}name for the .dta being saved{p_end}
{synopt :{opt p:ath}({it:path}{cmd:)}}folder where the .dta will be saved{p_end}
{synopt :{opt id:vars}({it:varlist}{cmd:)}}variables which compose a unique identifier in the dataset, automatically given the variable class id{p_end}

{syntab :Optional}
{synopt :{opt varc:lasses}({it:string}{cmd:)}}tokenized string to fill {it:char varZ[varclass] y}, where y are variable classes such as value, trait, sample, etc{p_end}
{synopt :{opt meta:data}({it:string}{cmd:)}}tokenized string to be stored as characteristics of the dataset, that is, {it:char _dta[X] x}, where X and x can be anything{p_end}
{synopt :{opt dir2delete}({it:path}{cmd:)}}usually a temp folder that one wishes to delete as a last step{p_end}
{synopt :{opt coll:ection}({it:string}{cmd:)}}apply commands that are specific to EduAnalytics collections{p_end}

{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:edukit_save} saves a dataset after performing checks/special commands, compressing and storing metadata in a way that is easy to integrate with {it:{help "dyntext"}} for automatically creating documentation, streamlining the workflow.

{pstd} First, to ensure data quality, the command checks whether the variables specified in {it:idvars} uniquely identify the dataset.

{pstd} Secondly, for storage efficiency and documentation quality assurance, only variables declared through the options {it:idvars} or {it:varclasses} are kept in the dataset. Any other existing variable is dropped. The command also automatically calls {it:{help "compress"}}.

{pstd} Thirdly, the command stores metadata as characteristics of the dataset ({it:{help "char"}}). It automatically stores: (1) {it:lastsave}, a timestamp of date, time and user; (2) {it:varclasses_used}, which is idvars plus any other varclasses specified as options. In addition, it also stores all items passed in the tokenized {it:metadata} string (ie: {it: metadata(X x; Y y; Z z)} creates dta chars X, Y, Z with values x, y, z).

{pstd} Lastly, there is a placeholder for special commands, which fulfills specific needs from the EduAnalytics team, according to the data collection being manipulated. External users can easily customize this section for their own needs.

{title:Options}

{dlgtab:Required}

{phang} {cmdab:filename(}{it:string}{cmd:)} specifies a filename for the .dta being saved. It may be enter with or without the sufix .dta.

{phang} {cmdab:path(}{it:path}{cmd:)} folder to save the dataset - purposefully mandatory to avoid default saving files in the working dir.

{phang} {cmdab:idvars(}{it:varlist}{cmd:)} variables which compose a unique identifier in the dataset, automatically given the variable class {it:idvar}. The check {it:{help "isid"} `idvars'} will be performed. If any idvar is missing or if they do not uniquely identify the dataset, the code will break.

{dlgtab:Optional}

{phang} {cmdab:varclasses(}{it:string}{cmd:)} tokenized string to fill {it:char varZ[varclass] y}, where y are variable classes such as value, trait, sample, etc. Besides assigning chars to the variables, it also assign it to the dta, for example: {it:varclass(value varA varB varC)} will create {it:char _dta[valuevars] "varA varB varC"}.

{phang} {cmdab:metadata(}{it:string}{cmd:)} tokenized string to be stored as characteristics of the dataset, that is, {it:char _dta[X] x}, where X and x can be anything. For example, in files from the Global Learning Assessment Database (GLAD) collection, metadata includes: region, year, assessment, vintage.

{phang} {cmdab:dir2delete(}{it:path}{cmd:)} usually a temp folder that one wishes to delete as a last step, to save space. It erases the contents of the folder and the folder itself.

{phang} {cmdab:collection(}{it:string}{cmd:)} apply commands that are specific to EduAnalytics collections. For example, in files from the Global Learning Assessment Database (GLAD) collection, we first save {it:filename_BASE.dta} without dropping any variables. External users can easily customize this section for their own needs.



{title:Examples}

{pstd}
Examples in the context of Learnig4All and GLAD:

   . {cmd:edukit_save, filename(population) path("${clone}/01_data/013_outputs")) idvars(countrycode year)}
	 {cmd:         varc("value pop_all  pop_ma pop_fe; trait pop_source")}


   . {cmd:edukit_save, filename("`output_file'") path("`output_dir'") idvars("`idvars'")}
	 {cmd:         varc("key `keyvars'; value `valuevars'; trait `traitvars'; sample `samplevars'")}
	 {cmd:         metadata("`metadata'") collection("GLAD") dir2delete("`temp_dir'")}


{title:Author}

{phang}Main Author: Diana Goldemberg

{title:Acknowledgements}

{phang}This command was developed for the EduAnalytics team at the World Bank Education Global Practice [eduanalytics@worldbank.org].{p_end}

{phang}Kristoffer Bjarkefur and Joao Pedro Azevedo provided a number of suggestions for improving the routine and help file.{p_end}

{phang}You can also see the code, make comments to the code, see the version history of the code, and submit additions or
        edits to the code through the {browse "https://github.com/worldbank/eduanalyticstoolkit":GitHub repository of edukit}.{p_end}
