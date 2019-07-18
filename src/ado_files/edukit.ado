*! version 0.1 11JUL2019 EduAnalytics team_email@worldbank.org

capture program drop edukit
program edukit, rclass

	* UPDATE THESE LOCALS FOR EACH NEW VERSION PUBLISHED
	local version "0.2"
	local versionDate "15JUL2019"

	syntax [anything]

	/**********************
		Error messages
	**********************/
	* Make sure that no arguments were passed
	if "`anything'" != "" {
		noi di as error "This command does not take any arguments, write only {it:edukit}"
		error 198
	}

	/**********************
		Output
	**********************/
	* Prepare returned locals
	return local 	versiondate "`versionDate'"
	return scalar 	version		= `version'

	* Display output
	noi di ""
	noi di _col(4) "This version of edukit installed is version " _col(54)"`version'"
	noi di _col(4) "This version of edukit was released on " _col(54)"`versionDate'"

end
