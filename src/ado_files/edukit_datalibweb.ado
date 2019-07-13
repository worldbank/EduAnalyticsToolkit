/* This program tentatively calls datalibweb 10 times,
	 to prevent breaking a long loop if connection is temporarily
	 lost while querying a file.

	 It has the sideeffect of suppressing the datalibweb header/disclaimer.

	 As it borrows the exact same syntax of datalibweb,
	 check the original help file of datalibweb for more info on syntax.
*/

cap program drop edukit_datalibweb
program  define  edukit_datalibweb, rclass

	syntax,	Datalibweb_syntax(string)

	quietly {

		noi disp as txt "{phang2}Calling... datalibweb, `datalibweb_syntax'{p_end}"

		local success = 0
		local attempt = 1

		/* Tentatively call datalibweb 10 times, for as long as did not
			loaded a proper dataset (non-empty)	*/
		while `attempt'<=10 & `success'!=1 {

			capture datalibweb, `datalibweb_syntax'

			if _rc==0 {
				/* If datalibweb did not run into any errors,
				still double checks that the loaded dataset	is
				not empty (may happen if queried too often/too soon) */
				describe
				if (`r(k)'!=0 & `r(N)'!=0) {
					local success = 1
				}
			}

			local attempt = `attempt' + 1
		}

		* After 10 failed attempts, give-up
		if `success'==0 {
			noi disp as err "{phang}Having issues with Datalibweb, after 10 failed attempts.{p_end}"
			/* The program dlw_message is a subfunction of datalibweb which
			 	 serves to display more informative error messages on failure */
			dlw_message, error(_rc)
			error _rc
		}

	}

end


/***** USAGE EXAMPLES
* should work
edukit_datalibweb, datalibweb_syntax("country(LAC) year(2006) type(EDURAW) surveyid(LAC_2006_LLECE) filename(m3.dta)")
* should give error file doesnt exist
edukit_datalibweb, datalibweb_syntax("country(LAC) year(2006) type(EDURAW) surveyid(LAC_2006_LLECE) filename(mssssss3.dta)")
* should give error access denied
edukit_datalibweb, datalibweb_syntax("country(SSA) year(1995) type(EDURAW) surveyid(SSA_1995_SACMEQ_v01_M) filename(back_03_1995_06_9.dta)
