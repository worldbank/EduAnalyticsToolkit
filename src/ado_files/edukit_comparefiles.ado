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
		idvars(string)		///
		[                   ///
		compareall          ///
		comparevars(string) ///
		wigglevars(string)  ///
		wiggleroom(numlist min=1 max=1 >0 <1)  ///
		listdetail(string)  ///
		varlistlenmax(numlist min=1 max=1 >0) ///
		]

	preserve

	noi di ""

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
				return local sharednoexist 1
				exit
			}
			else if _rc confirm file "``file''"
		}

		* Test that at least comparell or comparevars were used
		if "`compareall'`comparevars'" == "" {
			noi di as error "{phang}You must use one of the options {cmd:compareall} or {cmd:comparevars}.{p_end}"
			error 198
			exit
		}

		* Test comparell and comparevars were not both used at the same time
		if "`compareall'" != "" & "`comparevars'" != "" {
			noi di as error "{phang}You must not use both options {cmd:compareall} and {cmd:comparevars} at the same time.{p_end}"
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

		*Prepare a markdown file for listing differences if listdetail is specified
		if "`listdetail'" != "" {
			tempname	filehandle
			tempfile	tmp_mdfile
			file open  `filehandle' using `tmp_mdfile', write text replace
			file write `filehandle' "Local  file: `localfile'" _n
			file write `filehandle' "Shared file: `sharedfile'" _n
		}

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

		*test that idvars are fully an uniquely identifying
		cap isid `idvars'
		if _rc ==459 {
			noi di as error "{pstd}Variables [`idvars'] do not fully and uniquely identify the observations in localfile(). The local and shared files can only be compared if they have the same fully and uniquely identifying ID variables.{p_end}"
			error _rc
		}

		** If compareall was used, then take all variables from localfile apart
		*  from idvars and add to comparevars
		if "`compareall'" != "" {
			ds `idvars', not
			local comparevars "`r(varlist)'"
		}

		*Save the number of obseravations
		local obs_in_new_file = _N
		noi di "{col 5}Local file: {col 18}N = `obs_in_new_file'"

		* Make a list of all vars in the new file
		ds
		local new_file_vars `r(varlist)'

		* Make a list of all value vars in the new file
		local new_file_comparevars : list comparevars & new_file_vars

		* Make a list of all value vars expected in new file but missing
		local new_file_miss_comparevars : list comparevars - new_file_comparevars

		*Rename all vars in the new data set (this rename will not be saves)
		foreach newvar of local new_file_comparevars {
			rename `newvar' `newvar'_nw
		}

		*Save temporary data set
		tempfile newdata
		save 	`newdata'

		**************************************
	  ******** Prepare shared file  ********
		**************************************

		use "`sharedfile'", clear

		*test that idvars are fully an uniqely identiftying
		cap isid `idvars'
		if _rc ==459 {
			noi di as error "{pstd}Variables [`idvars'] do not fully and uniquely identify the observations in sharedfile(). The local and shared files can only be compared if they have the same fully and uniquely identifying ID variables.{p_end}"
			error _rc
		}

		*Save the number of obseravations
		local obs_in_shared_file = _N
		noi di "{col 5}Shared file: {col 18}N = `obs_in_shared_file'"


		* Make a list of all vars in the shared file
		ds
		local shared_file_vars `r(varlist)'

		* Make a list of all value vars in the new file
		local shared_file_comparevars : list comparevars & shared_file_vars

		* Make a list of all value vars expected in new file but missing
		local shared_file_miss_comparevars : list comparevars - shared_file_comparevars

		**************************************
	  ************ Merge files  ************
		**************************************

		merge 1:1 `idvars' using `newdata', gen(local_shared_merge)


		**************************************
	  ********** Test Difference ***********
		**************************************
		***** Missing compare variables ******
		**************************************

		noi di ""
		if ("`compareall'" != "") noi di "{pstd}The option [compareall] was used so all variables in the local file will be compared across the two files.{p_end}"
		else noi di "{pstd}The variables in [comparevars(`comparevars')] will be compared across the two files.{p_end}"

		* Export list of compare variables missing in local file
		if "`new_file_miss_comparevars'" != "" {

			local identical = 0

			* Trunctate varaible list if too long
			str_to_disp, string("`new_file_miss_comparevars'") maxlen(`varlistlenmax')
			local varlist_display "`r(str_to_disp)'"

			*Output in result window
			noi di ""
			noi disp "{phang}Value variables are missing in the local file. These variables are missing: `varlist_display' {p_end}"

			* Out put in file if listdetail option used
			if "`listdetail'" != "" {
				file write `filehandle' "shared vars error" _n
				file write `filehandle' "Expected comparevars missing in local fiel: `new_file_miss_comparevars'" _n
			}
		}

		*Export list of compare variables missing in shared file
		if "`shared_file_miss_comparevars'" != "" {

			local identical = 0

			* Trunctate varaible list if too long
			str_to_disp, string("`shared_file_miss_comparevars'") maxlen(`varlistlenmax'	)
			local varlist_display "`r(str_to_disp)'"

			*Output in result window
			noi di ""
			noi disp "{phang}Value variables are missing in the shared file. These variables are missing: `varlist_display' {p_end}"

			* Out put in file if listdetail option used
			if "`listdetail'" != "" {
				file write `filehandle' "shared vars error" _n
				file write `filehandle' "Expected comparevars missing in local fiel: `shared_file_miss_comparevars'" _n
			}
		}

		if "`new_file_miss_comparevars'" == "" & "`shared_file_miss_comparevars'" == "" {
			noi di ""
 			noi di "{pstd}All compare variables exist in both files.{p_end}"
		}
		noi di ""

		**************************************
	  ********** Test Difference ***********
		**************************************
		****** Different observations ********
		**************************************

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



		**************************************
	  ********** Test Difference ***********
		**************************************
		********* Different values ***********
		**************************************

		*Keep only observatins in both
		keep if local_shared_merge == 3

		local N_both `=_N'

		if "`listdetail'" != "" {
			file write `filehandle' "**Unmatched variables" _n
		}

		local allvarsidentical = 1

		* Create a list of variables
		local comparevars_both_files : list shared_file_comparevars & new_file_comparevars

		tempvar same wigglevalue diff
		gen `same'        = 0
		gen `wigglevalue' = 0

		*Loop over all non-idvars
		foreach compvar of local comparevars_both_files {

			noi di ""
			noi di "{pstd}`compvar'{p_end}"

			*Reset values for each var
			replace `same'        = 0
			replace `wigglevalue' = 0

			cap drop `diff'

			*Note to display when wiggle room was
			local wigglenote ""

			**************
			* Test that variables are the same type

			* Test first what typ var is in local file
			cap confirm string variable `compvar'_nw
			if !_rc local vartype "string"
			else local vartype "numeric"

			* Then test that var is the same in shared file
			cap confirm `vartype' variable `compvar'
			if _rc {

				*Output in result window
				noi disp "{phang}Type miss-missmatch, `vartype' in local file {p_end}"

				* Out put in file if listdetail option used
				if "`listdetail'" != "" {
					file write `filehandle' "Variable type miss-match" _n
					file write `filehandle' "Variable `compvar' is `vartype' in local file but not in shared file." _n
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
					replace `same'  = (`compvar' == `compvar'_nw)
				}
				else if (`thisvar_wigglevar'==0) {
					* Numeric without wiggle room is straightforward
					replace `same'  = (`compvar' == `compvar'_nw)
				}
				else {

					*Take the biggest value of the two vars and calculate absolute wiggle room from wiggle percent
					replace `wigglevalue' = max(abs(`compvar'),abs(`compvar'_nw)) * `wiggleroom'

					*Numeric varaibles are allowed to be .01% off by default (rounding errors, rand noise, export/import errors)
					replace `same'  = ( abs(`compvar' -`compvar'_nw)  < `wigglevalue')

					* Missing values in both files is still same.
					replace `same'  = 1 if missing(`compvar') & missing(`compvar'_nw)
				}


				**************
				* Display results from listig if identical

				* Count if any values were different, if so display info
				count if (`same'  == 0)
				local count_diff `r(N)'
				if `count_diff' > 0 {

					if  "`vartype'" == "string" gen `diff' = "N/A"
					else gen `diff' = abs(`compvar' - `compvar'_nw)

					local identical = 0

					noi di "{phang}`count_diff'  miss-match out of `N_both' obs`wigglenote'.{p_end}"

					noi list `idvars' `compvar' `compvar'_nw `diff' if `same' == 0

					if "`listdetail'" != "" {

						*write down the detialed list if listdetail is specified
						file write `filehandle' "***`compvar'" _n
						file write `filehandle' "|obs|`compvar'_local|`compvar'_shared|" _n
						file write `filehandle' "|---|---|---|" _n

						forvalues i = 1/_N {
							if `same'[`i'] == 1 {
								local value1 = `compvar'[`i']
								local value2 = `compvar'_nw[`i']
								file write `filehandle' "|`i'|`value1'|`value2'|" _n
							}
						}
					}
				}
				else {
					noi di "{phang}All `N_both' observations are identical`wigglenote'.{p_end}"
				}
			}
		}  // foreach compvar of local comparevars_both_files

	if "`listdetail'" != "" {
		file close `filehandle'
		copy `tmp_mdfile' "`listdetail'", replace
		noi disp "saved `listdetail'"
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
