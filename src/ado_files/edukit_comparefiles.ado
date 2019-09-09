* This command is similar to cf, but this handles the case with difference
* in number of observation better, and data set do not have to be sorted.
* if listdetail(filename) is specified, a markdown file will be created listing
* all the different observations.

cap program drop edukit_comparefiles
program edukit_comparefiles, rclass

qui {

	syntax , ///
		localfile(string)   ///
		sharedfile(string)  ///
		[                   ///
		idvars(string)		///
		idsfromchar(string)  ///
		compareboth          ///
		comparelocal        ///
		compareshared       ///
		comparevars(string) ///
		wigglevars(string)  ///
		wiggleroom(numlist min=1 max=1 >0 <1)  ///
		mdreport(string)			///
		varlistlenmax(numlist min=1 max=1 >0) ///
		mdevensame ///
		]

	preserve

	noi di ""

	*Prepare a markdown file for listing differences if listdetail is specified
	if "`mdreport'" != "" {
		tempname	filehandle
		tempfile	tmp_mdfile
		file open  `filehandle' using `tmp_mdfile', write text replace

		markdown_writeheader, filehandle(`filehandle') localfile(`localfile') sharedfile(`sharedfile')
	}

	  **************************************
	  ************* Test input *************
		**************************************

		* Test if the file paths to local and shared files are correct
		foreach file in localfile sharedfile {

			* If no file extension is used, add .dta
			if (substr("``file''", -4, .) != ".dta") local `file' "``file''.dta"

			* Test that file exists
			cap confirm file "``file''"
			if ("`file'" == "localfile" & _rc == 601) {
				noi di as error "{phang}The file used in option `file'() is not found. Check if this file path is correct: ``file'' {p_end}"
				error _rc
			}
			if ("`file'" == "sharedfile" & _rc == 601) {
				noi di "{phang}The file used in option `file'() is not found. Check if this file path is correct: ``file''.{p_end}"

				* Out put in file if listdetail option used
				if "`mdreport'" != "" {
					file write `filehandle' _n "#### Shared file does not exist" _n
					markdown_writefile , filehandle(`filehandle') markdownfile("`mdreport'") markdowntemp("`tmp_mdfile'")
				}

				return local identical 0
				return local sharednoexist 1

				exit
			}
			else if _rc confirm file "``file''"
		}

		* Counting how many compare options are used, only exacly one is allowed
		local numcomp = (!missing("`compareboth'") + !missing("`comparelocal'") + !missing("`compareshared'") + !missing("`comparevars'"))

		* Test that at least at least one compare option were used
		if (`numcomp' == 0) {
			noi di as error "{phang}You must use one of the options {cmd:compareboth}, {cmd:comparelocal}, {cmd:compareshared} or {cmd:comparevars}.{p_end}"
			error 198
			exit
		}

		* Test that exactly one compare option was used
		if (`numcomp' > 1)  {
			noi di as error "{phang}You may only use exactly one of the options {cmd:compareboth}, {cmd:comparelocal}, {cmd:compareshared} and {cmd:comparevars}.{p_end}"
			error 198
			exit
		}

		* Test comparell and comparevars were not both used at the same time
		if (!missing("`idvars'") + !missing("`idsfromchar'") != 1) {
			noi di as error "{phang}You must use one and only one of the options {cmd:idvars()} or {cmd:idsfromchar}.{p_end}"
			error 198
			exit
		}

		* Test comparell and comparevars were not both used at the same time
		if "`wiggleroom'" != "" & "`wigglevars'" == "" {
			noi di as error "{phang}You can only use option {cmd:wiggleroom} in combination with option {cmd:wigglevars}.{p_end}"
			error 198
			exit
		}

		**************************************
	  	*** Set up locals used in command  ***
		**************************************

		*Start by assuming files are identical
		local identical = 1

		*
		if "`varlistlenmax'" == "" {
				local varlistlenmax  200 //
		}


		*Use 0.01 percent as default wiggle room
		if "`wiggleroom'" == "" {
				local wiggleroom   0.0001 // default value .01%
		}

		*Prepare a note with the wiggle room in percent
		local wpercent     = `wiggleroom' * 100
		local wigglepercent "`wpercent'%"

		**************************************
	  ********* Prepare local file *********
		**************************************

		noi di "{pstd}Local file:  `localfile'{p_end}"
		noi di "{pstd}Shared file: `sharedfile'{p_end}"
		noi di ""

		use "`localfile'", clear

		* Get idvars from char if option idsfromchar is num_obs_only_in_shared
		if ("`idsfromchar'" != "") {
			local idvars : char _dta[`idsfromchar']
			if ("`idvars'" == "") {
				noi di as error "{pstd}There is no values in _dta[`idsfromchar'] in the local file. Make sure that the char name is correct.{p_end}"
				error 198
			}
		}

		*test that idvars are fully an uniquely identifying
		cap isid `idvars'
		if (_rc ==459) {
			noi di as error "{pstd}Variables [`idvars'] do not fully and uniquely identify the observations in localfile(). The local and shared files can only be compared if they have the same fully and uniquely identifying ID variables.{p_end}"
			error _rc
		}
		else if (_rc == 111) {
			noi di as error "{pstd}Not all ID variables [`idvars'] exist in the local file. The local and shared files can only be compared if they have the same fully and uniquely identifying ID variables.{p_end}"
			error _rc
		}
		else if (_rc != 0) {
			noi di as error "{pstd}Error in isid for local file in edukit_comparefiles.ado{p_end}"
			isid `idvars'
		}

		** If compareboth was used, then take all variables from localfile apart
		*  from idvars and add to comparevars
		if "`compareboth'" != "" {
			ds `idvars', not
			local comparevars "`r(varlist)'"
		}

		*Save the number of obseravations
		local obs_in_local_file = _N
		noi di "{col 5}Local file: {col 18}N = `obs_in_local_file'"

		* Make a list of all vars in the local file
		ds
		local local_file_vars `r(varlist)'

		* Make a list of all value vars in the local file
		local local_file_comparevars : list comparevars & local_file_vars

		* Make a list of all value vars expected in local file but missing
		local local_file_miss_comparevars : list comparevars - local_file_comparevars

		*Rename all vars in the local data set (this rename will not be saves)
		foreach localvar of local local_file_comparevars {
			rename `localvar' `localvar'__
		}

		*Save temporary data set
		tempfile localdata
		save 	`localdata'

		**************************************
	  ******** Prepare shared file  ********
		**************************************

		use "`sharedfile'", clear

		if ("`idsfromchar'" != "") {
			local sharedidvars : char _dta[`idsfromchar']
			if ("`sharedidvars'" == "") {
				noi di as error "{pstd}There is no values in _dta[`idsfromchar'] in the shared file. Make sure that the char name is correct.{p_end}"
				error 198
			}
			if (`:list sharedidvars === idvars' == 0) {
				noi di as error "{pstd}The values in _dta[`idsfromchar'] is different in the local file and the shared file. This is not allowed.{p_end}"
				error 198
			}
		}

		*test that idvars are fully an uniqely identiftying
		cap isid `idvars'
		if _rc ==459 {
			noi di as error "{pstd}Variables [`idvars'] do not fully and uniquely identify the observations in sharedfile(). The local and shared files can only be compared if they have the same fully and uniquely identifying ID variables.{p_end}"
			error _rc
		}
		else if (_rc == 111) {
			noi di as error "{pstd}Not all ID variables [`idvars'] exist in the shared file. The local and shared files can only be compared if they have the same fully and uniquely identifying ID variables.{p_end}"
			error _rc
		}
		else if (_rc != 0) {
			noi di as error "{pstd}Error in isid for shared file in edukit_comparefiles.ado{p_end}"
			isid `idvars'
		}

		*Save the number of obseravations
		local obs_in_shared_file = _N
		noi di "{col 5}Shared file: {col 18}N = `obs_in_shared_file'"


		* Make a list of all vars in the shared file
		ds
		local shared_file_vars `r(varlist)'

		* Make a list of all value vars in the local file
		local shared_file_comparevars : list comparevars & shared_file_vars

		* Make a list of all value vars expected in local file but missing
		local shared_file_miss_comparevars : list comparevars - shared_file_comparevars

		**************************************
	  ************ Merge files  ************
		**************************************

		merge 1:1 `idvars' using `localdata', gen(local_shared_merge)

		tempvar IDstring
		gen `IDstring' = ""
		foreach idvar of local idvars {
			tostring `idvar', replace force
			replace `IDstring' = `IDstring' + ":" + `idvar'
		}
		replace `IDstring' = substr(`IDstring', 2, .)

		**************************************
		* Test if local file has observations not in shared
		count if local_shared_merge == 1
		local num_obs_only_in_local `r(N)'

		count if local_shared_merge == 2
		local num_obs_only_in_shared `r(N)'

		count if local_shared_merge == 3
		local num_obs_both `r(N)'

		noi di "{pstd}In both file: `num_obs_both' obs.{p_end}"
		noi di "{pstd}In local file only: `num_obs_only_in_local' obs.{p_end}"
		noi di "{pstd}In shared file only: `num_obs_only_in_shared' obs.{p_end}"


		if "`mdreport'" != "" {
			markdown_obs, filehandle(`filehandle') ///
			obs_in_lfile(`obs_in_local_file') obs_in_sfile(`obs_in_shared_file') ///
			obs_both(`num_obs_both') obs_only_l(`num_obs_only_in_local') obs_only_s(`num_obs_only_in_shared')
		}


		**************************************
	  ********** Test Difference ***********
		**************************************
		***** Missing compare variables ******
		**************************************

		noi di ""
		if ("`compareboth'" != "") local compvar_str "The option [compareboth] was used so all variables in the local file will be compared across the two files."
		else if ("`comparelocal'" != "") local compvar_str "PLACEHOLDER compvar_str"
		else if ("`compareshared'" != "") local compvar_str "PLACEHOLDER compvar_str"
		else if ("`comparevars'" != "") local compvar_str "The variables in [comparevars(`comparevars')] will be compared across the two files."

		noi di "{pstd}`compvar_str'{p_end}"

		* Export list of compare variables missing in local file
		if "`local_file_miss_comparevars'" != "" {

			local identical = 0

			* Trunctate varaible list if too long
			str_to_disp, string("`local_file_miss_comparevars'") maxlen(`varlistlenmax')
			local lfile_missvars_str "Value variables are missing in the local file. These variables are missing: `r(str_to_disp)'"

			*Output in result window
			noi di ""
			noi disp "{phang}`lfile_missvars_str'{p_end}"

		}

		*Export list of compare variables missing in shared file
		if "`shared_file_miss_comparevars'" != "" {

			local identical = 0

			* Trunctate varaible list if too long
			str_to_disp, string("`shared_file_miss_comparevars'") maxlen(`varlistlenmax')
			local sfile_missvars_str "Value variables are missing in the shared file. These variables are missing: `r(str_to_disp)'"

			*Output in result window
			noi di ""
			noi disp "{phang}`sfile_missvars_str'{p_end}"
		}

		if "`local_file_miss_comparevars'" == "" & "`shared_file_miss_comparevars'" == "" {
			noi di ""
 			noi di "{pstd}All compare variables exist in both files.{p_end}"
		}
		noi di ""

		if "`mdreport'" != "" {
			markdown_varsexist, filehandle(`filehandle') ///
			lfile_missvars(`lfile_missvars_str') sfile_missvars(`sfile_missvars_str') ///
			compvar_str("`compvar_str'")
		}






		**************************************
	  ********** Test Difference ***********
		**************************************
		********* Different values ***********
		**************************************

		noi di ""

		*Keep only observatins in both
		keep if local_shared_merge == 3

		local N_both `=_N'

		if "`mdreport'" != "" {
			file write `filehandle' "## Variables with missmatches" _n
		}

		local allvarsidentical = 1

		* Create a list of variables
		local comparevars_both_files : list shared_file_comparevars & local_file_comparevars

		tempvar same wigglevalue diff
		gen `same'        = 0
		gen `wigglevalue' = 0

		*Loop over all non-idvars
		foreach compvar of local comparevars_both_files {

			*Reset values for each var
			replace `same'        = 0
			replace `wigglevalue' = 0

			cap drop `diff'

			*Note to display when wiggle room was
			local wigglenote ""

			**************
			* Test that variables are the same type

			* Test first what typ var is in local file
			cap confirm string variable `compvar'__
			if !_rc local vartype "string"
			else local vartype "numeric"

			* Then test that var is the same in shared file
			cap confirm `vartype' variable `compvar'
			if _rc {

				local identical = 0

				*Output in result window
				noi disp "{phang}Type miss-missmatch, `vartype' in local file {p_end}"

				* Out put in file if listdetail option used
				if "`mdreport'" != "" {
					file write `filehandle' _n "#### `compvar'" _n
					file write `filehandle' "**Variable is `vartype' in local file but not in shared file**" _n
				}
			}


			* Var is of same typ in both files. Continue with test
			else {

				**************
				* Test that variables are identical

				local thisvar_wigglevar : list compvar in wigglevars
				if `thisvar_wigglevar' local wigglenote " (using a wiggle room of `wigglepercent')"

				if ("`vartype'" == "string") {
					* String variables tests are srtaight forward
					replace `same'  = (`compvar' == `compvar'__)
				}
				else if (`thisvar_wigglevar'==0) {
					* Numeric without wiggle room is straightforward
					replace `same'  = (`compvar' == `compvar'__)
				}
				else {

					*Take the biggest value of the two vars and calculate absolute wiggle room from wiggle percent
					replace `wigglevalue' = max(abs(`compvar'),abs(`compvar'__)) * `wiggleroom'

					*Numeric varaibles are allowed to be .01% off by default (rounding errors, rand noise, export/import errors)
					replace `same'  = ( abs(`compvar' -`compvar'__)  < `wigglevalue')

					* Missing values in both files is still same.
					replace `same'  = 1 if missing(`compvar') & missing(`compvar'__)
				}


				**************
				* Display results from listig if identical

				* Count if any values were different, if so display info
				count if (`same'  == 0)
				local count_diff `r(N)'
				if `count_diff' > 0 {

					if  "`vartype'" == "string" gen `diff' = "N/A"
					else gen `diff' = abs(`compvar' - `compvar'__)

					local identical = 0

					noi di "{phang}`compvar' : `count_diff'  miss-match out of `N_both' obs`wigglenote'.{p_end}"

					if "`mdreport'" != "" {
						markdown_missmatch_var, filehandle(`filehandle') var(`compvar')
						forvalues i = 1/`=_N' {
							if `same'[`i'] != 1 {
								local sval = `compvar'[`i']
								local lval = `compvar'__[`i']
								local IDstr = `IDstring'[`i']
								local diffstr = `diff'[`i']

								markdown_missmatch_varval, filehandle(`filehandle') sval(`sval') lval(`lval') idstr("`IDstr'") diffstr(`diffstr')
							}
						}
					}
				}
				else {
					noi di "{phang}`compvar' : All `N_both' observations are identical`wigglenote'.{p_end}"
				}
			}
		}  // foreach compvar of local comparevars_both_files

	if "`mdreport'" != "" & ("`mdevensame'" != "" | `identical' == 0) {
		markdown_writefile , filehandle(`filehandle') markdownfile("`mdreport'") markdowntemp("`tmp_mdfile'")
	}

	restore

	*Return local that indicates if they are identical
	return local identical `identical'

}
end

cap program drop str_to_disp
program str_to_disp, rclass

	syntax, string(string) maxlen(integer)

		*Truncate long varlists to lon
		if `=strlen("`string'")' > `maxlen' {
			local str_to_disp = "[list is truncated - " + substr("`string'", 1,`maxlen') + "]"
		}
		else {
			local str_to_disp "`string'"
		}

		return local str_to_disp "`str_to_disp'"
end

cap program drop markdown_writeheader
program markdown_writeheader, rclass
	syntax , filehandle(string) localfile(string) sharedfile(string)
	file write `filehandle' "## Compare file output" _n _n "### Meta information:" _n
	file write `filehandle' "|Key|Value|" _n
	file write `filehandle' "|---|---|" _n
	file write `filehandle' "|Local file|`localfile'|" _n
	file write `filehandle' "|sharedfile|`sharedfile'|" _n
	file write `filehandle' "|User|`c(username)'|" _n
	file write `filehandle' "|Date|$S_DATE|" _n
	file write `filehandle' "|Time|$S_TIME|" _n
end

cap program drop markdown_writefile
program markdown_writefile, rclass

	syntax , filehandle(string) markdownfile(string) markdowntemp(string)

	file close `filehandle'
	copy "`markdowntemp'" "`markdownfile'", replace
	noi disp "Markdown file prepared"

end

cap program drop markdown_obs
program markdown_obs, rclass
	syntax , filehandle(string) obs_in_lfile(string) obs_in_sfile(string) obs_both(string) obs_only_l(string) obs_only_s(string)

	file write `filehandle' "### Compare number of observations" _n _n
	file write `filehandle' "|Key|Number of observations|" _n
	file write `filehandle' "|---|---|" _n
	file write `filehandle' "|Local file|`obs_in_lfile' obs|" _n
	file write `filehandle' "|Shared file|`obs_in_sfile' obs|" _n
	file write `filehandle' "|Observations in both files|`obs_both' obs|" _n
	file write `filehandle' "|Observations only in local file|`obs_only_l' obs|" _n
	file write `filehandle' "|Observations only in shared file|`obs_only_s' obs|" _n
end

cap program drop markdown_varsexist
program markdown_varsexist, rclass
	syntax , filehandle(string) compvar_str(string) [lfile_missvars(string) sfile_missvars(string)]

	if "`lfile_missvars'" == "" local lfile_missvars "All variables to compare exist in shared file."
	if "`sfile_missvars'" == "" local sfile_missvars "All variables to compare exist in local file."

	file write `filehandle' "### List compare variables " _n _n
	file write `filehandle' "`compvar_str'" _n
	file write `filehandle' "* `lfile_missvars'" _n
	file write `filehandle' "* `sfile_missvars'" _n _n

end

cap program drop markdown_missmatch_var
program markdown_missmatch_var, rclass
	syntax , filehandle(string) var(string)

	file write `filehandle' _n "#### `var'" _n
	file write `filehandle' "|ID String|Local value|Shared value|diff|" _n
	file write `filehandle' "|---|---|---|---|" _n

end

cap program drop markdown_missmatch_varval
program markdown_missmatch_varval, rclass
	syntax , filehandle(string) sval(string) lval(string) idstr(string) diffstr(string)

	file write `filehandle' "|`idstr'|`lval'|`sval'|`diffstr'|" _n

end
