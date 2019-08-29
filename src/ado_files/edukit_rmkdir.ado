* This program is a recursive implmentation of mkdir, i.e. you can created nested folders like WLD/WLD_2008_PISA.
* The command does not crash if any folder in the nested folder already exists

cap program drop edukit_rmkdir
program  define  edukit_rmkdir, rclass

	syntax, parent(string) newfolders(string)

	* Test that parent folder exists
	mata : st_numscalar("r(dirExist)", direxists("`parent'"))
	if `r(dirExist)' == 0 {
		noi di as error `"{phang}Parent folder [`parent'] does not exist{p_end}"'
		error 601
	}

	* Switch all slashes to slashes that work on Windows/Mac/Linux
	local this  = subinstr(`"`newfolders'"', "\", "/", .)
	local firstSlash = strpos(`"`this'"',"/")

	* If there is a slash in the newfolders string, split up this folder and rest
 	if `firstSlash' != 0 {
		local rest = substr(`"`this'"', `firstSlash'+1, .) // +1 so that slash is not a part of `rest'
		local this = substr(`"`this'"', 1, `firstSlash'-1) // -1 so that slash is not a part of `this'
	}

	* Create a local with the full path of the folder to be created
	local this_full_path `"`parent'/`this'"'

	* Test if next folder exists, if not create it
	mata : st_numscalar("r(dirExist)", direxists(`"`this_full_path'"'))
	if `r(dirExist)' == 0 mkdir `"`this_full_path'"'

	* Recursive call on the rest of the string if there was a slash in the newfolders
	* string. rest can be empty when firstSlash is > 0 if newfodlers string end on a /
	if (`firstSlash' > 0 & "`rest'" != "") qui edukit_rmkdir , parent(`"`this_full_path'"') newfolders(`"`rest'"')

	* Display and return results
	local resultfolder `"`parent'/`newfolders'"'
	noi di as txt `"{pstd}Folder [`resultfolder'] was created or did already exist.{p_end}"'
	return local folder `"`resultfolder'"'

end
