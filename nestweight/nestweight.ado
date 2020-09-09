*! version 1.0 8SEP2020 EduAnalytics eduanalytics@worldbank.org
*  Author: Diana Goldemberg

/* This program redistribute weights from missing nested observations
   to produce consistent aggregate estimates when missing values
   do not occur completely at random. */

cap program drop nestweight
program define   nestweight, rclass

  syntax varlist(numeric min=1 max=1) [if] [in]  ///
        [pweight fweight aweight] , by(varname)  ///
        [GENerate(name)] [only(string)]

  tempvar numerator denominator auxones newwgtvar sumwgtby
  local myvar `varlist'

  quietly {

    * If no weight is specified, still redistribute the senate weights
    if ("`weight'" == "") {
      gen `auxones' = 1
      local oldwgtexp  "[aw = `auxones']"
      local oldwgtvar  "`auxones'"
      local weight     "aweight"
    }
    * If some weight is specified, store the type and weight variable
    else {
      local oldwgtexp  "[`weight' `exp']"
      local oldwgtvar = trim(subinstr("`exp'","=","",.))
    }

    * To ornate if string when filtering for a certain level of variable by
    capture confirm numeric variable `by'
    if !_rc local bynumeric 1
    else    local bynumeric 0

    * Restricts the universe of variables considered (numerator of adjustment)
    gen `numerator' = 1 `in' `if'

    * Restricts the universe of observations considered (denominator of adjustment)
    gen `denominator' = (`numerator' == 1 & !missing(`myvar') & !missing(`oldwgtvar')) `only'

    * New weights variable start as empty
    gen double `newwgtvar' = .
    local newwgtexp "[`weight' = `newwgtvar']"

    * Replace new weight variable for each level of by variable
    levelsof `by' if `numerator' == 1, local(levelsby)
    foreach level of local levelsby {

      * Numerator of adjustment to be applied to original weights
      if `bynumeric' sum `oldwgtvar' if `by' ==  `level'  & `numerator' == 1
      else           sum `oldwgtvar' if `by' == "`level'" & `numerator' == 1
      local num = `r(sum)'

      * Denominator of adjustment to be applied to original weights
      if `bynumeric'   sum `oldwgtvar' if `by' ==  `level'  & `denominator' == 1
      else             sum `oldwgtvar' if `by' == "`level'" & `denominator' == 1
      local den = `r(sum)'

      * Copies original weights with adjustment into new weights
      if `bynumeric'   replace `newwgtvar' = `oldwgtvar' * `num'/`den' ///
                       if `by' ==  `level'  & `denominator' == 1
      else             replace `newwgtvar' = `oldwgtvar' * `num'/`den' ///
                       if `by' == "`level'" & `denominator' == 1

    }

    * Force weights to be integer numbers if they are frequency weights
    if "`weight'" == "fweight"  recast long `newwgtvar', force

    * Keep the temporary weight variable if generate is specified
    if "`generate'" != ""       clonevar `generate' = `newwgtvar'

  }

  tabstat `myvar' `newwgtexp', by(`by')

  qui sum `myvar' `newwgtexp'

  return local mean `r(mean)'

end
