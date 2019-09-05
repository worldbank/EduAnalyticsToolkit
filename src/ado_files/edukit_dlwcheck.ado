
cap program drop 	edukit_dlwcheck
program define	edukit_dlwcheck, rclass
qui {
  syntax , cntfolder(string) [country(string) survey(string) reportfolder(string) showoptional]

  *Build the basefolder
  local basefolder = subinstr("`cntfolder'","\","/",.)
  if "`country'" != ""  local basefolder "`basefolder'/`country'"
  if "`survey'" != ""   local basefolder "`basefolder'/`survey'"

  *List off all valid country names. Used in country folders and as first 3 letters in survye foldre name
  local valid_countries "AFG AGO ALB ARE ARG ARM ATG AUS AUT AZE BDI BEL BEN BFA BGD BGR BHR BIH BLZ BOL BRA BWA CAN CHE CHL CHN CIV CMR COD COL CRI CYP CZE DEU DMA DNK DOM DZA EGY ESP EST ETH FIN FRA GAB GBR GEO GHA GIN GMB GRC GRD GUY HKG HND HRV HTI HUN IDN IND IRL IRN IRQ ISL ISR ITA JAM JOR JPN KAZ KEN KGZ KHM KIR KNA KOR KWT LAO LBN LBR LCA LIE LKA LTU LUX LVA MAC MAR MDA MDG MEX MKD MLI MLT MMR MNE MNG MOZ MRT MUS MWI MYS NER NGA NIC NLD NOR NPL NZL OMN PAK PAN PER PHL PNG POL PRT PSE QAT ROU RUS RWA SAU SDN SEN SGP SLB SLE SLV SRB SSD SVK SVN SWE SYR TCD TGO THA TJK TLS TON TTO TUN TUR TUV TWN TZA UGA UKR URY USA VCT VEN VNM VUT WSM XKX YEM ZAF ZMB"

  *List off all valid region names. Used in country folders and as first 3 letters in survye foldre name
  local valid_regions "LAC SSA WLD"

  *Combine the list of valid country and region abbreviations
  local valid_abbreviations "`valid_countries' `valid_regions'"

  *List of valid assessments to
  local valid_assessments "EGRA LLECE NLA PASEC PIRLS PISA PISAD SACMEQ TIMSS"

  /***********************************
    Test user input
  ***********************************/

  *Test that country is specified if survey is specified
  if ("`country'" == "") & ("`survey'" != "") {
    noi di as error "{pstd}If you are specifying a survey you must also specify the country.{p_end}"
    error 198
  }

  *Test that the basefolder exist
  mata : st_numscalar("r(dirExist)", direxists("`basefolder'"))
  if (`r(dirExist)' == 0) {
    noi di as error "{pstd}Something is wrong with how the options were specified. The folder [`basefolder'] does not exist.{p_end}"
    error 198
  }

  *If country option is used, make sure that it is a valid country
  if ("`country'" != "")  {
    *Test that the specified country folder is a valid country abbrevatiation
    local  valid_country_folder : list country in valid_abbreviations
    if `valid_country_folder' == 0 {
      noi di as error "{pstd}The folder [`country'] specified in option country is not a valid country abbreviation.{p_end}"
      error 198
    }
  }

  * Handle option that force that optional folders are still shown
  if ("`showoptional'" == "") local optional "optional"
  else local optional ""

  /***********************************
  ************************************

    Set up loop depending on basefolder
    is all of database, country or survey

  ************************************
  ***********************************/

  tempname 	handle
  tempfile	smclReport

  cap file close 	`handle'
  file open `handle' using "`smclReport'", text write replace

  *Create a timestamp for the report
  local date = subinstr("`c(current_date)'" ," ", "", .)
  local time = subinstr("`c(current_time)'" ,":", "", .)
  local timestamp "`date'_`time'"


  *This command write the top of the result table in the result window, and sets up the report file
  noi start_output_and_file, handle(`handle') timestamp(`timestamp') user(`c(username)')

  ************************************
  *
  *  Nither country or survey were specified,
  *  list and loop over all country folders
  *  and all the survey folders within them.
  *
  ************************************

  *If neither country or survey are specified then loop over all of database
  if ("`country'" == "" & "`survey'" == "") {

    *List all country folders
    local dlist : dir `"`basefolder'"' dirs "*", respectcase

    *Make sure this only folders that are countries are listed
    local not_country_folders     :  list dlist - valid_abbreviations //to be displayed, not erorr just notify
    local valid_country_folders   :  list dlist & valid_abbreviations

    *List country folders and non-valid country folders
    noi write_to_output_and_file, handle(`handle') output("{col 4}{c |}")
    noi write_to_output_and_file, handle(`handle') output(`"{col 4}{c |}{col 6} Valid country/region folders found: `valid_country_folders'"')
    noi write_to_output_and_file, handle(`handle') output("{col 4}{c |}")
    noi write_to_output_and_file, handle(`handle') output(`"{col 4}{c |}{col 6} Non-country/non-regions folders found (will be ignored): `not_country_folders'"')
    noi write_to_output_and_file, handle(`handle') output("{col 4}{c |}")

    *Loop over all valid country folders, and run
    foreach country_dir of local valid_country_folders {
      noi test_countryfolder, handle(`handle') countryfolder("`basefolder'/`country_dir'") country("`country_dir'") valid_abbreviations("`valid_abbreviations'") valid_assessments("`valid_assessments'") `optional'
    }
  }

  ************************************
  *
  *  Only country was specified, just
  *  test folders for only that country
  *
  ************************************

  *Only one single country folder are listed
  else if ("`country'" != "" & "`survey'" == "") {

    noi test_countryfolder ,handle(`handle') countryfolder("`basefolder'") country("`country'") valid_abbreviations("`valid_abbreviations'") valid_assessments("`valid_assessments'") `optional'
  }

  ************************************
  *
  *  Both country and survey were specifed,
  *  just test folders for only that survey
  *  for that country country
  *
  ************************************

  else if ("`country'" != "" & "`survey'" != "") {

    **Print country head. Need to do it here as the test_countryfolder
	* commnand where it otherwise happneds is not used when both country
	* and survey are specifed
    noi write_to_output_and_file, handle(`handle') output("{col 4}{c LT}{hline 40}")
    noi write_to_output_and_file, handle(`handle') output("{col 4}{c |}")
    noi write_to_output_and_file, handle(`handle') output("{col 4}{c |}{col 8}`country'")
    noi write_to_output_and_file, handle(`handle') output("{col 4}{c |}")

	*Test this survey only
    noi test_surveyfolder , handle(`handle') surveyfolder("`basefolder'") survey("`survey'") country("`country'") valid_abbreviations("`valid_abbreviations'") valid_assessments("`valid_assessments'") `optional'
  }

  else {

	*This is just a catch, if this error message happen there is a programming error in the command.
    noi di as error "{pstd}Programming error, code should never reach this place.{p_end}"
    error 198
  }

  noi end_output_and_file, handle(`handle') tempfilename(`smclReport') reportfolder(`"`reportfolder'"') timestamp(`timestamp')

}
end


/*************************************************

  Utility functions

*************************************************/

*This command handles how to test all content of a country folder
cap program drop test_countryfolder
program define	 test_countryfolder, rclass
qui {
  syntax , handle(string) countryfolder(string) country(string) valid_abbreviations(string) valid_assessments(string) [optional]

  noi write_to_output_and_file, handle(`handle') output("{col 4}{c LT}{hline 40}")
  noi write_to_output_and_file, handle(`handle') output("{col 4}{c |}")
  noi write_to_output_and_file, handle(`handle') output("{col 4}{c |}{col 8}`country'")
  noi write_to_output_and_file, handle(`handle') output("{col 4}{c |}")

  *List any files in the country folder, there must not be any
  local flist : dir `"`countryfolder'"' files "*", respectcase
  if "`flist'" != "" {
    noi di as error "{pstd}There are files in the [`country'] folder. Only survey folders are allowed there.{p_end}"
    error 198
  }

  *List folders in this folder
  local surveyfolders : dir `"`countryfolder'"' dirs "*", respectcase

  *Display error if there is none, but do not throw erorr code
  if `"`surveyfolders'"' == "" {
    noi di as error "{pstd}There are no survey folders in the [`country'] folder, that folder is emtpy.{p_end}"
  }
  *Loop over all survey folders
  else {
    *Loop over all survey folders
    foreach surveyfolder of local surveyfolders {
      noi test_surveyfolder , handle(`handle') surveyfolder("`countryfolder'/`surveyfolder'") survey("`surveyfolder'") country(`country') valid_abbreviations(`valid_abbreviations') valid_assessments("`valid_assessments'") `optional'
    }
  }
}
end

*This command handles how to test all content of a survey folder folder
cap program drop test_surveyfolder
program define	 test_surveyfolder, rclass
qui {
  syntax , handle(string) surveyfolder(string) survey(string) country(string) valid_abbreviations(string) valid_assessments(string) [optional]

  noi write_to_output_and_file, handle(`handle') output("{col 4}{c LT}{hline 40}")
  noi write_to_output_and_file, handle(`handle') output("{col 4}{c |}{col 6}`survey'")
  noi write_to_output_and_file, handle(`handle') output("{col 4}{c LT}{hline 40}")

  ************************
  * Test that the survey name is a valid name

  *No name is valid if name if less than 10 characters
  local survey_folder_name_length	= strlen("`survey'")

  *Extract country from survey name and test that it is valid country abbreviation
  local survey_country 	= substr("`survey'", 1,3)
  local valid_survey_country : list survey_country in valid_abbreviations

  *Extract year from survey name and test it is a number
  local year 		= substr("`survey'", 5,4)
  cap confirm number `year'
  local numbercheck = _rc

  *Extract assessment from survey name and test it is a number
  local assessment 	= substr("`survey'", 10,.)
  local valid_assessment_folder : list assessment in valid_assessments

  *Test that country name in survey option is same as in country

  *Name must be longer then 10 characters to at all be valid
  if `survey_folder_name_length' < 10 {
	  noi write_to_output_and_file, handle(`handle') output(`"{col 4}{c |}{col 8}INVALID FOLDER: {col 28}[`surveyfolder'] - name to short for survey name format CCC_YYYY_surveyname"')
  }
  *Country name in survey folder name is not the same as the country folder name
  else if ("`survey_country'" != "`country'") {
    noi write_to_output_and_file, handle(`handle') output(`"{col 4}{c |}{col 8}INVALID FOLDER: {col 28}[`surveyfolder'] - survey country not same as country folder"')
  }
  *Test that YYYY is a number
  else if `numbercheck' != 0 {
	  noi write_to_output_and_file, handle(`handle') output(`"{col 4}{c |}{col 8}INVALID FOLDER: {col 28}[`surveyfolder'] - year not valid in survey name format CCC_YYYY_surveyname"')
  }
  *Test that Assessment is valid
  else if `valid_assessment_folder' == 0 {
      noi write_to_output_and_file, handle(`handle') output(`"{col 4}{c |}{col 8}INVALID FOLDER: {col 28}[`surveyfolder'] - assessment name not valid in survey folder name"')
  }


  *All tests passed, check the content of the survey folder
  else {

	  ************************
	  * Test that the folder structure is ok

	  *Create a list with valid folders for this folder
	  local validfolders ""

	  *All versions of the EDURAW collection in this survey folder
	  noi check_collection , handle(`handle') surveyfolder(`"`surveyfolder'"') collection("RAW")  fld_pattern("`survey'_v*_M") `optional'

      local validfolders "`validfolders' `r(validfolders)'"

      *Loop over the vintages for which there are EDURAW collections and test that there are GLAD and HLO folders for all of them
      foreach vintage in `r(master_vintages)' {
          *All vintaged versions of the GLAD collection in this survey folder
          noi check_collection , handle(`handle') surveyfolder(`"`surveyfolder'"') collection("GLAD") fld_pattern("`survey'_`vintage'_M_v*_A_GLAD") `optional'
          local validfolders "`validfolders' `r(validfolders)'"

          *All wrk versions of the GLAD collection in this survey folder
          noi check_collection , handle(`handle') surveyfolder(`"`surveyfolder'"') collection("GLAD") fld_pattern("`survey'_`vintage'_M_wrk_A_GLAD") `optional'
          local validfolders "`validfolders' `r(validfolders)'"

          *All vintaged versions of the HLO collection in this survey folder
          noi check_collection , handle(`handle') surveyfolder(`"`surveyfolder'"') collection("HLO") fld_pattern("`survey'_`vintage'_M_v*_A_HLO") `optional'
          local validfolders "`validfolders' `r(validfolders)'"

          *All wrk versions of the HLO collection in this survey folder
          noi check_collection , handle(`handle') surveyfolder(`"`surveyfolder'"') collection("HLO") fld_pattern("`survey'_`vintage'_M_v*_A_HLO") `optional'
          local validfolders "`validfolders' `r(validfolders)'"
      }

      if (trim(`"`validfolders'"') == "") {
          noi write_to_output_and_file, handle(`handle') output(`"{col 4}{c |}{col 8}NO EDURAW COLLECTION: {col 28} - At least one EDURAW vintage folder must exist"')
      }

	  *Output a list of all folders in the survey-level folder that are invalid, these are all non-collection folders directly under the survey folder.
	  noi list_invalid_and_missing_folders , handle(`handle') folder(`"`surveyfolder'"') expectedfolders(`"`validfolders'"') `optional'

  }
}
end

*Check which versions exist for each collection, and then test the content for each of them
cap program drop check_collection
program define	 check_collection, rclass
qui {
  syntax , handle(string) surveyfolder(string)  fld_pattern(string) collection(string) [optional]

  *List all the vintages for this collection. In most cases there will only be vintage
  *version 01, but it could be any number of vintages for each collection.
  local collection_folders   : dir `"`surveyfolder'"' dirs "`fld_pattern'", respectcase

  *Loop over each collection folder (only one folder if only version 01), and apply to corresponding checek
  foreach collection_folder of local collection_folders {
    if "`collection'" == "RAW"  noi checkraw  , handle(`handle') surveyfolder(`"`surveyfolder'"') folder("`collection_folder'") `optional'
    if "`collection'" == "GLAD" noi checkglad , handle(`handle') surveyfolder(`"`surveyfolder'"') folder("`collection_folder'") `optional'
    if "`collection'" == "HLO"  noi checkhlo  , handle(`handle') surveyfolder(`"`surveyfolder'"') folder("`collection_folder'") `optional'

    * Collect and pass back all the master vintages that already exists
    if "`collection'" == "RAW" {
        local master_vintages = "`master_vintages' " + substr("`collection_folder'", -5, 3)
    }
  }

  *Pass back valid folders
  return local validfolders "`collection_folders'"

  *Pass back all master vintages
  if "`collection'" == "RAW" {
      return local master_vintages = trim("`master_vintages'")
  }
}
end


* Check for expected and invalid folders and files specific to the EDURAW collections
cap program drop checkraw
program define	 checkraw, rclass
qui {
  syntax, handle(string)  surveyfolder(string) folder(string) [optional]

  *Create the foldre local for this collection
  local rawfolder `"`surveyfolder'/`folder'"'

  *List all expteced folders that do not exist, and all existing folders
  *that were not expected. Create missing expected folders if creaetmissing is used.
  noi list_invalid_and_missing_folders , handle(`handle') folder(`"`rawfolder'"') expectedfolders("Data") optionalfolders("Codebook Doc") filesnone `optional'
  local existing_expected_folders `r(existing_expected_folders)'

  *If the Data folder did no exist, then it does not make sense to check subfolders
  if strpos("`existing_expected_folders'","Data") != 0 {
      noi list_invalid_and_missing_folders , handle(`handle') folder(`"`rawfolder'/Data"') expectedfolders("Original Stata") filesnone
      local existing_Data_folders `r(existing_expected_folders)'

      if strpos("`existing_Data_folders'","Original") != 0 {
          noi list_invalid_and_missing_files, handle(`handle') folder(`"`rawfolder'/Data/Original"') filesany
      }
      if strpos("`existing_Data_folders'","Stata") != 0 {
          noi list_invalid_and_missing_files, handle(`handle') folder(`"`rawfolder'/Data/Stata"') filepatterns("*.dta *.DTA")
      }
  }

  *If the Doc folder did no exist, then it does not make sense to check subfolders
  if strpos("`existing_expected_folders'","Doc") != 0 {
      noi list_invalid_and_missing_folders , handle(`handle') folder(`"`rawfolder'/Doc"') optionalfolders("Questionnaires Reports Technical") filesnone `optional'
  }
}
end

* Check for expected and invalid folders and files specific to the GLAD collections
cap program drop checkglad
program define	 checkglad, rclass
qui {
  syntax, handle(string) surveyfolder(string) folder(string) [optional]

  *Create the foldre local for this collection
  local gladfolder `"`surveyfolder'/`folder'"'

  *List all expteced folders that do not exist, and all existing folders
  *that were not expected. Create missing expected folders if creaetmissing is used.
  noi list_invalid_and_missing_folders , handle(`handle') folder(`"`gladfolder'"') expectedfolders("Data") optionalfolders("Programs") filesnone `optional'
  local existing_expected_folders `r(existing_expected_folders)'

  *If the Data folder did no exist, then it does not make sense to check subfolders
  if strpos("`existing_expected_folders'","Data") != 0 {
      noi list_invalid_and_missing_folders , handle(`handle') folder(`"`gladfolder'/Data"') expectedfolders("Harmonized") filesnone
      local existing_Data_folders `r(existing_expected_folders)'

      * If folder GLAD/Data/Harmonized exist, makes sure that the ALL, All-Base and CLO file is there and nothing else
      if strpos("`existing_Data_folders'","Harmonized") != 0 {
          *Get the exact file prefix from the gladfolder
          local fileprefix = substr("`gladfolder'",strlen("`gladfolder'")-strpos(strreverse("`gladfolder'"),"/")+2,.)
          noi list_invalid_and_missing_files, handle(`handle') folder(`"`gladfolder'/Data/Harmonized"') files("`fileprefix'_ALL-BASE.dta `fileprefix'_ALL.dta `fileprefix'_CLO.dta")
      }
  }

  * If folder GLAD/Data/Programs exist, makes sure that there are at least one do file there, and no other files
  if strpos("`existing_expected_folders'","Programs") != 0 {
      noi list_invalid_and_missing_files, handle(`handle') folder(`"`gladfolder'/Data/Harmonized"') filepatterns("*.do")
  }
}
end


* Check for expected and invalid folders and files specific to the HLO collections
cap program drop checkhlo
program define	 checkhlo, rclass
qui {
  syntax, handle(string) surveyfolder(string) folder(string) [optional]

  *Create the foldre local for this collection
  local hlofolder `"`surveyfolder'/`folder'"'

  *List all expteced folders that do not exist, and all existing folders
  *that were not expected. Create missing expected folders if creaetmissing is used.
  noi list_invalid_and_missing_folders , handle(`handle') folder(`"`hlofolder'"') expectedfolders("Data") optionalfolders("Programs") filesnone `optional'
  local existing_expected_folders `r(existing_expected_folders)'

  *If the Data folder did no exist, then it does not make sense to check subfolders
  if strpos("`existing_expected_folders'","Data") != 0 {
      noi list_invalid_and_missing_folders , handle(`handle') folder(`"`hlofolder'/Data"') expectedfolders("Indicators") filesnone
      local existing_Data_folders `r(existing_expected_folders)'

      * If folder HLO/Data/Indicators exist, makes sure that the ALL file is there and nothing else
      if strpos("`existing_Data_folders'","Indicators") != 0 {
          *Get the exact file prefix from the gladfolder
          local fileprefix = substr("`hlofolder'",strlen("`hlofolder'")-strpos(strreverse("`hlofolder'"),"/")+2,.)
          noi list_invalid_and_missing_files, handle(`handle') folder(`"`hlofolder'/Data/Indicators"') files("`fileprefix'_ALL.dta")
      }
  }

  * If folder GLAD/Data/Programs exist, makes sure that there are at least one do file there, and no other files
  if strpos("`existing_expected_folders'","Programs") != 0 {
      noi list_invalid_and_missing_files, handle(`handle') folder(`"`hlofolder'/Data/Indicators"') filepatterns("*.do")
  }
}
end

**This command compares exisitng list of folders with
* list of expected folders, and output missing and invalid folders.
cap program drop list_invalid_and_missing_folders
program define	 list_invalid_and_missing_folders, rclass
qui {
  syntax, handle(string) folder(string) [expectedfolders(string) optionalfolders(string) filesnone optional]

  *If optional is not used, then also optional folders are expected
  if ("`optional'" == "") {
      local expectedfolders : list expectedfolders | optionalfolders
  }

  * Create local with all folders
  local all_folders : dir `"`folder'"' dirs "*", respectcase

  * Removing expected and optional folders from the list of existing folders, leaves us with the invalid folders
  local invalid_folders : list all_folders - expectedfolders
  local invalid_folders : list invalid_folders - optionalfolders

  * Removing existing folders from the list of expected folders, leaves us with the missing expected folders
  local missing_folders : list expectedfolders - all_folders

  *Output the invalid folders
  foreach invalid_folder of local invalid_folders {
    noi write_to_output_and_file, handle(`handle') output(`"{col 4}{c |}{col 8}INVALID FOLDER: {col 28}[`folder'/`invalid_folder']"')
  }

  *Output the missing expected folders
  foreach missing_folder of local missing_folders {
    noi write_to_output_and_file, handle(`handle') output(`"{col 4}{c |}{col 8}MISSING FOLDER: {col 28}[`folder'/`missing_folder']"')
  }

  *If this folder is suppsoed to have have no files, then test that
  if ("`filesnone'" != "") noi list_invalid_and_missing_files, handle(`handle') folder(`"`folder'"') filesnone

  *Return a local with all existing folders after this command ran, in case subsequent commands
  return local existing_expected_folders : list expectedfolders & all_folders
}
end

**This command compares exisitng list of folders with
* list of expected folders, and output missing and invalid folders.
cap program drop list_invalid_and_missing_files
program define	 list_invalid_and_missing_files, rclass
qui {
  syntax, handle(string) folder(string) [filesnone filesany filepatterns(string) files(string)]

  * Test syntax during testing
  if (!missing("`filesnone'") + !missing("`filesany'") + !missing("`filepatterns'") + !missing("`files'") != 1 ) {
      noi di as error "{pstd}One and exactly one of filesnone, filesany, filepatterns, files must be used.{p_end}"
      error 198
  }

  * Create local with all files
  local all_files : dir `"`folder'"' files "*", respectcase

  * If any files of any sort should be here but none are here, output error
  if ("`filesany'" != "") {
      if (`"`all_files'"' == "") noi write_to_output_and_file, handle(`handle') output(`"{col 4}{c |}{col 8}FOLDER INVALIDLY EMPTY: {col 28}[`folder']"')
  }
  else if ("`filepatterns'" != "" & `"`all_files'"' == "") {
      noi write_to_output_and_file, handle(`handle') output(`"{col 4}{c |}{col 8}FOLDER INVALIDLY EMPTY: {col 28}[`folder']"')
  }
  else {
      ************
      * For the different option determine the expected files

      *option filespattern used: All files on the given pattern are expected
      if ("`filepatterns'" != "") {
          foreach filepattern of local filepatterns {
              local these_expected_files : dir `"`folder'"' files "`filepattern'", respectcase
              local expected_files : list these_expected_files | expected_files
          }
      }
      *option files used: Exactly the files in option files are expected
      else if ("`files'" != "")     local expected_files "`files'"
      *option filesnone used: No files are expected
      else if ("`filesnone'" != "") local expected_files ""

      * Removing expected files from the list of existing files, leaves us with the invalid files
      local invalid_files : list all_files - expected_files

      * Removing existing files from the list of expected files, leaves us with the missing expected files
      local missing_files : list expected_files - all_files

      *Output the invalid files
      foreach invalid_file of local invalid_files {
        noi write_to_output_and_file, handle(`handle') output(`"{col 4}{c |}{col 8}INVALID FILE: {col 28}[`folder'/`invalid_file']"')
      }

      *Output the missing expected files
      foreach missing_file of local missing_files {
        noi write_to_output_and_file, handle(`handle') output(`"{col 4}{c |}{col 8}MISSING FILE: {col 28}[`folder'/`missing_file']"')
      }
  }
}
end

**
cap program drop start_output_and_file
program define	 start_output_and_file, rclass
qui {
    syntax, handle(string) timestamp(string) user(string)

    local top_of_table "{col 4}{c TLC}{hline 60}"

    *Write the beginning of the table
    noi di "`top_of_table'"

    *Write output in report file
    file write  `handle' _n "{col 4}HLO Database file and folder name report" _n _n "{col 4}Date and time: `timestamp'" _n "{col 4}Prepared by `user'" _n _n "`top_of_table'" _n
}
end

**
cap program drop write_to_output_and_file
program define	 write_to_output_and_file, rclass
qui {
    syntax, handle(string) output(string)

    *Write output in result window
    noi di `"`output'"'

    *Write output in report file
    file write  `handle' `"`output'"' _n
}
end


**
cap program drop end_output_and_file
program define	 end_output_and_file, rclass
qui {
    syntax, handle(string) tempfilename(string) timestamp(string) [reportfolder(string)]

    local end_of_table "{col 4}{c BLC}{hline 60}"

    *Write the beginning of the table
    noi di "`end_of_table'"

    if ("`reportfolder'" != "") {

        *Write output in report file
        file write  `handle' `"`end_of_table'"' _n _n _n

        *Closing the new main master dofile handle
        file close 		`handle'

        *Copy the new master dofile from the tempfile to the original position
        copy "`tempfilename'"  `"`reportfolder'/test.smcl"' , replace

        translate "`tempfilename'" `"`reportfolder'/HLO_FOLDER_REPORT_`timestamp'.txt"', trans(smcl2txt) replace linesize(220)

        noi di ""
        noi di `"{pstd}Report written to: {browse "`reportfolder'/HLO_FOLDER_REPORT_`timestamp'.txt":`reportfolder'/HLO_FOLDER_REPORT_`timestamp'.txt}{p_end}"'
    }
}
end
