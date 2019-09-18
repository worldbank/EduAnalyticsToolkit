*! version 1.0 18SEP2019 EduAnalytics eduanalytics@worldbank.org
*  Author: Diana Goldemberg

/* Saves a dataset after compressing and checking isid, with
   options to store metadata and variable information in chars,
   plus flexibility to execute special commands for EduAnalytics */

cap program drop edukit_save
program define   edukit_save, rclass

	syntax,	FILEname(string) Path(string) IDvars(string) ///
		[ VARClasses(string) METAdata(string) dir2delete(string) COLLection(string) ]
		* path is mandatory to avoid default saving files in the working dir
		* idvars is mandatory to  test it using isid `idvars' and auto fill the char idvars as below
		* varclasses is tokenized to fill char varX[varclass] Y, where Y = id (auto), value, trait, sample, ...
		* metadata is tokenized to become char _dta[X] Y, where X and Y can be anything
		* dir2delete is optional, usually a temp folder (with subfiles) that one wishes to delete as a last step
		* collection is optional, used to host commands that are specific to a given collection


	**************************************
	**** Deals with path and filename ****
	**************************************
	* Test that the path exists
	mata : st_numscalar("r(dirExist)", direxists("`path'"))
 	if `r(dirExist)' == 0 {
		noi di as error "{phang}Argument path does not exist or is not accessible.{p_end}"
		error 2222
	}

	* Removes .dta extension if already specified in filename argument
	if strrpos(".dta","`filename'")==4  local filename = substr("`filename'", 1, length("`filename'") - 4)


	**************************************
	** Avoids conflicts in varclass char *
	**************************************
	* Clean slate on char varclass for all variables
	foreach var of varlist _all {
		char `var'[varclass] ""
	}


	**************************************
	*********  Deals with idvars  ********
	**************************************
	* Check if isid
	capture isid `idvars'
	if _rc!=0 {
		noi di as error "{phang}IDvars do not uniquely identify the dataset and/or have missing values. No file will be saved.{p_end}"
		error 2222
	}

	* Unabbreviate wildcards* in the variables for varclass idvars
	unab idvars : `idvars'

	* Automatic metadata (to ease auto-documentation):
	* - dataset record of which variables are idvars
	char _dta[idvars]   "`idvars'"
	* - every idvar receives the char varclass = id
	foreach idvar of varlist `idvars' {
		char `idvar'[varclass] "id"
	}

	* Macro that will store the list of vars to order and keep (all others will be dropped)
	local vars_to_keep "`idvars'"


	**************************************
	******  Variable class markers  ******
	**************************************
	* Having a char vars_classes_used is useful when generating md via dyntext
	* Starts with ID (mandatory option) and is updated with tokenized varsclass
	local varclasses_used "idvars"

	* It would be unusual to save a dataset with only idvars
	if "`varclasses'" == "" {
		noi dis as res "{phang}Warning! You only specified idvars, so the saved dataset will only contain those idvars. If you want to keep other variables, use the option varclass. For example, varclass(value var1 var2; trait var3) would keep var1-var3, in addition to the specified idvars.{p_end}"
	}

	* Varclasses defined by the user, with corresponding vars are parsed
	while "`varclasses'" != "" {

		* Parsing variable_class and variables to set
		gettoken setclass_name_and_vars varclasses : varclasses, parse(";")
		* Splitting variable_class and variables
		gettoken varclass_name class_variables : setclass_name_and_vars
		* Removing leading or trailing spaces
		local varclass_name   = trim("`varclass_name'")
		local class_variables = trim("`class_variables'")
		* Unabbreviate wildcards* in the variables for this varclass
		unab class_variables : `class_variables'

		* Update macros with newly isolated variable_class / vars
		local varclasses_used "`varclasses_used' `varclass_name'vars"
		local vars_to_keep    "`vars_to_keep' `class_variables'"

		* Automatic metadata (to ease auto-documentation):
		* - dataset record of which variables are idvars
		char _dta[`varclass_name'vars]    "`class_variables'"
		* - every var in this varclass receives the char varclass = varclass_name
		foreach var of varlist `class_variables' {
			char `var'[varclass] "`varclass_name'"
		}

		* Parse character is not removed by gettoken
		local varclasses = subinstr("`varclasses'" ,";","",1)
	}


	**************************************
	******  Metadata saved as chars  *****
	**************************************
	* Having a char metada_chars is useful when generating md via dyntext
	* Starts with automatic metadata and is updated with tokenized varsclass
	local metadata_chars "lastsave varclasses_used"

	* Metadata passed as tokenized argument (optional) is parsed
	while "`metadata'" != "" {

		* Parsing char and value to set
		gettoken setchar_and_setvalue metadata : metadata, parse(";")
		* Splitting char and value
		gettoken setchar setvalue : setchar_and_setvalue
		* Removing leading or trailing spaces
		local setchar  = trim("`setchar'")
		local setvalue = trim("`setvalue'")

		* Update macro with newly isolated variable_class
		local metadata_chars "`metadata_chars' `setchar'"

		* Core of this while loop: assign the value to the dta characteristic
		char _dta[`setchar'] "`setvalue'"

		* Parse character is not removed by gettoken
		local metadata = subinstr("`metadata'" ,";","",1)
	}

	* Automatic metadata, not explicit in the optional argument
	local lastsave 	=	trim("`c(current_date)'") + " " + "`c(current_time)'" + " by " + "`c(username)'"
	char _dta[lastsave] "`lastsave'"
	char _dta[varclasses_used] "`varclasses_used'"
	char _dta[metadata_chars] "`metadata_chars'"


	**************************************
	*****  Compress, organize, save  *****
	**************************************
	compress

	* Special commands to perform according to collection go here
	if "`collection'" == "GLAD" {  // GLAD = Global Learning Assessment Database
		* Before discarding variables without a varclass, saves GLAD_module-BASE.dta
		noi save "`path'/`filename'-BASE.dta", replace
	}
	else if "`collection'" == "CLO" {  // CLO = Country Level Outcomes
		noi disp as txt "{phang}FYI: no special commads are defined for collection CLO.{p_end}"
	}
	else if "`collection'" != "" {
		* Option collection can be ommited, but if used and does not match the above, assumes it was an error
		noi disp as error "{phang}You specified a collection for which no special commands are defined. Ommit the collection option, or try another collection.{p_end}"
		error 2222
	}

	* Organizes the dataset
	sort  `idvars'
	order `vars_to_keep'

	* Any variable that was not given a varclass is dropped
	keep  `vars_to_keep'
	save "`path'/`filename'.dta", replace


	**************************************
	*****  dir2delete option (temp) ******
	**************************************
	* In case the creation of the file being saved required tempfiles, this
	* option easily delete all the tempfiles in a tempfolder at once
	if "`dir2delete'" != "" {
		fs "`dir2delete'/*.dta"
		foreach f in `r(files)' {
			cap erase "`dir2delete'/`f'"
		}
		cap rmdir "`dir2delete'"
	}


end
