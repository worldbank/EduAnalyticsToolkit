{smcl}
{* *! version 1.0 18 SEP 2019}{...}
{hline}
help for {hi:edukit}
{hline}

{title:Title}

{phang}{cmdab:edukit} {hline 2} Returns information on the version of edukit installed

{title:Syntax}

{phang}
{cmdab:edukit}

{pstd}Note that this command takes no arguments at all.{p_end}

{marker desc}
{title:Description}

{pstd}{cmdab:edukit} This command returns the version of edukit installed. It
	can be used in the beginning of a Master Do-file that is intended to be used
	by multiple users to programmatically test if edukit is not installed for
	the user and therefore need to be installed, or if the version the user has
	installed is too old and needs to be upgraded.

{marker optslong}
{title:Options}

{phang}This command does not take any options.

{marker example}
{title:Examples}

{pstd}The code below is an example code that can be added to the top of any do-file.
It first test if the command is installed, and install it if not. If it is
installed, it test if the version is less than version 5.0. If it is, it
replaces the ietoolkit file with the latest version. In your code you can skip
the second part if you are not sure which version is required. But you should
always have the first part testing that {inp:r(version)} has a value before using
it in less than or greater than expressions.

{inp}    cap edukit
{inp}    if "`r(version)'" == "" {
{inp}      *edukit not installed, install it
{inp}      ssc install edukit
{inp}    }
{inp}    else if `r(version)' < 5.0 {
{inp}      *edukit version too old, install the latest version
{inp}      ssc install edukit, replace
{inp}    }{text}

{title:Acknowledgements}

{phang}This help file and its command were adapted from ietoolkit. Check out the {browse "https://github.com/worldbank/ietoolkit":GitHub repository of ietoolkit}.{p_end}

{title:Author}

{phang}Main author (ietoolkit): Kristoffer Bjarkefur

{phang}Adaptation (edukit): Diana Goldemberg

{phang}You can also see the code, make comments to the code, see the version history of the code, and submit additions or
		   edits to the code through the {browse "https://github.com/worldbank/eduanalyticstoolkit":GitHub repository of edukit}.{p_end}
