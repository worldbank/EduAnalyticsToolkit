*! version 0.2 15JUL2019 EduAnalytics eduanalytics@worldbank.org
*  Author: Diana Goldemberg

/* This program calls datalibweb repeatedly to prevent breaking a long loop
   if connection is temporarily lost/other issues while querying a file.

	 It has the side effect of suppressing the datalibweb header/disclaimer.

	 As it borrows the exact same syntax of datalibweb,
	 check the original help file of datalibweb for more info on syntax. */

cap program drop edukit_datalibweb
program  define  edukit_datalibweb, rclass

	syntax,	Datalibweb_syntax(string)
	* in practice, it mimics datalibweb syntax

	quietly {

		* Only message that will display if the command is successful, due to capture in datalibweb
		noi disp as txt "{phang2}Calling... datalibweb, `datalibweb_syntax'{p_end}"

		* Keeping score of attempts and (hopefully) success through locals
		local success = 0
		local attempt = 1

		* Tentatively call datalibweb 5 times, but stops before if gets non-empty dataset	*/
		while `attempt'<=5 & `success'!=1 {

			capture datalibweb, `datalibweb_syntax'

			if _rc==0 {
				/* If datalibweb did not run into any errors,	still double checks that
				the loaded dataset is not empty (may happen if queried too often/too soon) */
				describe
				if (`r(k)'!=0 & `r(N)'!=0) {
					local success = 1
				}
			}

			local attempt = `attempt' + 1
		}

		* After 5 failed attempts, give-up
		if `success'==0 {
			noi disp as err "{phang}Having issues with datalibweb, after 5 failed attempts. Check the original datalibweb help file and the error message below for more info.{p_end}"
			/* Trick to display the original datalibweb error message: call it again
			   If it succeeds this time after 5 errors, it's a miracle! */
			datalibweb, `datalibweb_syntax'
		}

	* Just in case this may be useful
	return local success

	}

end


/***** USAGE EXAMPLES
* should work
edukit_datalibweb, datalibweb_syntax("country(LAC) year(2006) type(EDURAW) surveyid(LAC_2006_LLECE) filename(m3.dta)")
* should give error file doesnt exist
edukit_datalibweb, datalibweb_syntax("country(LAC) year(2006) type(EDURAW) surveyid(LAC_2006_LLECE) filename(mssssss3.dta)")
* should give error access denied
edukit_datalibweb, datalibweb_syntax("country(SSA) year(1995) type(EDURAW) surveyid(SSA_1995_SACMEQ_v01_M) filename(back_03_1995_06_9.dta)
