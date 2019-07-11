*! version 0.1 11JUL2019 EduAnalytics team_email@worldbank.org

* Uses Pandoc to convert HTML created by dyndoc to GitHub-flavored Markdown (GFM)
*      but made in a flexible way that other input and output files are allowed.

cap program drop edukit_pandoc
program define   edukit_pandoc

	syntax, Path(string) File(string) pandoc(string) [Output(string)]

	* PLACEHOLDER!!! Add check and error messages for:
	* - path doesnt exist/not accessible
	* - pandoc not found in `pandoc'
	* - `file' or `output' does not contain extension

	* input file is tokeniked into name and extension (p_from)
	local name = substr("`file'", 1, strlen("`file'")-strpos("`file'",".")-1)
	local from = substr("`file'", strpos("`file'",".")+1, strlen("`file'")-strpos("`file'","."))

	* when not specified, output is assumed to be same name, to GitHub-flavored Markdown
	if "`output'"==""{
		local output = "`name'.md"
		local to = "gfm"
	}
	else {
		local to = substr("`output'", strpos("`output'",".")+1, strlen("`output'")-strpos("`output'","."))
	}

	* adds path to input and output files
	local full_input	 = "`path'" + "\" + "`file'"
	local full_output	 = "`path'" + "\" + "`output'"

	* calls pandoc command line into a shell
	local  pandoc_cmd  = "`pandoc' `full_input' -f `from' -t `to' -s -o `full_output'"
	shell `pandoc_cmd'

end
