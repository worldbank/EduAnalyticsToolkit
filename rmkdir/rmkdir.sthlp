{smcl}
{* *! version 1.0 18 SEP 2019}{...}
{cmd:help rmkdir}{...}
{hline}

{title:Title}

{pstd}
{hi:rmkdir} {hline 2} Conveniently creates folders and sub-folders recursively

{title:Syntax}

{phang}
{cmd:rmkdir}, {opt parent(string)} {opt newfolders(string)}
{p_end}

{synoptset 24 tabbed}{...}
{synopthdr :Options}
{synoptline}
{syntab :Required}
{synopt :{opt parent(string)}}The top folder in which one or many sub-folders will be created.{p_end}
{synopt :{opt newfolders(string)}}String of the folder and sub-folders to create.{p_end}

{synoptline}

{marker description}{...}
{title:Description}

{pstd}{cmd:rmkdir} creates a folder that may have a sub-folder, that may have a sub-folder etc. The {opt newfolders()} option can be specified like {opt newfolders(folder1/folder2/folder3)} where a folder called {it:folder3} will be created in the a folder called {it:folder2}, that will be created in a folder called {it:folder1}, that will be created in the folder specified in {opt parent()}.{p_end}

{pstd}A major benefit of this command is that it does not cause an error if any or all of the folders in {opt newfolders()} exists. If the folder exists the command handles that and move on to the next subfolder. Hence, there will be no error if {opt newfolders(folder1/folder2/folderBBB)} is executed immediately after {opt newfolders(folder1/folder2/folderAAA)}. In that case the folders {it:folder1} and {it:folder2} will be created already when creating folder {it:folderAAA}, but it will not affect the result when creating folder {it:folderBBB}.

{pstd}There is no way to create more than one sub-folder in each folder, so if you want to create both {it:folderAAA} and {it:folderBBB} in {it:folder2} as in the example above, you must run the command twice first using the option {opt newfolders(folder1/folder2/folderAAA)} and then {opt newfolders(folder1/folder2/folderBBB)}.

{pstd}The command returns the local {it:r(resultfolder)} that has the full folder path to the last folder created, for example {it:folder3} in {opt newfolders(folder1/folder2/folder3)}.

{pstd}Up to 64 layers of sub-folders can be created in one execution of this command. 64 comes from the limit of recursive calls Stata allows (see {it:# of nested do-files} in {help limits}), although if this command is run from within a do-file the actual maximum number will be slightly less.

{title:Options}

{dlgtab:Required}

{phang}{opt parent(string)} specifies the top folder where the first sub-folder will be created. The full folder path must be provided.{p_end}

{phang}{opt newfolders(string)} lists the folders that will be created in the folder specified in {opt parent()}. One folder or many folders separated by "/" can be listed. If {it:folder1/folder2} is listed then {it:folder2} will be created inside {it:folder1}. There is no way to use this command to create two folders directly in the {opt parent()} folder, unless this command is used twice.{p_end}

{title:Acknowledgements}

{phang}This command was developed for the EduAnalytics team at the World Bank Education Global Practice [eduanalytics@worldbank.org].{p_end}

{phang}You can also see the code, make comments to the code, see the version history of the code, and submit additions or
        edits to the code through the {browse "https://github.com/worldbank/eduanalyticstoolkit":GitHub repository of edukit}.{p_end}
