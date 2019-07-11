* Saves a dataset after compressing and checking isid, with
*   options to store metadata and variable information in chars,
*   plus flexibility to execute special commands for eduanalytics.

cap program drop edukit_save
program define   edukit_save, rclass

	syntax,	FILEname(string) Path(string) IDvars(string) ///
		[ VARClasses(string) METAdata(string) dir2delete(string) COLLection(string) ]
		* path is mandatory because we want to avoid saving files in the working dir
		* idvars is mandatory so we can test it using isid `idvars' and auto fill the char as below
		* varclasses is tokenized to fill char varX[varclass] Y, where Y = ID (auto), Value, Trait, Sample, ...
		* metadata is tokenized to become char _dta[X] Y, where X and Y can be anything
		* dir2delete is optional, usually a temp folder (with subfiles) that one wishes to delete as a last step
		* collection is optional, used to host commands that are specific to files of a special collection

	**************************************
	**** Deals with path and filename ****
	**************************************

	*Test that the path exists
	mata : st_numscalar("r(dirExist)", direxists("`path'"))
 	if `r(dirExist)' == 0 {
		noi di as error "Argument path does not exist or is not accessible"
		exit
	}

	*Removes .dta extension if already specified in filename argument
	if strrpos(".dta","`filename'")==4  local filename = substr("`filename'", 1, length("`filename'") - 4)

	**************************************
	*********  Deals with idvars  ********
	**************************************
	* Check if isid
	capture isid `idvars'
	if _rc!=0 {
		noi di as error "{phang}IDvars do not uniquely identify the dataset and/or have missing values. No file will be saved.{p_end}"
		exit
	}

	*Cleans char variable_class for all variables
	foreach var of varlist _all {
		char `var'[varclass] 	""
	}

	* Un-abbreviate varlists with wildcards*
	unab idvars : `idvars'
	foreach idvar of varlist `idvars' {
		char `idvar'[varclass] 	"id"
	}
	*Automatic metadata: variables which are in variable_class id
	char _dta[idvars]   "`idvars'"
	* Macro that will store the list of vars to order and keep
	local ordered_vars "`idvars'"


	**************************************
	******  Variable class markers  ******
	**************************************
	*Macro vars_classes is needed when generating html via dyndoc
	* it starts with ID (mandatory) and is updated with tokenized varsclass
	local varclasses_used "idvars"

	while "`varclasses'" != "" {
		*Parsing variable_class and variables to set
		gettoken setclass_name_and_vars varclasses : varclasses, parse(";")
		*Splitting variable_class and variables
		gettoken varclass_name class_variables : setclass_name_and_vars
		*Removing leading or trailing spaces
		local varclass_name = trim("`varclass_name'")
		local class_variables   = trim("`class_variables'")
		* Unabbreviate wildcards* in the varaibles for this class
		unab class_variables : `class_variables'
		*Update macros with newly isolated variable_class / vars
		local varclasses_used "`varclasses_used' `varclass_name'vars"
		local ordered_vars    "`ordered_vars' `class_variables'"
		*Automatic metadata: variables which are in this variable_class
		char _dta[`varclass_name'vars]    "`class_variables'"
		*Also assigns char variable_class to the vars individually
		foreach var of varlist `class_variables' {
			char `var'[varclass] 	"`varclass_name'"
		}
		*Parse character is not removed by gettoken
		local varclasses = subinstr("`varclasses'" ,";","",1)
	}


	**************************************
	******  Metadata saved as chars  *****
	**************************************
	*Macro metadata_chars is needed when generating html via dyndoc
	* it starts with automatic metadata and is updated with tokenized varsclass
	local metadata_chars "lastsave varclasses"
	while "`metadata'" != "" {
		*Parsing char and value to set
		gettoken setchar_and_setvalue metadata : metadata, parse(";")
		*Splitting char and value
		gettoken setchar setvalue : setchar_and_setvalue
		*Removing leading or trailing spaces
		local setchar  = trim("`setchar'")
		local setvalue = trim("`setvalue'")
		*Update macro with newly isolated variable_class
		local metadata_chars "`metadata_chars' `setchar'"
		*Core of this while loop: assign the value to the dta characteristic
		char _dta[`setchar']	"`setvalue'"
		*Parse character is not removed by gettoken
		local metadata = subinstr("`metadata'" ,";","",1)
	}

	// Automatic metadata, not explicit in the optional argument
	local lastsave 	=	trim("`c(current_date)'") + " " + "`c(current_time)'" + " by " + "`c(username)'"
	char _dta[lastsave] "`lastsave'"
	char _dta[varclasses_used] "`varclasses_used'"
	char _dta[metadata_chars] "`metadata_chars'"


	**************************************
	*****  Compress, organize, save  *****
	**************************************
	compress
	// Special case for GLAD, which requires a GLAD_BASE.dta to be saved before discarding variables
	if "`collection'" == "GLAD" {
		save "`path'/`filename'_BASE.dta", replace
	}
	// Organizes the dataset and saves it
	sort  `idvars'
	order `ordered_vars'
	keep  `ordered_vars'
	save "`path'/`filename'.dta", replace


	**************************************
	****  dir2delete option (temp files) ****
	**************************************
	if "`dir2delete'" != "" {
		fs "`dir2delete'/*.dta"
		foreach f in `r(files)' {
			cap erase "`dir2delete'/`f'"
		}
		cap rmdir "`dir2delete'"
	}


end
